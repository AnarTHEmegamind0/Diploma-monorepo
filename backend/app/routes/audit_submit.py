"""
Audit Submit route - Main endpoint for mobile app.
Handles image upload, YOLO detection, and auto-answering survey questions.
"""

import json
import shutil
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List
from collections import Counter

from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form, status

from fastapi import Request

from ..config import settings
from ..database import (
    get_campaigns_collection,
    get_surveys_collection,
    get_questions_collection,
    get_tradeshops_collection,
    get_detections_collection,
    get_audit_responses_collection,
)
from ..models.audit_response import (
    Answer,
    AuditLocation,
    AuditSubmitResponse,
    AuditResponseResponse,
)
from ..services.detection_service import DetectionService
from ..dependencies import get_current_auditor

router = APIRouter()


def build_photo_urls(photos: List[str], base_url: str) -> List[str]:
    """Convert photo filenames to full URLs."""
    urls = []
    for photo in photos:
        # Handle both old absolute paths and new filenames
        if "/" in photo or "\\" in photo:
            # Old format: extract filename from path
            filename = Path(photo).name
        else:
            filename = photo
        urls.append(f"{base_url}/uploads/{filename}")
    return urls


def count_detections(detections: List[dict]) -> Dict[str, int]:
    """Count detected products by class name."""
    class_names = [d.get("class_name", "unknown") for d in detections]
    return dict(Counter(class_names))


def _parse_number(value: object) -> Optional[int]:
    """Try to normalize an answer value into a non-negative integer."""
    if isinstance(value, bool):
        return int(value)
    if isinstance(value, (int, float)):
        return max(int(value), 0)
    if isinstance(value, str):
        stripped = value.strip()
        if not stripped:
            return None
        try:
            return max(int(float(stripped)), 0)
        except ValueError:
            return None
    return None


def _parse_yes_no(value: object) -> Optional[bool]:
    """Normalize yes/no style answers used in survey forms."""
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return value > 0
    if isinstance(value, str):
        normalized = value.strip().lower()
        if normalized in {"тийм", "yes", "true", "1"}:
            return True
        if normalized in {"үгүй", "no", "false", "0"}:
            return False
    return None


def calculate_audit_result(
    questions: List[dict],
    answers: List[Answer],
    detected_products: Dict[str, int],
) -> str:
    """
    Compare expected answers against detections and return pass/warning/fail.

    Rules:
    - Difference <= 10% -> pass
    - 10% < difference <= 30% -> warning
    - Difference > 30% -> fail
    - Missing expected product -> fail
    - Extra unexpected product -> warning
    """
    answers_by_id = {answer.question_id: answer for answer in answers}
    exact_expected: Dict[str, int] = {}
    presence_expected: Dict[str, bool] = {}

    for question in questions:
        product_class = question.get("product_class")
        if not product_class:
            continue

        answer = answers_by_id.get(question["_id"])
        if answer is None:
            continue

        question_type = question.get("type", "yes_no")
        if question_type == "number":
            numeric_value = _parse_number(answer.answer)
            if numeric_value is not None:
                exact_expected[product_class] = numeric_value
        else:
            boolean_value = _parse_yes_no(answer.answer)
            if boolean_value is not None and product_class not in exact_expected:
                presence_expected[product_class] = boolean_value

    comparable_products = set(detected_products) | set(exact_expected) | set(presence_expected)
    if not comparable_products:
        return "warning" if not detected_products else "pass"

    has_warning = False
    for product_class in comparable_products:
        detected_count = detected_products.get(product_class, 0)

        if product_class in exact_expected:
            expected_count = exact_expected[product_class]
            if expected_count > 0 and detected_count == 0:
                return "fail"
            if expected_count == 0 and detected_count > 0:
                has_warning = True
                continue

            difference = abs(detected_count - expected_count) / max(expected_count, 1)
            if difference > 0.30:
                return "fail"
            if difference > 0.10:
                has_warning = True
            continue

        expected_present = presence_expected.get(product_class)
        if expected_present is True and detected_count == 0:
            return "fail"
        if expected_present is False and detected_count > 0:
            has_warning = True

    return "warning" if has_warning else "pass"


