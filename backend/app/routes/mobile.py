"""
Mobile routes - Flutter app focused endpoints for campaigns, surveys, and history.
"""

from typing import Dict, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query

from ..database import (
    get_audit_responses_collection,
    get_auditors_collection,
    get_campaigns_collection,
    get_categories_collection,
    get_groups_collection,
    get_question_groups_collection,
    get_questions_collection,
    get_surveys_collection,
    get_tradeshops_collection,
)
from ..dependencies import get_current_auditor
from ..models.audit_response import AuditResponseResponse, Answer, AuditLocation
from ..models.mobile import (
    MobileCampaignDetail,
    MobileCampaignSummary,
    MobileTradeshopSummary,
)
from ..models.question import QuestionResponse
from ..models.survey import SurveyGroupWithQuestions, SurveyWithQuestions
from .audit_submit import count_detections

router = APIRouter()


def can_access_tradeshop(auditor: dict, tradeshop: dict) -> bool:
    """Check whether the current auditor can access a tradeshop."""
    if auditor.get("is_admin", False):
        return True

    if tradeshop.get("assigned_auditor_id") == auditor["_id"]:
        return True

    group_id = auditor.get("group_id")
    return bool(group_id and tradeshop.get("group_id") == group_id)


async def get_accessible_tradeshops_map(current_auditor: dict) -> Dict[str, dict]:
    """Return accessible tradeshops keyed by ID."""
    collection = get_tradeshops_collection()
    if current_auditor.get("is_admin", False):
        shops = await collection.find({}).to_list(length=1000)
    else:
        query_parts = [{"assigned_auditor_id": current_auditor["_id"]}]
        if current_auditor.get("group_id"):
            query_parts.append({"group_id": current_auditor["group_id"]})
        shops = await collection.find({"$or": query_parts}).to_list(length=1000)
    return {shop["_id"]: shop for shop in shops}


async def build_mobile_tradeshop_summaries(
    tradeshop_docs: List[dict],
    current_auditor: dict,
    campaign_id: Optional[str] = None,
) -> List[MobileTradeshopSummary]:
    """Build mobile tradeshop summaries with completion state."""
    groups_collection = get_groups_collection()
    categories_collection = get_categories_collection()
    auditors_collection = get_auditors_collection()
    responses_collection = get_audit_responses_collection()

    group_cache: Dict[str, Optional[str]] = {}
    category_cache: Dict[str, Optional[str]] = {}
    auditor_cache: Dict[str, Optional[str]] = {}

    response_query = {"auditor_id": current_auditor["_id"], "status": "completed"}
    if campaign_id:
        response_query["campaign_id"] = campaign_id
    submitted_responses = await responses_collection.find(response_query).sort("submitted_at", -1).to_list(length=1000)
    latest_by_tradeshop: Dict[str, dict] = {}
    for response in submitted_responses:
        latest_by_tradeshop.setdefault(response["tradeshop_id"], response)

    summaries: List[MobileTradeshopSummary] = []
    for shop in tradeshop_docs:
        group_name = None
        if shop.get("group_id"):
            if shop["group_id"] not in group_cache:
                group = await groups_collection.find_one({"_id": shop["group_id"]})
                group_cache[shop["group_id"]] = group["name"] if group else None
            group_name = group_cache[shop["group_id"]]

        category_name = None
        if shop.get("category_id"):
            if shop["category_id"] not in category_cache:
                category = await categories_collection.find_one({"_id": shop["category_id"]})
                category_cache[shop["category_id"]] = category["name"] if category else None
            category_name = category_cache[shop["category_id"]]

        assigned_auditor_name = None
        if shop.get("assigned_auditor_id"):
            if shop["assigned_auditor_id"] not in auditor_cache:
                assigned = await auditors_collection.find_one({"_id": shop["assigned_auditor_id"]})
                auditor_cache[shop["assigned_auditor_id"]] = assigned["name"] if assigned else None
            assigned_auditor_name = auditor_cache[shop["assigned_auditor_id"]]

        latest_response = latest_by_tradeshop.get(shop["_id"])
        summaries.append(
            MobileTradeshopSummary(
                id=shop["_id"],
                name=shop["name"],
                address=shop.get("address"),
                location=shop.get("location"),
                group_id=shop.get("group_id"),
                group_name=group_name,
                category_id=shop.get("category_id"),
                category_name=category_name,
                assigned_auditor_id=shop.get("assigned_auditor_id"),
                assigned_auditor_name=assigned_auditor_name,
                latest_response_id=latest_response["_id"] if latest_response else None,
                latest_submitted_at=latest_response["submitted_at"] if latest_response else None,
                audit_status="completed" if latest_response else "pending",
            )
        )

    return summaries


