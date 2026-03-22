"""
Campaign models - Audit campaigns with time periods.
"""

from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field


class CampaignBase(BaseModel):
    """Base campaign fields."""
    name: str = Field(..., min_length=2, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    start_date: datetime
    end_date: datetime
    survey_id: Optional[str] = None
    target_tradeshop_ids: List[str] = Field(default_factory=list)
    is_active: bool = True


class CampaignCreate(CampaignBase):
    """Create campaign request."""
    pass


class CampaignUpdate(BaseModel):
    """Update campaign request."""
    name: Optional[str] = Field(None, min_length=2, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    survey_id: Optional[str] = None
    target_tradeshop_ids: Optional[List[str]] = None
    is_active: Optional[bool] = None


class CampaignResponse(CampaignBase):
    """Campaign response."""
    id: str
    survey_name: Optional[str] = None
    total_tradeshops: int = 0
    completed_audits: int = 0
    progress_percent: float = 0.0
    created_at: datetime
    updated_at: datetime

    class Config:
        populate_by_name = True


class CampaignStats(BaseModel):
    """Campaign statistics."""
    campaign_id: str
    campaign_name: str
    total_tradeshops: int
    completed_audits: int
    pending_audits: int
    progress_percent: float
    pass_count: int = 0
    warning_count: int = 0
    fail_count: int = 0