def auto_answer_questions(
    questions: List[dict],
    detected_products: Dict[str, int]
) -> List[Answer]:
    """
    Auto-answer survey questions based on YOLO detection results.
    
    For each question with a product_class:
    - yes_no: Answer "Тийм" if product detected, "Үгүй" otherwise
    - number: Answer with the count of detected products
    """
    answers = []
    
    for q in questions:
        product_class = q.get("product_class")
        
        if not product_class:
            # No product class - skip auto-answering
            continue
        
        question_type = q.get("type", "yes_no")
        detected_count = detected_products.get(product_class, 0)
        
        if question_type == "yes_no":
            answer_value = "Тийм" if detected_count > 0 else "Үгүй"
        elif question_type == "number":
            answer_value = detected_count
        else:
            # For other types, provide detected status
            answer_value = f"Detected: {detected_count}"
        
        answers.append(Answer(
            question_id=q["_id"],
            question_text=q["text"],
            answer=answer_value,
            auto_answered=True,
        ))
    
    return answers


def parse_manual_answers(
    answers_json: Optional[str],
    questions_by_id: Dict[str, dict],
) -> List[Answer]:
    """Parse manual answers JSON submitted by the Flutter app."""
    if not answers_json:
        return []

    try:
        payload = json.loads(answers_json)
    except json.JSONDecodeError as exc:
        raise HTTPException(status_code=400, detail=f"answers_json is not valid JSON: {exc.msg}") from exc

    if not isinstance(payload, list):
        raise HTTPException(status_code=400, detail="answers_json must be a JSON array")

    manual_answers: List[Answer] = []
    for item in payload:
        if not isinstance(item, dict):
            raise HTTPException(status_code=400, detail="Each answer item must be an object")

        question_id = item.get("question_id")
        if not question_id or question_id not in questions_by_id:
            raise HTTPException(status_code=400, detail=f"Unknown question_id: {question_id}")

        manual_answers.append(
            Answer(
                question_id=question_id,
                question_text=item.get("question_text") or questions_by_id[question_id]["text"],
                answer=item.get("answer"),
                auto_answered=False,
            )
        )

    return manual_answers