async def build_survey_with_groups(survey_id: str) -> SurveyWithQuestions:
    """Build grouped survey response for mobile use."""
    surveys_collection = get_surveys_collection()
    groups_collection = get_question_groups_collection()
    questions_collection = get_questions_collection()

    survey = await surveys_collection.find_one({"_id": survey_id})
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")

    groups = await groups_collection.find({"survey_id": survey_id}).sort("order", 1).to_list(length=200)
    questions = await questions_collection.find({"survey_id": survey_id}).sort(
        [("group_id", 1), ("order", 1), ("created_at", 1)]
    ).to_list(length=500)

    questions_by_group: Dict[str, List[QuestionResponse]] = {}
    for question in questions:
        questions_by_group.setdefault(question["group_id"], []).append(
            QuestionResponse(
                id=question["_id"],
                survey_id=question["survey_id"],
                group_id=question["group_id"],
                text=question["text"],
                type=question["type"],
                options=question.get("options", []),
                required=question.get("required", True),
                order=question.get("order", 0),
                product_class=question.get("product_class"),
                detection_based=question.get("detection_based", False),
                created_at=question["created_at"],
            )
        )

    grouped = []
    for group in groups:
        grouped.append(
            SurveyGroupWithQuestions(
                id=group["_id"],
                survey_id=group["survey_id"],
                name=group["name"],
                description=group.get("description"),
                order=group.get("order", 0),
                question_count=len(questions_by_group.get(group["_id"], [])),
                created_at=group["created_at"],
                updated_at=group["updated_at"],
                questions=questions_by_group.get(group["_id"], []),
            )
        )

    return SurveyWithQuestions(
        id=survey["_id"],
        name=survey["name"],
        description=survey.get("description"),
        category_id=survey.get("category_id"),
        is_active=survey.get("is_active", True),
        question_count=len(questions),
        group_count=len(groups),
        created_at=survey["created_at"],
        updated_at=survey["updated_at"],
        groups=grouped,
    )


async def get_accessible_campaign_or_404(campaign_id: str, current_auditor: dict) -> tuple[dict, List[dict]]:
    """Fetch a campaign and its accessible tradeshops for the current auditor."""
    campaigns_collection = get_campaigns_collection()
    campaign = await campaigns_collection.find_one({"_id": campaign_id})
    if not campaign:
        raise HTTPException(status_code=404, detail="Campaign not found")

    accessible_shops = await get_accessible_tradeshops_map(current_auditor)
    target_ids = campaign.get("target_tradeshop_ids", [])
    target_shops = [accessible_shops[shop_id] for shop_id in target_ids if shop_id in accessible_shops]

    if not target_shops and not current_auditor.get("is_admin", False):
        raise HTTPException(status_code=403, detail="This campaign is not assigned to the current auditor")

    return campaign, target_shops


