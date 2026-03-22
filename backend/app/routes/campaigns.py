"""
Campaigns CRUD routes.
"""

from datetime import datetime
from typing import List, Optional
import uuid

from fastapi import APIRouter, HTTPException, Depends, Query, status

from ..models.campaign import (
    CampaignCreate,
    CampaignUpdate,
    CampaignResponse,
    CampaignStats,
)
from ..database import (
    get_campaigns_collection,
    get_surveys_collection,
    get_tradeshops_collection,
    get_audit_responses_collection,
)
from ..dependencies import get_admin_auditor

router = APIRouter()


@router.get("/", response_model=List[CampaignResponse])
async def list_campaigns(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    is_active: Optional[bool] = None,
    search: Optional[str] = None,
    _: dict = Depends(get_admin_auditor)
):
    """List all campaigns."""
    collection = get_campaigns_collection()
    
    query = {}
    if is_active is not None:
        query["is_active"] = is_active
    if search:
        query["name"] = {"$regex": search, "$options": "i"}
    
    cursor = collection.find(query).skip(skip).limit(limit).sort("created_at", -1)
    campaigns = await cursor.to_list(length=limit)
    
    result = []
    for camp in campaigns:
        survey_name = None
        if camp.get("survey_id"):
            survey = await get_surveys_collection().find_one({"_id": camp["survey_id"]})
            if survey:
                survey_name = survey["name"]
        
        total_tradeshops = len(camp.get("target_tradeshop_ids", []))
        completed = await get_audit_responses_collection().count_documents({
            "campaign_id": camp["_id"],
            "status": "completed"
        })
        
        progress = (completed / total_tradeshops * 100) if total_tradeshops > 0 else 0
        
        result.append(CampaignResponse(
            id=camp["_id"],
            name=camp["name"],
            description=camp.get("description"),
            start_date=camp["start_date"],
            end_date=camp["end_date"],
            survey_id=camp.get("survey_id"),
            survey_name=survey_name,
            target_tradeshop_ids=camp.get("target_tradeshop_ids", []),
            is_active=camp.get("is_active", True),
            total_tradeshops=total_tradeshops,
            completed_audits=completed,
            progress_percent=round(progress, 1),
            created_at=camp["created_at"],
            updated_at=camp["updated_at"],
        ))
    
    return result


@router.get("/{campaign_id}", response_model=CampaignResponse)
async def get_campaign(campaign_id: str, _: dict = Depends(get_admin_auditor)):
    """Get a single campaign."""
    collection = get_campaigns_collection()
    camp = await collection.find_one({"_id": campaign_id})
    
    if not camp:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    survey_name = None
    if camp.get("survey_id"):
        survey = await get_surveys_collection().find_one({"_id": camp["survey_id"]})
        if survey:
            survey_name = survey["name"]
    
    total_tradeshops = len(camp.get("target_tradeshop_ids", []))
    completed = await get_audit_responses_collection().count_documents({
        "campaign_id": camp["_id"],
        "status": "completed"
    })
    progress = (completed / total_tradeshops * 100) if total_tradeshops > 0 else 0
    
    return CampaignResponse(
        id=camp["_id"],
        name=camp["name"],
        description=camp.get("description"),
        start_date=camp["start_date"],
        end_date=camp["end_date"],
        survey_id=camp.get("survey_id"),
        survey_name=survey_name,
        target_tradeshop_ids=camp.get("target_tradeshop_ids", []),
        is_active=camp.get("is_active", True),
        total_tradeshops=total_tradeshops,
        completed_audits=completed,
        progress_percent=round(progress, 1),
        created_at=camp["created_at"],
        updated_at=camp["updated_at"],
    )


@router.get("/{campaign_id}/stats", response_model=CampaignStats)
async def get_campaign_stats(campaign_id: str, _: dict = Depends(get_admin_auditor)):
    """Get campaign statistics."""
    collection = get_campaigns_collection()
    camp = await collection.find_one({"_id": campaign_id})
    
    if not camp:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    responses_collection = get_audit_responses_collection()
    
    total_tradeshops = len(camp.get("target_tradeshop_ids", []))
    completed = await responses_collection.count_documents({
        "campaign_id": campaign_id,
        "status": "completed"
    })
    
    # TODO: Add pass/warning/fail counts based on YOLO results
    
    return CampaignStats(
        campaign_id=campaign_id,
        campaign_name=camp["name"],
        total_tradeshops=total_tradeshops,
        completed_audits=completed,
        pending_audits=total_tradeshops - completed,
        progress_percent=round((completed / total_tradeshops * 100) if total_tradeshops > 0 else 0, 1),
        pass_count=0,
        warning_count=0,
        fail_count=0,
    )


@router.post("/", response_model=CampaignResponse, status_code=status.HTTP_201_CREATED)
async def create_campaign(request: CampaignCreate, _: dict = Depends(get_admin_auditor)):
    """Create a new campaign."""
    collection = get_campaigns_collection()
    
    now = datetime.utcnow()
    campaign_id = str(uuid.uuid4())
    
    doc = {
        "_id": campaign_id,
        "name": request.name,
        "description": request.description,
        "start_date": request.start_date,
        "end_date": request.end_date,
        "survey_id": request.survey_id,
        "target_tradeshop_ids": request.target_tradeshop_ids,
        "is_active": request.is_active,
        "created_at": now,
        "updated_at": now,
    }
    
    await collection.insert_one(doc)
    
    return CampaignResponse(
        id=campaign_id,
        name=request.name,
        description=request.description,
        start_date=request.start_date,
        end_date=request.end_date,
        survey_id=request.survey_id,
        target_tradeshop_ids=request.target_tradeshop_ids,
        is_active=request.is_active,
        total_tradeshops=len(request.target_tradeshop_ids),
        completed_audits=0,
        progress_percent=0,
        created_at=now,
        updated_at=now,
    )


@router.put("/{campaign_id}", response_model=CampaignResponse)
async def update_campaign(
    campaign_id: str,
    request: CampaignUpdate,
    _: dict = Depends(get_admin_auditor)
):
    """Update a campaign."""
    collection = get_campaigns_collection()
    
    camp = await collection.find_one({"_id": campaign_id})
    if not camp:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    update_data = {"updated_at": datetime.utcnow()}
    update_data.update(request.model_dump(exclude_unset=True))
    
    await collection.update_one({"_id": campaign_id}, {"$set": update_data})
    
    return await get_campaign(campaign_id, _)


@router.delete("/{campaign_id}")
async def delete_campaign(campaign_id: str, _: dict = Depends(get_admin_auditor)):
    """Delete a campaign."""
    collection = get_campaigns_collection()
    result = await collection.delete_one({"_id": campaign_id})
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    return {"message": "Campaign deleted successfully"}
