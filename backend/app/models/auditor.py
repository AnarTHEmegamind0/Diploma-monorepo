"""
Auditor models - Field auditors who collect data.
"""

from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field, EmailStr


class AuditorBase(BaseModel):
    """Base auditor fields."""
    name: str = Field(..., min_length=2, max_length=100)
    phone: str = Field(..., min_length=8, max_length=20)
    email: Optional[EmailStr] = None
    group_id: Optional[str] = None
    is_active: bool = True


class AuditorCreate(AuditorBase):
    """Create auditor request."""
    password: str = Field(..., min_length=6)


class AuditorUpdate(BaseModel):
    """Update auditor request."""
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    phone: Optional[str] = Field(None, min_length=8, max_length=20)
    email: Optional[EmailStr] = None
    group_id: Optional[str] = None
    is_active: Optional[bool] = None
    password: Optional[str] = Field(None, min_length=6)


class AuditorInDB(AuditorBase):
    """Auditor stored in database."""
    id: str = Field(..., alias="_id")
    password_hash: str
    created_at: datetime
    updated_at: datetime

    class Config:
        populate_by_name = True


class AuditorResponse(AuditorBase):
    """Auditor response (without password)."""
    id: str
    is_admin: bool = False
    created_at: datetime
    updated_at: datetime
    group_name: Optional[str] = None

    class Config:
        populate_by_name = True