async def build_audit_response_payloads(responses: List[dict]) -> List[AuditResponseResponse]:
    """Build audit response payloads used by mobile history endpoints."""
    campaigns_collection = get_campaigns_collection()
    tradeshops_collection = get_tradeshops_collection()
    auditors_collection = get_auditors_collection()
    from ..database import get_detections_collection

    detections_collection = get_detections_collection()
    campaigns_cache: Dict[str, Optional[str]] = {}
    tradeshops_cache: Dict[str, Optional[str]] = {}
    auditors_cache: Dict[str, Optional[str]] = {}

    payloads: List[AuditResponseResponse] = []
    for response in responses:
        if response["campaign_id"] not in campaigns_cache:
            campaign = await campaigns_collection.find_one({"_id": response["campaign_id"]})
            campaigns_cache[response["campaign_id"]] = campaign["name"] if campaign else None
        if response["tradeshop_id"] not in tradeshops_cache:
            tradeshop = await tradeshops_collection.find_one({"_id": response["tradeshop_id"]})
            tradeshops_cache[response["tradeshop_id"]] = tradeshop["name"] if tradeshop else None
        if response["auditor_id"] not in auditors_cache:
            auditor = await auditors_collection.find_one({"_id": response["auditor_id"]})
            auditors_cache[response["auditor_id"]] = auditor["name"] if auditor else None

        detection_summary = None
        detection_items = []
        detection_total = 0
        detection_processing_time_ms = 0.0
        if response.get("detection_id"):
            detection = await detections_collection.find_one({"_id": response["detection_id"]})
            if detection:
                detection_summary = count_detections(detection.get("detections", []))
                detection_items = detection.get("detections", [])
                detection_total = detection.get("total_products", 0)
                detection_processing_time_ms = detection.get("processing_time_ms", 0)

        location = AuditLocation(**response["location"]) if response.get("location") else None
        answers = [Answer(**item) for item in response.get("answers", [])]

        payloads.append(
            AuditResponseResponse(
                id=response["_id"],
                campaign_id=response["campaign_id"],
                campaign_name=campaigns_cache[response["campaign_id"]],
                tradeshop_id=response["tradeshop_id"],
                tradeshop_name=tradeshops_cache[response["tradeshop_id"]],
                auditor_id=response["auditor_id"],
                auditor_name=auditors_cache[response["auditor_id"]],
                survey_id=response["survey_id"],
                detection_id=response.get("detection_id"),
                detection_summary=detection_summary,
                detection_items=detection_items,
                detection_total=detection_total,
                detection_processing_time_ms=detection_processing_time_ms,
                answers=answers,
                photos=response.get("photos", []),
                location=location,
                notes=response.get("notes"),
                status=response.get("status", "completed"),
                submitted_at=response["submitted_at"],
                created_at=response["created_at"],
            )
        )

    return payloads


@router.get("/campaigns", response_model=List[MobileCampaignSummary])
async def list_mobile_campaigns(
    include_inactive: bool = Query(False),
    current_auditor: dict = Depends(get_current_auditor),
):
    """List campaigns accessible to the current auditor."""
    campaigns_collection = get_campaigns_collection()
    surveys_collection = get_surveys_collection()
    responses_collection = get_audit_responses_collection()

    query = {}
    if not include_inactive:
        query["is_active"] = True

    campaigns = await campaigns_collection.find(query).sort("start_date", -1).to_list(length=200)
    accessible_shops = await get_accessible_tradeshops_map(current_auditor)

    items: List[MobileCampaignSummary] = []
    for campaign in campaigns:
        target_ids = [shop_id for shop_id in campaign.get("target_tradeshop_ids", []) if shop_id in accessible_shops]
        if not target_ids and not current_auditor.get("is_admin", False):
            continue

        survey_name = None
        if campaign.get("survey_id"):
            survey = await surveys_collection.find_one({"_id": campaign["survey_id"]})
            if survey:
                survey_name = survey["name"]

        completed_ids = await responses_collection.distinct(
            "tradeshop_id",
            {
                "campaign_id": campaign["_id"],
                "auditor_id": current_auditor["_id"],
                "status": "completed",
                "tradeshop_id": {"$in": target_ids},
            },
        )
        completed = len(completed_ids)
        total = len(target_ids)

        items.append(
            MobileCampaignSummary(
                id=campaign["_id"],
                name=campaign["name"],
                description=campaign.get("description"),
                start_date=campaign["start_date"],
                end_date=campaign["end_date"],
                survey_id=campaign.get("survey_id"),
                survey_name=survey_name,
                total_tradeshops=total,
                completed_tradeshops=completed,
                pending_tradeshops=max(total - completed, 0),
                progress_percent=round((completed / total * 100) if total else 0, 1),
            )
        )

    return items


