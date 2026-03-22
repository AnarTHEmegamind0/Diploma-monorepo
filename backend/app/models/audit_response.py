"""
Audit Response models - Survey responses submitted by auditors.
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field


class Answer(BaseModel):
    """Single question answer."""
    question_id: str
    question_text: str
    answer: Any  # Can be string, number, boolean, or list
    auto_answered: bool = False  # True if answered by YOLO


class AuditLocation(BaseModel):
    """Location where audit was performed."""
    lat: float
    lng: float
    accuracy: Optional[float] = None


class AuditResponseCreate(BaseModel):
    """Create audit response request (from mobile app)."""
    campaign_id: str
    tradeshop_id: str
    # Image will be uploaded as file, detection_id returned
    answers: List[Answer] = Field(default_factory=list)
    location: Optional[AuditLocation] = None
    notes: Optional[str] = Field(None, max_length=1000)


class AuditResponseInDB(BaseModel):
    """Audit response stored in database."""
    id: str = Field(..., alias="_id")
    campaign_id: str
    tradeshop_id: str
    auditor_id: str
    survey_id: str
    detection_id: Optional[str] = None  # YOLO detection result
    answers: List[Answer]
    photos: List[str] = Field(default_factory=list)  # Photo paths
    location: Optional[AuditLocation] = None
    notes: Optional[str] = None
    status: str = "completed"  # completed, pending, failed
    submitted_at: datetime
    created_at: datetime

    class Config:
        populate_by_name = True


class AuditResponseResponse(BaseModel):
    """Audit response for API."""
    id: str
    campaign_id: str
    campaign_name: Optional[str] = None
    tradeshop_id: str
    tradeshop_name: Optional[str] = None
    auditor_id: str
    auditor_name: Optional[str] = None
    survey_id: str
    detection_id: Optional[str] = None
    detection_summary: Optional[Dict[str, int]] = None  # {product: count}
    detection_items: List[Dict[str, Any]] = Field(default_factory=list)
    detection_total: int = 0
    detection_processing_time_ms: float = 0.0
    answers: List[Answer]
    photos: List[str] = Field(default_factory=list)
    location: Optional[AuditLocation] = None
    notes: Optional[str] = None
    status: str
    submitted_at: datetime
    created_at: datetime

    class Config:
        populate_by_name = True


class AuditSubmitRequest(BaseModel):
    """
    Request for submitting audit with image.
    Image is uploaded as multipart/form-data.
    This model is for the JSON part.
    """
    campaign_id: str
    tradeshop_id: str
    location: Optional[AuditLocation] = None
    notes: Optional[str] = Field(None, max_length=1000)


class AuditSubmitResponse(BaseModel):
    """Response after audit submission."""
    audit_response_id: str
    detection_id: str
    detected_products: Dict[str, int]  # {product: count}
    auto_answers: List[Answer]
    saved_answers: List[Answer] = Field(default_factory=list)
    answer_count: int = 0
    photo_count: int = 0
    status: str
    message: str