@router.post("/submit", response_model=AuditSubmitResponse)
async def submit_audit(
    file: Optional[UploadFile] = File(None),
    photos: Optional[List[UploadFile]] = File(None),
    campaign_id: str = Form(...),
    tradeshop_id: str = Form(...),
    lat: Optional[float] = Form(None),
    lng: Optional[float] = Form(None),
    accuracy: Optional[float] = Form(None),
    notes: Optional[str] = Form(None),
    answers_json: Optional[str] = Form(None),
    current_auditor: dict = Depends(get_current_auditor)
):
    """
    Submit an audit with image.
    
    1. Saves uploaded image
    2. Runs YOLO detection
    3. Gets campaign's survey questions
    4. Auto-answers questions based on detections
    5. Saves everything to database
    6. Returns results
    """
    uploaded_files = photos or []
    if file is not None:
        uploaded_files = [file, *uploaded_files]

    if not uploaded_files:
        raise HTTPException(status_code=400, detail="At least one image is required")

    # Validate file types
    allowed_types = {"image/jpeg", "image/png", "image/bmp"}
    for upload in uploaded_files:
        if upload.content_type not in allowed_types:
            raise HTTPException(
                status_code=400,
                detail=f"File type {upload.content_type} not supported. Use JPEG, PNG, or BMP."
            )
    
    # Verify campaign exists and get survey_id
    campaigns_collection = get_campaigns_collection()
    campaign = await campaigns_collection.find_one({"_id": campaign_id})
    if not campaign:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    if not campaign.get("is_active", True):
        raise HTTPException(status_code=400, detail="Campaign is not active")
    
    survey_id = campaign.get("survey_id")
    if not survey_id:
        raise HTTPException(status_code=400, detail="Campaign has no survey assigned")
    
    # Verify tradeshop exists
    tradeshops_collection = get_tradeshops_collection()
    tradeshop = await tradeshops_collection.find_one({"_id": tradeshop_id})
    if not tradeshop:
        raise HTTPException(status_code=404, detail="Tradeshop not found")

    if tradeshop_id not in campaign.get("target_tradeshop_ids", []):
        raise HTTPException(status_code=400, detail="Tradeshop is not part of the selected campaign")

    if not current_auditor.get("is_admin", False):
        assigned_to_auditor = tradeshop.get("assigned_auditor_id") == current_auditor["_id"]
        in_same_group = bool(
            current_auditor.get("group_id")
            and tradeshop.get("group_id") == current_auditor.get("group_id")
        )
        if not assigned_to_auditor and not in_same_group:
            raise HTTPException(status_code=403, detail="This tradeshop is not assigned to the current auditor")
    
    # Save uploaded file
    upload_dir = Path(settings.UPLOAD_DIR)
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    saved_filenames: List[str] = []
    saved_full_paths: List[str] = []
    for index, upload in enumerate(uploaded_files, start=1):
        filename = f"{timestamp}_{current_auditor['_id']}_{index}_{upload.filename}"
        file_path = upload_dir / filename
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(upload.file, buffer)
        saved_filenames.append(filename)
        saved_full_paths.append(str(file_path))

    primary_photo_path = saved_full_paths[0]
    
    # Run YOLO detection
    detection_result = DetectionService.detect_from_file(primary_photo_path)
    
    detected_products: Dict[str, int] = {}
    detection_id = str(uuid.uuid4())
    
    if detection_result:
        detected_products = count_detections(detection_result.get("detections", []))
        
        # Save detection to database
        detection_doc = {
            "_id": detection_id,
            "image_path": primary_photo_path,
            "tradeshop_id": tradeshop_id,
            "auditor_id": current_auditor["_id"],
            "campaign_id": campaign_id,
            "detections": detection_result.get("detections", []),
            "total_products": detection_result.get("total_products", 0),
            "processing_time_ms": detection_result.get("processing_time_ms", 0),
            "timestamp": datetime.utcnow(),
        }
        
        detections_collection = get_detections_collection()
        await detections_collection.insert_one(detection_doc)
    else:
        # Model not loaded - still save the image info
        detection_doc = {
            "_id": detection_id,
            "image_path": primary_photo_path,
            "tradeshop_id": tradeshop_id,
            "auditor_id": current_auditor["_id"],
            "campaign_id": campaign_id,
            "detections": [],
            "total_products": 0,
            "processing_time_ms": 0,
            "message": "YOLO model not loaded",
            "timestamp": datetime.utcnow(),
        }
        
        detections_collection = get_detections_collection()
        await detections_collection.insert_one(detection_doc)
    
    # Get survey questions
    questions_collection = get_questions_collection()
    questions_cursor = questions_collection.find({"survey_id": survey_id}).sort("order", 1)
    questions = await questions_cursor.to_list(length=100)
    questions_by_id = {question["_id"]: question for question in questions}
    
    # Auto-answer questions
    auto_answers = auto_answer_questions(questions, detected_products)
    manual_answers = parse_manual_answers(answers_json, questions_by_id)

    answers_by_id: Dict[str, Answer] = {}
    for answer in auto_answers:
        answers_by_id[answer.question_id] = answer
    for answer in manual_answers:
        answers_by_id[answer.question_id] = answer

    saved_answers = [answers_by_id[question["_id"]] for question in questions if question["_id"] in answers_by_id]
    
    # Build location
    location = None
    if lat is not None and lng is not None:
        location = {"lat": lat, "lng": lng, "accuracy": accuracy}
    
    # Save audit response
    now = datetime.utcnow()
    audit_response_id = str(uuid.uuid4())
    
    audit_result = calculate_audit_result(questions, saved_answers, detected_products)

    audit_response_doc = {
        "_id": audit_response_id,
        "campaign_id": campaign_id,
        "tradeshop_id": tradeshop_id,
        "auditor_id": current_auditor["_id"],
        "survey_id": survey_id,
        "detection_id": detection_id,
        "answers": [answer.model_dump() for answer in saved_answers],
        "photos": saved_filenames,
        "location": location,
        "notes": notes,
        "status": "completed",
        "audit_result": audit_result,
        "submitted_at": now,
        "created_at": now,
    }
    
    audit_responses_collection = get_audit_responses_collection()
    await audit_responses_collection.insert_one(audit_response_doc)
    
    return AuditSubmitResponse(
        audit_response_id=audit_response_id,
        detection_id=detection_id,
        detected_products=detected_products,
        auto_answers=auto_answers,
        saved_answers=saved_answers,
        answer_count=len(saved_answers),
        photo_count=len(saved_filenames),
        status="completed",
        audit_result=audit_result,
        message=f"Audit submitted successfully. Detected {sum(detected_products.values())} products and saved {len(saved_answers)} answers.",
    )


