"""
Auditors CRUD routes.
"""

from datetime import datetime
from typing import List, Optional
import uuid

from fastapi import APIRouter, HTTPException, Depends, Query, status

from ..models.auditor import (
    AuditorCreate,
    AuditorUpdate,
    AuditorResponse,
)
from ..database import get_auditors_collection, get_groups_collection
from ..services.auth_service import hash_password
from ..dependencies import get_admin_auditor

router = APIRouter()


@router.get("/", response_model=List[AuditorResponse])
async def list_auditors(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    group_id: Optional[str] = None,
    is_active: Optional[bool] = None,
    search: Optional[str] = None,
    _: dict = Depends(get_admin_auditor)
):
    """
    List all auditors with optional filters.
    """
    collection = get_auditors_collection()
    groups_collection = get_groups_collection()
    
    # Build query
    query = {}
    if group_id:
        query["group_id"] = group_id
    if is_active is not None:
        query["is_active"] = is_active
    if search:
        query["$or"] = [
            {"name": {"$regex": search, "$options": "i"}},
            {"phone": {"$regex": search, "$options": "i"}},
            {"email": {"$regex": search, "$options": "i"}},
        ]
    
    cursor = collection.find(query).skip(skip).limit(limit).sort("created_at", -1)
    auditors = await cursor.to_list(length=limit)
    
    # Get all group names
    group_ids = [a.get("group_id") for a in auditors if a.get("group_id")]
    groups = {}
    if group_ids:
        groups_cursor = groups_collection.find({"_id": {"$in": group_ids}})
        async for group in groups_cursor:
            groups[group["_id"]] = group["name"]
    
    # Build response
    result = []
    for auditor in auditors:
        result.append(AuditorResponse(
            id=auditor["_id"],
            name=auditor["name"],
            phone=auditor["phone"],
            email=auditor.get("email"),
            group_id=auditor.get("group_id"),
            group_name=groups.get(auditor.get("group_id")),
            is_active=auditor.get("is_active", True),
            is_admin=auditor.get("is_admin", False),
            created_at=auditor["created_at"],
            updated_at=auditor["updated_at"],
        ))
    
    return result


@router.get("/{auditor_id}", response_model=AuditorResponse)
async def get_auditor(
    auditor_id: str,
    _: dict = Depends(get_admin_auditor)
):
    """
    Get a single auditor by ID.
    """
    collection = get_auditors_collection()
    auditor = await collection.find_one({"_id": auditor_id})
    
    if not auditor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Auditor not found",
        )
    
    # Get group name
    group_name = None
    if auditor.get("group_id"):
        groups_collection = get_groups_collection()
        group = await groups_collection.find_one({"_id": auditor["group_id"]})
        if group:
            group_name = group["name"]
    
    return AuditorResponse(
        id=auditor["_id"],
        name=auditor["name"],
        phone=auditor["phone"],
        email=auditor.get("email"),
        group_id=auditor.get("group_id"),
        group_name=group_name,
        is_active=auditor.get("is_active", True),
        is_admin=auditor.get("is_admin", False),
        created_at=auditor["created_at"],
        updated_at=auditor["updated_at"],
    )


@router.post("/", response_model=AuditorResponse, status_code=status.HTTP_201_CREATED)
async def create_auditor(
    request: AuditorCreate,
    _: dict = Depends(get_admin_auditor)
):
    """
    Create a new auditor.
    """
    collection = get_auditors_collection()
    
    # Check if phone already exists
    existing = await collection.find_one({"phone": request.phone})
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered",
        )
    
    now = datetime.utcnow()
    auditor_id = str(uuid.uuid4())
    
    auditor_doc = {
        "_id": auditor_id,
        "name": request.name,
        "phone": request.phone,
        "email": request.email,
        "group_id": request.group_id,
        "is_active": request.is_active,
        "is_admin": False,
        "password_hash": hash_password(request.password),
        "created_at": now,
        "updated_at": now,
    }
    
    await collection.insert_one(auditor_doc)
    
    # Get group name
    group_name = None
    if request.group_id:
        groups_collection = get_groups_collection()
        group = await groups_collection.find_one({"_id": request.group_id})
        if group:
            group_name = group["name"]
    
    return AuditorResponse(
        id=auditor_id,
        name=request.name,
        phone=request.phone,
        email=request.email,
        group_id=request.group_id,
        group_name=group_name,
        is_active=request.is_active,
        is_admin=False,
        created_at=now,
        updated_at=now,
    )


@router.put("/{auditor_id}", response_model=AuditorResponse)
async def update_auditor(
    auditor_id: str,
    request: AuditorUpdate,
    _: dict = Depends(get_admin_auditor)
):
    """
    Update an auditor.
    """
    collection = get_auditors_collection()
    
    auditor = await collection.find_one({"_id": auditor_id})
    if not auditor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Auditor not found",
        )
    
    # Build update
    update_data = {"updated_at": datetime.utcnow()}
    payload = request.model_dump(exclude_unset=True)

    if "phone" in payload:
        # Check if new phone already exists
        existing = await collection.find_one({
            "phone": payload["phone"],
            "_id": {"$ne": auditor_id}
        })
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Phone number already registered",
            )
        update_data["phone"] = payload.pop("phone")

    if "password" in payload:
        update_data["password_hash"] = hash_password(payload.pop("password"))

    update_data.update(payload)
    
    await collection.update_one(
        {"_id": auditor_id},
        {"$set": update_data}
    )
    
    # Get updated auditor
    auditor = await collection.find_one({"_id": auditor_id})
    
    # Get group name
    group_name = None
    if auditor.get("group_id"):
        groups_collection = get_groups_collection()
        group = await groups_collection.find_one({"_id": auditor["group_id"]})
        if group:
            group_name = group["name"]
    
    return AuditorResponse(
        id=auditor["_id"],
        name=auditor["name"],
        phone=auditor["phone"],
        email=auditor.get("email"),
        group_id=auditor.get("group_id"),
        group_name=group_name,
        is_active=auditor.get("is_active", True),
        is_admin=auditor.get("is_admin", False),
        created_at=auditor["created_at"],
        updated_at=auditor["updated_at"],
    )


@router.delete("/{auditor_id}")
async def delete_auditor(
    auditor_id: str,
    _: dict = Depends(get_admin_auditor)
):
    """
    Delete an auditor.
    """
    collection = get_auditors_collection()
    
    result = await collection.delete_one({"_id": auditor_id})
    
    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Auditor not found",
        )
    
    return {"message": "Auditor deleted successfully"}
