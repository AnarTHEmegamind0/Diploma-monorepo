"""
Tradeshops CRUD routes.
"""

from datetime import datetime
from typing import List, Optional
import uuid

from fastapi import APIRouter, HTTPException, Depends, Query, status

from ..models.tradeshop import (
    TradeshopCreate,
    TradeshopUpdate,
    TradeshopResponse,
)
from ..database import (
    get_tradeshops_collection,
    get_categories_collection,
    get_auditors_collection,
    get_groups_collection,
)
from ..dependencies import get_admin_auditor

router = APIRouter()


@router.get("/", response_model=List[TradeshopResponse])
async def list_tradeshops(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    category_id: Optional[str] = None,
    group_id: Optional[str] = None,
    assigned_auditor_id: Optional[str] = None,
    is_active: Optional[bool] = None,
    search: Optional[str] = None,
    _: dict = Depends(get_admin_auditor)
):
    """List all tradeshops with optional filters."""
    collection = get_tradeshops_collection()
    
    query = {}
    if category_id:
        query["category_id"] = category_id
    if group_id:
        query["group_id"] = group_id
    if assigned_auditor_id:
        query["assigned_auditor_id"] = assigned_auditor_id
    if is_active is not None:
        query["is_active"] = is_active
    if search:
        query["$or"] = [
            {"name": {"$regex": search, "$options": "i"}},
            {"address": {"$regex": search, "$options": "i"}},
        ]
    
    cursor = collection.find(query).skip(skip).limit(limit).sort("created_at", -1)
    tradeshops = await cursor.to_list(length=limit)
    
    # Get related data
    categories_collection = get_categories_collection()
    auditors_collection = get_auditors_collection()
    groups_collection = get_groups_collection()
    
    result = []
    for ts in tradeshops:
        category_name = None
        if ts.get("category_id"):
            cat = await categories_collection.find_one({"_id": ts["category_id"]})
            if cat:
                category_name = cat["name"]

        group_name = None
        if ts.get("group_id"):
            group = await groups_collection.find_one({"_id": ts["group_id"]})
            if group:
                group_name = group["name"]
        
        auditor_name = None
        if ts.get("assigned_auditor_id"):
            aud = await auditors_collection.find_one({"_id": ts["assigned_auditor_id"]})
            if aud:
                auditor_name = aud["name"]
        
        result.append(TradeshopResponse(
            id=ts["_id"],
            name=ts["name"],
            address=ts.get("address"),
            location=ts.get("location"),
            group_id=ts.get("group_id"),
            group_name=group_name,
            category_id=ts.get("category_id"),
            category_name=category_name,
            phone=ts.get("phone"),
            assigned_auditor_id=ts.get("assigned_auditor_id"),
            assigned_auditor_name=auditor_name,
            is_active=ts.get("is_active", True),
            created_at=ts["created_at"],
            updated_at=ts["updated_at"],
        ))
    
    return result


@router.get("/{tradeshop_id}", response_model=TradeshopResponse)
async def get_tradeshop(tradeshop_id: str, _: dict = Depends(get_admin_auditor)):
    """Get a single tradeshop by ID."""
    collection = get_tradeshops_collection()
    ts = await collection.find_one({"_id": tradeshop_id})
    
    if not ts:
        raise HTTPException(status_code=404, detail="Tradeshop not found")
    
    category_name = None
    if ts.get("category_id"):
        cat = await get_categories_collection().find_one({"_id": ts["category_id"]})
        if cat:
            category_name = cat["name"]

    group_name = None
    if ts.get("group_id"):
        group = await get_groups_collection().find_one({"_id": ts["group_id"]})
        if group:
            group_name = group["name"]
    
    auditor_name = None
    if ts.get("assigned_auditor_id"):
        aud = await get_auditors_collection().find_one({"_id": ts["assigned_auditor_id"]})
        if aud:
            auditor_name = aud["name"]
    
    return TradeshopResponse(
        id=ts["_id"],
        name=ts["name"],
        address=ts.get("address"),
        location=ts.get("location"),
        group_id=ts.get("group_id"),
        group_name=group_name,
        category_id=ts.get("category_id"),
        category_name=category_name,
        phone=ts.get("phone"),
        assigned_auditor_id=ts.get("assigned_auditor_id"),
        assigned_auditor_name=auditor_name,
        is_active=ts.get("is_active", True),
        created_at=ts["created_at"],
        updated_at=ts["updated_at"],
    )


@router.post("/", response_model=TradeshopResponse, status_code=status.HTTP_201_CREATED)
async def create_tradeshop(request: TradeshopCreate, _: dict = Depends(get_admin_auditor)):
    """Create a new tradeshop."""
    collection = get_tradeshops_collection()
    
    now = datetime.utcnow()
    tradeshop_id = str(uuid.uuid4())
    
    location_dict = None
    if request.location:
        location_dict = {"lat": request.location.lat, "lng": request.location.lng}
    
    doc = {
        "_id": tradeshop_id,
        "name": request.name,
        "address": request.address,
        "location": location_dict,
        "group_id": request.group_id,
        "category_id": request.category_id,
        "phone": request.phone,
        "assigned_auditor_id": request.assigned_auditor_id,
        "is_active": request.is_active,
        "created_at": now,
        "updated_at": now,
    }
    
    await collection.insert_one(doc)
    
    return TradeshopResponse(
        id=tradeshop_id,
        name=request.name,
        address=request.address,
        location=request.location,
        group_id=request.group_id,
        category_id=request.category_id,
        phone=request.phone,
        assigned_auditor_id=request.assigned_auditor_id,
        is_active=request.is_active,
        created_at=now,
        updated_at=now,
    )


@router.put("/{tradeshop_id}", response_model=TradeshopResponse)
async def update_tradeshop(
    tradeshop_id: str,
    request: TradeshopUpdate,
    _: dict = Depends(get_admin_auditor)
):
    """Update a tradeshop."""
    collection = get_tradeshops_collection()
    
    ts = await collection.find_one({"_id": tradeshop_id})
    if not ts:
        raise HTTPException(status_code=404, detail="Tradeshop not found")
    
    update_data = {"updated_at": datetime.utcnow()}
    payload = request.model_dump(exclude_unset=True)
    if "location" in payload:
        location = payload.pop("location")
        payload["location"] = {"lat": location["lat"], "lng": location["lng"]} if location else None
    update_data.update(payload)
    
    await collection.update_one({"_id": tradeshop_id}, {"$set": update_data})
    
    return await get_tradeshop(tradeshop_id, _)


@router.delete("/{tradeshop_id}")
async def delete_tradeshop(tradeshop_id: str, _: dict = Depends(get_admin_auditor)):
    """Delete a tradeshop."""
    collection = get_tradeshops_collection()
    result = await collection.delete_one({"_id": tradeshop_id})
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Tradeshop not found")
    
    return {"message": "Tradeshop deleted successfully"}