@router.get("/responses", response_model=List[AuditResponseResponse])
async def list_audit_responses(
    request: Request,
    campaign_id: Optional[str] = None,
    tradeshop_id: Optional[str] = None,
    auditor_id: Optional[str] = None,
    skip: int = 0,
    limit: int = 50,
    _: dict = Depends(get_current_auditor)
):
    """List audit responses with optional filters."""
    base_url = str(request.base_url).rstrip("/")
    collection = get_audit_responses_collection()

    query = {}
    if campaign_id:
        query["campaign_id"] = campaign_id
    if tradeshop_id:
        query["tradeshop_id"] = tradeshop_id
    if auditor_id:
        query["auditor_id"] = auditor_id
    
    cursor = collection.find(query).skip(skip).limit(limit).sort("submitted_at", -1)
    responses = await cursor.to_list(length=limit)
    
    # Get related data
    campaigns = {}
    tradeshops = {}
    auditors = {}
    detections = {}
    
    campaigns_collection = get_campaigns_collection()
    tradeshops_collection = get_tradeshops_collection()
    from ..database import get_auditors_collection
    auditors_collection = get_auditors_collection()
    detections_collection = get_detections_collection()
    
    result = []
    for resp in responses:
        # Get campaign name
        camp_name = None
        if resp["campaign_id"] not in campaigns:
            camp = await campaigns_collection.find_one({"_id": resp["campaign_id"]})
            campaigns[resp["campaign_id"]] = camp["name"] if camp else None
        camp_name = campaigns[resp["campaign_id"]]
        
        # Get tradeshop name
        ts_name = None
        if resp["tradeshop_id"] not in tradeshops:
            ts = await tradeshops_collection.find_one({"_id": resp["tradeshop_id"]})
            tradeshops[resp["tradeshop_id"]] = ts["name"] if ts else None
        ts_name = tradeshops[resp["tradeshop_id"]]
        
        # Get auditor name
        aud_name = None
        if resp["auditor_id"] not in auditors:
            aud = await auditors_collection.find_one({"_id": resp["auditor_id"]})
            auditors[resp["auditor_id"]] = aud["name"] if aud else None
        aud_name = auditors[resp["auditor_id"]]
        
        # Get detection summary
        detection_summary = None
        detection_items = []
        detection_total = 0
        detection_processing_time_ms = 0.0
        if resp.get("detection_id"):
            if resp["detection_id"] not in detections:
                det = await detections_collection.find_one({"_id": resp["detection_id"]})
                if det:
                    detections[resp["detection_id"]] = {
                        "summary": count_detections(det.get("detections", [])),
                        "items": det.get("detections", []),
                        "total": det.get("total_products", 0),
                        "processing_time_ms": det.get("processing_time_ms", 0),
                    }
            detection_data = detections.get(resp["detection_id"]) or {}
            detection_summary = detection_data.get("summary")
            detection_items = detection_data.get("items", [])
            detection_total = detection_data.get("total", 0)
            detection_processing_time_ms = detection_data.get("processing_time_ms", 0)
        
        # Build answers
        answers = [Answer(**a) for a in resp.get("answers", [])]
        
        # Build location
        location = None
        if resp.get("location"):
            location = AuditLocation(**resp["location"])
        
        photos = resp.get("photos", [])
        result.append(AuditResponseResponse(
            id=resp["_id"],
            campaign_id=resp["campaign_id"],
            campaign_name=camp_name,
            tradeshop_id=resp["tradeshop_id"],
            tradeshop_name=ts_name,
            auditor_id=resp["auditor_id"],
            auditor_name=aud_name,
            survey_id=resp["survey_id"],
            detection_id=resp.get("detection_id"),
            detection_summary=detection_summary,
            detection_items=detection_items,
            detection_total=detection_total,
            detection_processing_time_ms=detection_processing_time_ms,
            answers=answers,
            photos=photos,
            photo_urls=build_photo_urls(photos, base_url),
            location=location,
            notes=resp.get("notes"),
            status=resp.get("status", "completed"),
            audit_result=resp.get("audit_result"),
            submitted_at=resp["submitted_at"],
            created_at=resp["created_at"],
        ))
    
    return result