@router.get("/campaigns/{campaign_id}", response_model=MobileCampaignDetail)
async def get_mobile_campaign_detail(
    campaign_id: str,
    current_auditor: dict = Depends(get_current_auditor),
):
    """Get one accessible campaign for Flutter screens."""
    campaign, target_shops = await get_accessible_campaign_or_404(campaign_id, current_auditor)
    surveys_collection = get_surveys_collection()
    groups_collection = get_question_groups_collection()
    questions_collection = get_questions_collection()

    survey_name = None
    question_group_count = 0
    question_count = 0
    if campaign.get("survey_id"):
        survey = await surveys_collection.find_one({"_id": campaign["survey_id"]})
        if survey:
            survey_name = survey["name"]
        question_group_count = await groups_collection.count_documents({"survey_id": campaign["survey_id"]})
        question_count = await questions_collection.count_documents({"survey_id": campaign["survey_id"]})

    tradeshops = await build_mobile_tradeshop_summaries(target_shops, current_auditor, campaign_id=campaign_id)
    completed = len([shop for shop in tradeshops if shop.audit_status == "completed"])
    total = len(tradeshops)

    return MobileCampaignDetail(
        id=campaign["_id"],
        name=campaign["name"],
        description=campaign.get("description"),
        start_date=campaign["start_date"],
        end_date=campaign["end_date"],
        survey_id=campaign.get("survey_id"),
        survey_name=survey_name,
        total_tradeshops=total,
        completed_tradeshops=completed,
        pending_tradeshops=max(total - completed, 0),
        progress_percent=round((completed / total * 100) if total else 0, 1),
        question_group_count=question_group_count,
        question_count=question_count,
        tradeshops=tradeshops,
    )


@router.get("/campaigns/{campaign_id}/survey", response_model=SurveyWithQuestions)
async def get_mobile_campaign_survey(
    campaign_id: str,
    current_auditor: dict = Depends(get_current_auditor),
):
    """Get grouped survey definition for the current campaign."""
    campaign, _ = await get_accessible_campaign_or_404(campaign_id, current_auditor)
    survey_id = campaign.get("survey_id")
    if not survey_id:
        raise HTTPException(status_code=400, detail="Campaign has no survey assigned")

    return await build_survey_with_groups(survey_id)


@router.get("/tradeshops", response_model=List[MobileTradeshopSummary])
async def list_mobile_tradeshops(
    campaign_id: Optional[str] = None,
    status: Optional[str] = Query(None, pattern="^(pending|completed)$"),
    current_auditor: dict = Depends(get_current_auditor),
):
    """List the current auditor's accessible tradeshops."""
    accessible_shops = await get_accessible_tradeshops_map(current_auditor)
    tradeshop_docs = list(accessible_shops.values())

    if campaign_id:
        campaign, target_shops = await get_accessible_campaign_or_404(campaign_id, current_auditor)
        _ = campaign
        tradeshop_docs = target_shops

    summaries = await build_mobile_tradeshop_summaries(tradeshop_docs, current_auditor, campaign_id=campaign_id)
    if status:
        summaries = [item for item in summaries if item.audit_status == status]
    return sorted(summaries, key=lambda item: (item.audit_status, item.name))


@router.get("/audits/my", response_model=List[AuditResponseResponse])
async def list_my_audits(
    campaign_id: Optional[str] = None,
    tradeshop_id: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    current_auditor: dict = Depends(get_current_auditor),
):
    """List the current auditor's submitted audits for Flutter history screens."""
    collection = get_audit_responses_collection()
    query = {"auditor_id": current_auditor["_id"]}
    if campaign_id:
        query["campaign_id"] = campaign_id
    if tradeshop_id:
        query["tradeshop_id"] = tradeshop_id

    responses = await collection.find(query).skip(skip).limit(limit).sort("submitted_at", -1).to_list(length=limit)
    return await build_audit_response_payloads(responses)
