"""
Category models - Categories for tradeshops and products.
"""

from typing import Optional, Literal
from datetime import datetime
from pydantic import BaseModel, Field


CategoryType = Literal["tradeshop", "product"]


class CategoryBase(BaseModel):
    """Base category fields."""
    name: str = Field(..., min_length=2, max_length=100)
    type: CategoryType = Field(..., description="Category type: tradeshop or product")
    description: Optional[str] = Field(None, max_length=500)


class CategoryCreate(CategoryBase):
    """Create category request."""
    pass


class CategoryUpdate(BaseModel):
    """Update category request."""
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    type: Optional[CategoryType] = None
    description: Optional[str] = Field(None, max_length=500)


class CategoryResponse(CategoryBase):
    """Category response."""
    id: str
    item_count: int = 0  # Number of tradeshops or products using this category
    created_at: datetime

    class Config:
        populate_by_name = True
