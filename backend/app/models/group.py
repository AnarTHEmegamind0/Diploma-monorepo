"""
Group models - Auditor groups/teams.
"""

from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field


class GroupBase(BaseModel):
    """Base group fields."""
    name: str = Field(..., min_length=2, max_length=100)
    description: Optional[str] = Field(None, max_length=500)


class GroupCreate(GroupBase):
    """Create group request."""
    pass


class GroupUpdate(BaseModel):
    """Update group request."""
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    description: Optional[str] = Field(None, max_length=500)


class GroupResponse(GroupBase):
    """Group response."""
    id: str
    auditor_count: int = 0
    tradeshop_count: int = 0
    created_at: datetime

    class Config:
        populate_by_name = True
