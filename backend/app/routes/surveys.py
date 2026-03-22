"""
Surveys, question groups, and questions CRUD routes.
"""

from datetime import datetime
from typing import List, Optional
import uuid

from fastapi import APIRouter, HTTPException, Depends, Query, status

from ..models.survey import (
    SurveyCreate,
    SurveyUpdate,
    SurveyResponse,
    SurveyWithQuestions,
    SurveyGroupWithQuestions,
)
from ..models.question_group import (
    QuestionGroupCreate,
    QuestionGroupUpdate,
    QuestionGroupResponse,
)
from ..models.question import (
    QuestionCreate,
    QuestionUpdate,
    QuestionResponse,
    QuestionReorder,
    QuestionTypeDefinition,
    QUESTION_TYPE_DEFINITIONS,
)
from ..database import (
    get_surveys_collection,
    get_questions_collection,
    get_question_groups_collection,
)
from ..dependencies import get_admin_auditor

router = APIRouter()


def build_question_response(question: dict) -> QuestionResponse:
    """Convert a question document to a response model."""
    return QuestionResponse(
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


def build_group_response(group: dict, question_count: int = 0) -> QuestionGroupResponse:
    """Convert a question group document to a response model."""
    return QuestionGroupResponse(
        id=group["_id"],
        survey_id=group["survey_id"],
        name=group["name"],
        description=group.get("description"),
        order=group.get("order", 0),
        question_count=question_count,
        created_at=group["created_at"],
        updated_at=group["updated_at"],
    )


async def get_survey_or_404(survey_id: str) -> dict:
    """Fetch a survey or raise a 404 error."""
    survey = await get_surveys_collection().find_one({"_id": survey_id})
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")
    return survey


async def get_group_or_404(group_id: str) -> dict:
    """Fetch a question group or raise a 404 error."""
    group = await get_question_groups_collection().find_one({"_id": group_id})
    if not group:
        raise HTTPException(status_code=404, detail="Question group not found")
    return group


async def ensure_group_in_survey(group_id: str, survey_id: str) -> dict:
    """Ensure a group belongs to the expected survey."""
    group = await get_group_or_404(group_id)
    if group["survey_id"] != survey_id:
        raise HTTPException(status_code=400, detail="Question group does not belong to the survey")
    return group


async def compute_counts(survey_id: str) -> tuple[int, int]:
    """Return (question_count, group_count) for a survey."""
    questions_collection = get_questions_collection()
    groups_collection = get_question_groups_collection()
    question_count = await questions_collection.count_documents({"survey_id": survey_id})
    group_count = await groups_collection.count_documents({"survey_id": survey_id})
    return question_count, group_count


async def touch_survey(survey_id: str):
    """Update survey timestamp after nested edits."""
    await get_surveys_collection().update_one(
        {"_id": survey_id},
        {"$set": {"updated_at": datetime.utcnow()}},
    )


# ==================== QUESTION TYPES ====================

@router.get("/question-types", response_model=List[QuestionTypeDefinition])
async def list_question_types(_: dict = Depends(get_admin_auditor)):
    """Return the supported survey question types."""
    return QUESTION_TYPE_DEFINITIONS


# ==================== SURVEYS ====================

@router.get("/", response_model=List[SurveyResponse])
async def list_surveys(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    is_active: Optional[bool] = None,
    search: Optional[str] = None,
    _: dict = Depends(get_admin_auditor),
):
    """List all surveys."""
    collection = get_surveys_collection()

    query = {}
    if is_active is not None:
        query["is_active"] = is_active
    if search:
        query["name"] = {"$regex": search, "$options": "i"}

    cursor = collection.find(query).skip(skip).limit(limit).sort("created_at", -1)
    surveys = await cursor.to_list(length=limit)

    result = []
    for survey in surveys:
        question_count, group_count = await compute_counts(survey["_id"])
        result.append(
            SurveyResponse(
                id=survey["_id"],
                name=survey["name"],
                description=survey.get("description"),
                category_id=survey.get("category_id"),
                is_active=survey.get("is_active", True),
                question_count=question_count,
                group_count=group_count,
                created_at=survey["created_at"],
                updated_at=survey["updated_at"],
            )
        )

    return result


@router.get("/{survey_id}", response_model=SurveyWithQuestions)
async def get_survey(survey_id: str, _: dict = Depends(get_admin_auditor)):
    """Get a survey with grouped questions."""
    survey = await get_survey_or_404(survey_id)
    groups_collection = get_question_groups_collection()
    questions_collection = get_questions_collection()

    groups_cursor = groups_collection.find({"survey_id": survey_id}).sort("order", 1)
    groups = await groups_cursor.to_list(length=200)

    questions_cursor = questions_collection.find({"survey_id": survey_id}).sort(
        [("group_id", 1), ("order", 1), ("created_at", 1)]
    )
    questions = await questions_cursor.to_list(length=500)

    questions_by_group: dict[str, list[QuestionResponse]] = {}
    for question in questions:
        questions_by_group.setdefault(question["group_id"], []).append(build_question_response(question))

    grouped = [
        SurveyGroupWithQuestions(
            **build_group_response(group, len(questions_by_group.get(group["_id"], []))).model_dump(),
            questions=questions_by_group.get(group["_id"], []),
        )
        for group in groups
    ]
    question_count, group_count = await compute_counts(survey_id)

    return SurveyWithQuestions(
        id=survey["_id"],
        name=survey["name"],
        description=survey.get("description"),
        category_id=survey.get("category_id"),
        is_active=survey.get("is_active", True),
        question_count=question_count,
        group_count=group_count,
        created_at=survey["created_at"],
        updated_at=survey["updated_at"],
        groups=grouped,
    )


@router.post("/", response_model=SurveyResponse, status_code=status.HTTP_201_CREATED)
async def create_survey(request: SurveyCreate, _: dict = Depends(get_admin_auditor)):
    """Create a new survey."""
    collection = get_surveys_collection()

    now = datetime.utcnow()
    survey_id = str(uuid.uuid4())

    doc = {
        "_id": survey_id,
        "name": request.name,
        "description": request.description,
        "category_id": request.category_id,
        "is_active": request.is_active,
        "created_at": now,
        "updated_at": now,
    }

    await collection.insert_one(doc)

    return SurveyResponse(
        id=survey_id,
        name=request.name,
        description=request.description,
        category_id=request.category_id,
        is_active=request.is_active,
        question_count=0,
        group_count=0,
        created_at=now,
        updated_at=now,
    )


@router.put("/{survey_id}", response_model=SurveyResponse)
async def update_survey(
    survey_id: str,
    request: SurveyUpdate,
    _: dict = Depends(get_admin_auditor),
):
    """Update a survey."""
    collection = get_surveys_collection()

    await get_survey_or_404(survey_id)

    update_data = {"updated_at": datetime.utcnow()}
    update_data.update(request.model_dump(exclude_unset=True))

    await collection.update_one({"_id": survey_id}, {"$set": update_data})

    survey = await collection.find_one({"_id": survey_id})
    question_count, group_count = await compute_counts(survey_id)
    return SurveyResponse(
        id=survey["_id"],
        name=survey["name"],
        description=survey.get("description"),
        category_id=survey.get("category_id"),
        is_active=survey.get("is_active", True),
        question_count=question_count,
        group_count=group_count,
        created_at=survey["created_at"],
        updated_at=survey["updated_at"],
    )


@router.delete("/{survey_id}")
async def delete_survey(survey_id: str, _: dict = Depends(get_admin_auditor)):
    """Delete a survey and all nested groups/questions."""
    surveys_collection = get_surveys_collection()
    groups_collection = get_question_groups_collection()
    questions_collection = get_questions_collection()

    result = await surveys_collection.delete_one({"_id": survey_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Survey not found")

    await groups_collection.delete_many({"survey_id": survey_id})
    await questions_collection.delete_many({"survey_id": survey_id})

    return {"message": "Survey and its nested groups/questions deleted successfully"}


# ==================== QUESTION GROUPS ====================

@router.post("/{survey_id}/groups", response_model=QuestionGroupResponse, status_code=status.HTTP_201_CREATED)
async def create_question_group(
    survey_id: str,
    request: QuestionGroupCreate,
    _: dict = Depends(get_admin_auditor),
):
    """Create a question group inside a survey."""
    if request.survey_id != survey_id:
        raise HTTPException(status_code=400, detail="survey_id mismatch")

    await get_survey_or_404(survey_id)
    groups_collection = get_question_groups_collection()

    last_group = await groups_collection.find_one({"survey_id": survey_id}, sort=[("order", -1)])
    next_order = (last_group.get("order", 0) + 1) if last_group else 1

    now = datetime.utcnow()
    group_id = str(uuid.uuid4())
    doc = {
        "_id": group_id,
        "survey_id": survey_id,
        "name": request.name,
        "description": request.description,
        "order": request.order if request.order > 0 else next_order,
        "created_at": now,
        "updated_at": now,
    }
    await groups_collection.insert_one(doc)
    await touch_survey(survey_id)
    return build_group_response(doc)


@router.put("/groups/{group_id}", response_model=QuestionGroupResponse)
async def update_question_group(
    group_id: str,
    request: QuestionGroupUpdate,
    _: dict = Depends(get_admin_auditor),
):
    """Update a question group."""
    groups_collection = get_question_groups_collection()
    questions_collection = get_questions_collection()

    group = await get_group_or_404(group_id)
    update_data = {"updated_at": datetime.utcnow()}
    if request.name is not None:
        update_data["name"] = request.name
    if request.description is not None:
        update_data["description"] = request.description
    if request.order is not None:
        update_data["order"] = request.order

    await groups_collection.update_one({"_id": group_id}, {"$set": update_data})
    await touch_survey(group["survey_id"])

    updated = await groups_collection.find_one({"_id": group_id})
    question_count = await questions_collection.count_documents({"group_id": group_id})
    return build_group_response(updated, question_count)


@router.delete("/groups/{group_id}")
async def delete_question_group(group_id: str, _: dict = Depends(get_admin_auditor)):
    """Delete a question group and its questions."""
    groups_collection = get_question_groups_collection()
    questions_collection = get_questions_collection()

    group = await get_group_or_404(group_id)
    await groups_collection.delete_one({"_id": group_id})
    await questions_collection.delete_many({"group_id": group_id})
    await touch_survey(group["survey_id"])
    return {"message": "Question group deleted successfully"}


@router.put("/{survey_id}/groups/reorder")
async def reorder_question_groups(
    survey_id: str,
    request: QuestionReorder,
    _: dict = Depends(get_admin_auditor),
):
    """Reorder question groups inside a survey."""
    await get_survey_or_404(survey_id)
    groups_collection = get_question_groups_collection()

    groups = await groups_collection.find({"survey_id": survey_id}).to_list(length=500)
    existing_ids = {group["_id"] for group in groups}
    if set(request.question_ids) != existing_ids:
        raise HTTPException(status_code=400, detail="Group IDs do not match the survey's groups")

    for index, group_id in enumerate(request.question_ids, start=1):
        await groups_collection.update_one(
            {"_id": group_id},
            {"$set": {"order": index, "updated_at": datetime.utcnow()}},
        )

    await touch_survey(survey_id)
    return {"message": "Question groups reordered successfully"}


# ==================== QUESTIONS ====================

@router.post("/{survey_id}/questions", response_model=QuestionResponse, status_code=status.HTTP_201_CREATED)
async def create_question(
    survey_id: str,
    request: QuestionCreate,
    _: dict = Depends(get_admin_auditor),
):
    """Add a question to a survey."""
    if request.survey_id != survey_id:
        raise HTTPException(status_code=400, detail="survey_id mismatch")

    await get_survey_or_404(survey_id)
    await ensure_group_in_survey(request.group_id, survey_id)

    questions_collection = get_questions_collection()
    max_order_q = await questions_collection.find_one(
        {"survey_id": survey_id, "group_id": request.group_id},
        sort=[("order", -1)],
    )
    next_order = (max_order_q.get("order", 0) + 1) if max_order_q else 1

    now = datetime.utcnow()
    question_id = str(uuid.uuid4())
    doc = {
        "_id": question_id,
        "survey_id": survey_id,
        "group_id": request.group_id,
        "text": request.text,
        "type": request.type,
        "options": request.options,
        "required": request.required,
        "order": request.order if request.order > 0 else next_order,
        "product_class": request.product_class,
        "detection_based": request.detection_based,
        "created_at": now,
    }

    await questions_collection.insert_one(doc)
    await touch_survey(survey_id)
    return build_question_response(doc)


@router.post("/{survey_id}/groups/{group_id}/questions", response_model=QuestionResponse, status_code=status.HTTP_201_CREATED)
async def create_group_question(
    survey_id: str,
    group_id: str,
    request: QuestionCreate,
    _: dict = Depends(get_admin_auditor),
):
    """Create a question within a specific group."""
    if request.group_id != group_id:
        raise HTTPException(status_code=400, detail="group_id mismatch")
    return await create_question(survey_id, request, _)


@router.put("/questions/{question_id}", response_model=QuestionResponse)
async def update_question(
    question_id: str,
    request: QuestionUpdate,
    _: dict = Depends(get_admin_auditor),
):
    """Update a question."""
    questions_collection = get_questions_collection()
    question = await questions_collection.find_one({"_id": question_id})
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    update_data = request.model_dump(exclude_unset=True)

    if "group_id" in update_data:
        await ensure_group_in_survey(update_data["group_id"], question["survey_id"])

    merged = {**question, **update_data}
    validated = QuestionCreate(
        survey_id=merged["survey_id"],
        group_id=merged["group_id"],
        text=merged["text"],
        type=merged["type"],
        options=merged.get("options", []),
        required=merged.get("required", True),
        order=merged.get("order", 0),
        product_class=merged.get("product_class"),
        detection_based=merged.get("detection_based", False),
    )

    await questions_collection.update_one(
        {"_id": question_id},
        {
            "$set": {
                "text": validated.text,
                "type": validated.type,
                "options": validated.options,
                "required": validated.required,
                "order": validated.order,
                "group_id": validated.group_id,
                "product_class": validated.product_class,
                "detection_based": validated.detection_based,
            }
        },
    )

    await touch_survey(question["survey_id"])
    updated = await questions_collection.find_one({"_id": question_id})
    return build_question_response(updated)


@router.delete("/questions/{question_id}")
async def delete_question(question_id: str, _: dict = Depends(get_admin_auditor)):
    """Delete a question."""
    questions_collection = get_questions_collection()
    question = await questions_collection.find_one({"_id": question_id})
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    await questions_collection.delete_one({"_id": question_id})
    await touch_survey(question["survey_id"])
    return {"message": "Question deleted successfully"}


@router.put("/{survey_id}/questions/reorder")
async def reorder_questions(
    survey_id: str,
    request: QuestionReorder,
    _: dict = Depends(get_admin_auditor),
):
    """Reorder questions across a survey."""
    await get_survey_or_404(survey_id)
    questions_collection = get_questions_collection()

    questions = await questions_collection.find({"survey_id": survey_id}).to_list(length=1000)
    existing_ids = {question["_id"] for question in questions}
    if set(request.question_ids) != existing_ids:
        raise HTTPException(status_code=400, detail="Question IDs do not match the survey's questions")

    group_offsets: dict[str, int] = {}
    for question_id in request.question_ids:
        question = next(item for item in questions if item["_id"] == question_id)
        group_id = question["group_id"]
        group_offsets[group_id] = group_offsets.get(group_id, 0) + 1
        await questions_collection.update_one(
            {"_id": question_id},
            {"$set": {"order": group_offsets[group_id]}},
        )

    await touch_survey(survey_id)
    return {"message": "Questions reordered successfully"}
