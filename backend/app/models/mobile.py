"""
Mobile API models - Flutter app specific responses.
"""

from typing import Optional, List, Literal
from datetime import datetime
from pydantic import BaseModel, Field

from .audit_response import AuditLocation


AuditTaskStatus = Literal["pending", "completed"]


class MobileTradeshopSummary(BaseModel):
    """Tradeshop summary for the mobile app."""
    id: str
    name: str
    address: Optional[str] = None
    location: Optional[AuditLocation] = None
    group_id: Optional[str] = None
    group_name: Optional[str] = None
    category_id: Optional[str] = None
    category_name: Optional[str] = None
    assigned_auditor_id: Optional[str] = None
    assigned_auditor_name: Optional[str] = None
    latest_response_id: Optional[str] = None
    latest_submitted_at: Optional[datetime] = None
    audit_status: AuditTaskStatus = "pending"


class MobileCampaignSummary(BaseModel):
    """Campaign summary for the mobile app home screen."""
    id: str
    name: str
    description: Optional[str] = None
    start_date: datetime
    end_date: datetime
    survey_id: Optional[str] = None
    survey_name: Optional[str] = None
    total_tradeshops: int = 0
    completed_tradeshops: int = 0
    pending_tradeshops: int = 0
    progress_percent: float = 0.0


class MobileCampaignDetail(MobileCampaignSummary):
    """Campaign detail with accessible tradeshops and survey counts."""
    question_group_count: int = 0
    question_count: int = 0
    tradeshops: List[MobileTradeshopSummary] = Field(default_factory=list)
