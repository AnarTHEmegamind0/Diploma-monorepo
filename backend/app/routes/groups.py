"""
Groups CRUD routes.
"""

from datetime import datetime
from typing import List, Optional
import uuid

from fastapi import APIRouter, HTTPException, Depends, Query, status

from ..models.group import (
    GroupCreate,
    GroupUpdate,
    GroupResponse,
)
from ..database import get_groups_collection, get_auditors_collection, get_tradeshops_collection
from ..dependencies import get_admin_auditor

router = APIRouter()


@router.get("/", response_model=List[GroupResponse])
async def list_groups(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    search: Optional[str] = None,
    _: dict = Depends(get_admin_auditor)
):
    """
    List all groups.
    """
    collection = get_groups_collection()
    auditors_collection = get_auditors_collection()
    tradeshops_collection = get_tradeshops_collection()
    
    # Build query
    query = {}
    if search:
        query["$or"] = [
            {"name": {"$regex": search, "$options": "i"}},
            {"description": {"$regex": search, "$options": "i"}},
        ]
    
    cursor = collection.find(query).skip(skip).limit(limit).sort("created_at", -1)
    groups = await cursor.to_list(length=limit)
    
    # Get auditor counts per group
    result = []
    for group in groups:
        auditor_count = await auditors_collection.count_documents({"group_id": group["_id"]})
        tradeshop_count = await tradeshops_collection.count_documents({"group_id": group["_id"]})
        result.append(GroupResponse(
            id=group["_id"],
            name=group["name"],
            description=group.get("description"),
            auditor_count=auditor_count,
            tradeshop_count=tradeshop_count,
            created_at=group["created_at"],
        ))
    
    return result


@router.get("/{group_id}", response_model=GroupResponse)
async def get_group(
    group_id: str,
    _: dict = Depends(get_admin_auditor)
):
    """
    Get a single group by ID.
    """
    collection = get_groups_collection()
    auditors_collection = get_auditors_collection()
    tradeshops_collection = get_tradeshops_collection()
    
    group = await collection.find_one({"_id": group_id})
    
    if not group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Group not found",
        )
    
    auditor_count = await auditors_collection.count_documents({"group_id": group_id})
    tradeshop_count = await tradeshops_collection.count_documents({"group_id": group_id})
    
    return GroupResponse(
        id=group["_id"],
        name=group["name"],
        description=group.get("description"),
        auditor_count=auditor_count,
        tradeshop_count=tradeshop_count,
        created_at=group["created_at"],
    )


@router.post("/", response_model=GroupResponse, status_code=status.HTTP_201_CREATED)
async def create_group(
    request: GroupCreate,
    _: dict = Depends(get_admin_auditor)
):
    """
    Create a new group.
    """
    collection = get_groups_collection()
    
    # Check if name already exists
    existing = await collection.find_one({"name": request.name})
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Group name already exists",
        )
    
    now = datetime.utcnow()
    group_id = str(uuid.uuid4())
    
    group_doc = {
        "_id": group_id,
        "name": request.name,
        "description": request.description,
        "created_at": now,
    }
    
    await collection.insert_one(group_doc)
    
    return GroupResponse(
        id=group_id,
        name=request.name,
        description=request.description,
        auditor_count=0,
        created_at=now,
    )


@router.put("/{group_id}", response_model=GroupResponse)
async def update_group(
    group_id: str,
    request: GroupUpdate,
    _: dict = Depends(get_admin_auditor)
):
    """
    Update a group.
    """
    collection = get_groups_collection()
    auditors_collection = get_auditors_collection()
    tradeshops_collection = get_tradeshops_collection()
    
    group = await collection.find_one({"_id": group_id})
    if not group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Group not found",
        )
    
    # Build update
    update_data = {}
    
    if request.name is not None:
        # Check if new name already exists
        existing = await collection.find_one({
            "name": request.name,
            "_id": {"$ne": group_id}
        })
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Group name already exists",
            )
        update_data["name"] = request.name
    
    if request.description is not None:
        update_data["description"] = request.description
    
    if update_data:
        await collection.update_one(
            {"_id": group_id},
            {"$set": update_data}
        )
    
    # Get updated group
    group = await collection.find_one({"_id": group_id})
    auditor_count = await auditors_collection.count_documents({"group_id": group_id})
    tradeshop_count = await tradeshops_collection.count_documents({"group_id": group_id})
    
    return GroupResponse(
        id=group["_id"],
        name=group["name"],
        description=group.get("description"),
        auditor_count=auditor_count,
        tradeshop_count=tradeshop_count,
        created_at=group["created_at"],
    )


@router.delete("/{group_id}")
async def delete_group(
    group_id: str,
    _: dict = Depends(get_admin_auditor)
):
    """
    Delete a group.
    """
    collection = get_groups_collection()
    auditors_collection = get_auditors_collection()
    tradeshops_collection = get_tradeshops_collection()
    
    # Check if group has auditors
    auditor_count = await auditors_collection.count_documents({"group_id": group_id})
    if auditor_count > 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot delete group with {auditor_count} auditors. Remove auditors first.",
        )
    
    tradeshop_count = await tradeshops_collection.count_documents({"group_id": group_id})
    if tradeshop_count > 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot delete group with {tradeshop_count} tradeshops. Reassign tradeshops first.",
        )

    result = await collection.delete_one({"_id": group_id})
    
    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Group not found",
        )
    
    return {"message": "Group deleted successfully"}