@router.get("/responses/{response_id}", response_model=AuditResponseResponse)
async def get_audit_response(
    request: Request,
    response_id: str,
    _: dict = Depends(get_current_auditor)
):
    """Get a single audit response."""
    base_url = str(request.base_url).rstrip("/")
    collection = get_audit_responses_collection()
    resp = await collection.find_one({"_id": response_id})
    
    if not resp:
        raise HTTPException(status_code=404, detail="Audit response not found")
    
    # Get related data
    campaigns_collection = get_campaigns_collection()
    tradeshops_collection = get_tradeshops_collection()
    from ..database import get_auditors_collection
    auditors_collection = get_auditors_collection()
    detections_collection = get_detections_collection()
    
    camp = await campaigns_collection.find_one({"_id": resp["campaign_id"]})
    ts = await tradeshops_collection.find_one({"_id": resp["tradeshop_id"]})
    aud = await auditors_collection.find_one({"_id": resp["auditor_id"]})
    
    detection_summary = None
    detection_items = []
    detection_total = 0
    detection_processing_time_ms = 0.0
    if resp.get("detection_id"):
        det = await detections_collection.find_one({"_id": resp["detection_id"]})
        if det:
            detection_summary = count_detections(det.get("detections", []))
            detection_items = det.get("detections", [])
            detection_total = det.get("total_products", 0)
            detection_processing_time_ms = det.get("processing_time_ms", 0)
    
    answers = [Answer(**a) for a in resp.get("answers", [])]

    location = None
    if resp.get("location"):
        location = AuditLocation(**resp["location"])

    photos = resp.get("photos", [])
    return AuditResponseResponse(
        id=resp["_id"],
        campaign_id=resp["campaign_id"],
        campaign_name=camp["name"] if camp else None,
        tradeshop_id=resp["tradeshop_id"],
        tradeshop_name=ts["name"] if ts else None,
        auditor_id=resp["auditor_id"],
        auditor_name=aud["name"] if aud else None,
        survey_id=resp["survey_id"],
        detection_id=resp.get("detection_id"),
        detection_summary=detection_summary,
        detection_items=detection_items,
        detection_total=detection_total,
        detection_processing_time_ms=detection_processing_time_ms,
        answers=answers,
        photos=photos,
        photo_urls=build_photo_urls(photos, base_url),
        location=location,
        notes=resp.get("notes"),
        status=resp.get("status", "completed"),
        audit_result=resp.get("audit_result"),
        submitted_at=resp["submitted_at"],
        created_at=resp["created_at"],
    )
