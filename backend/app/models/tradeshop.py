"""
Tradeshop models - Retail stores/shops to audit.
"""

from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field


class Location(BaseModel):
    """Geographic location."""
    lat: float = Field(..., ge=-90, le=90)
    lng: float = Field(..., ge=-180, le=180)


class TradeshopBase(BaseModel):
    """Base tradeshop fields."""
    name: str = Field(..., min_length=2, max_length=200)
    address: Optional[str] = Field(None, max_length=500)
    location: Optional[Location] = None
    group_id: Optional[str] = None
    category_id: Optional[str] = None
    phone: Optional[str] = Field(None, max_length=20)
    assigned_auditor_id: Optional[str] = None
    is_active: bool = True


class TradeshopCreate(TradeshopBase):
    """Create tradeshop request."""
    pass


class TradeshopUpdate(BaseModel):
    """Update tradeshop request."""
    name: Optional[str] = Field(None, min_length=2, max_length=200)
    address: Optional[str] = Field(None, max_length=500)
    location: Optional[Location] = None
    group_id: Optional[str] = None
    category_id: Optional[str] = None
    phone: Optional[str] = Field(None, max_length=20)
    assigned_auditor_id: Optional[str] = None
    is_active: Optional[bool] = None


class TradeshopResponse(TradeshopBase):
    """Tradeshop response."""
    id: str
    group_name: Optional[str] = None
    category_name: Optional[str] = None
    assigned_auditor_name: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        populate_by_name = True
