"""
Survey models - Survey templates with grouped questions.
"""

from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field


class SurveyBase(BaseModel):
    """Base survey fields."""
    name: str = Field(..., min_length=2, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    category_id: Optional[str] = None
    is_active: bool = True


class SurveyCreate(SurveyBase):
    """Create survey request."""
    pass


class SurveyUpdate(BaseModel):
    """Update survey request."""
    name: Optional[str] = Field(None, min_length=2, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    category_id: Optional[str] = None
    is_active: Optional[bool] = None


class SurveyResponse(SurveyBase):
    """Survey response."""
    id: str
    question_count: int = 0
    group_count: int = 0
    created_at: datetime
    updated_at: datetime

    class Config:
        populate_by_name = True


class SurveyGroupWithQuestions(BaseModel):
    """Question group with embedded questions."""
    id: str
    survey_id: str
    name: str
    description: Optional[str] = None
    order: int = 0
    question_count: int = 0
    created_at: datetime
    updated_at: datetime
    questions: List["QuestionResponse"] = Field(default_factory=list)


class SurveyWithQuestions(SurveyResponse):
    """Survey with grouped questions."""
    groups: List[SurveyGroupWithQuestions] = Field(default_factory=list)


# Import at bottom to avoid circular imports
from .question import QuestionResponse
SurveyWithQuestions.model_rebuild()
