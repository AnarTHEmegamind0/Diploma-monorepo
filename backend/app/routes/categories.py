"""
Categories CRUD routes.
"""

from datetime import datetime
from typing import List, Optional
import uuid

from fastapi import APIRouter, HTTPException, Depends, Query, status

from ..models.category import (
    CategoryCreate,
    CategoryUpdate,
    CategoryResponse,
    CategoryType,
)
from ..database import get_categories_collection, get_tradeshops_collection
from ..dependencies import get_admin_auditor

router = APIRouter()


@router.get("/", response_model=List[CategoryResponse])
async def list_categories(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    type: Optional[CategoryType] = None,
    search: Optional[str] = None,
    _: dict = Depends(get_admin_auditor)
):
    """List all categories."""
    collection = get_categories_collection()
    
    query = {}
    if type:
        query["type"] = type
    if search:
        query["name"] = {"$regex": search, "$options": "i"}
    
    cursor = collection.find(query).skip(skip).limit(limit).sort("created_at", -1)
    categories = await cursor.to_list(length=limit)
    
    result = []
    for cat in categories:
        # Count items using this category
        if cat["type"] == "tradeshop":
            item_count = await get_tradeshops_collection().count_documents({"category_id": cat["_id"]})
        else:
            item_count = 0  # Product count would go here
        
        result.append(CategoryResponse(
            id=cat["_id"],
            name=cat["name"],
            type=cat["type"],
            description=cat.get("description"),
            item_count=item_count,
            created_at=cat["created_at"],
        ))
    
    return result


@router.get("/{category_id}", response_model=CategoryResponse)
async def get_category(category_id: str, _: dict = Depends(get_admin_auditor)):
    """Get a single category."""
    collection = get_categories_collection()
    cat = await collection.find_one({"_id": category_id})
    
    if not cat:
        raise HTTPException(status_code=404, detail="Category not found")
    
    item_count = 0
    if cat["type"] == "tradeshop":
        item_count = await get_tradeshops_collection().count_documents({"category_id": cat["_id"]})
    
    return CategoryResponse(
        id=cat["_id"],
        name=cat["name"],
        type=cat["type"],
        description=cat.get("description"),
        item_count=item_count,
        created_at=cat["created_at"],
    )


@router.post("/", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
async def create_category(request: CategoryCreate, _: dict = Depends(get_admin_auditor)):
    """Create a new category."""
    collection = get_categories_collection()
    
    # Check duplicate name for same type
    existing = await collection.find_one({"name": request.name, "type": request.type})
    if existing:
        raise HTTPException(status_code=400, detail="Category with this name already exists")
    
    now = datetime.utcnow()
    category_id = str(uuid.uuid4())
    
    doc = {
        "_id": category_id,
        "name": request.name,
        "type": request.type,
        "description": request.description,
        "created_at": now,
    }
    
    await collection.insert_one(doc)
    
    return CategoryResponse(
        id=category_id,
        name=request.name,
        type=request.type,
        description=request.description,
        item_count=0,
        created_at=now,
    )


@router.put("/{category_id}", response_model=CategoryResponse)
async def update_category(
    category_id: str,
    request: CategoryUpdate,
    _: dict = Depends(get_admin_auditor)
):
    """Update a category."""
    collection = get_categories_collection()
    
    cat = await collection.find_one({"_id": category_id})
    if not cat:
        raise HTTPException(status_code=404, detail="Category not found")
    
    update_data = {}
    if request.name is not None:
        update_data["name"] = request.name
    if request.type is not None:
        update_data["type"] = request.type
    if request.description is not None:
        update_data["description"] = request.description
    
    if update_data:
        await collection.update_one({"_id": category_id}, {"$set": update_data})
    
    return await get_category(category_id, _)


@router.delete("/{category_id}")
async def delete_category(category_id: str, _: dict = Depends(get_admin_auditor)):
    """Delete a category."""
    collection = get_categories_collection()
    
    # Check if category is in use
    tradeshop_count = await get_tradeshops_collection().count_documents({"category_id": category_id})
    if tradeshop_count > 0:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot delete category with {tradeshop_count} tradeshops using it"
        )
    
    result = await collection.delete_one({"_id": category_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Category not found")
    
    return {"message": "Category deleted successfully"}
