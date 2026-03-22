"""
Question group models - Logical sections inside a survey.
"""

from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field


class QuestionGroupBase(BaseModel):
    """Base question group fields."""
    name: str = Field(..., min_length=2, max_length=120)
    description: Optional[str] = Field(None, max_length=500)
    order: int = Field(0, ge=0)


class QuestionGroupCreate(QuestionGroupBase):
    """Create question group request."""
    survey_id: str


class QuestionGroupUpdate(BaseModel):
    """Update question group request."""
    name: Optional[str] = Field(None, min_length=2, max_length=120)
    description: Optional[str] = Field(None, max_length=500)
    order: Optional[int] = Field(None, ge=0)


class QuestionGroupResponse(QuestionGroupBase):
    """Question group response."""
    id: str
    survey_id: str
    question_count: int = 0
    created_at: datetime
    updated_at: datetime

    class Config:
        populate_by_name = True
