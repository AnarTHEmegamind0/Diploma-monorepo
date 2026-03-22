"""
Question models - Survey questions.
"""

from typing import Optional, List, Literal
from datetime import datetime
from pydantic import BaseModel, Field, model_validator


QuestionType = Literal[
    "yes_no",
    "number",
    "text",
    "single_choice",
    "multiple_choice",
    "photo",
    "dropdown",
    "rating",
]


class QuestionTypeDefinition(BaseModel):
    """Static question type definition returned to the frontend."""
    code: QuestionType
    name: str
    description: str
    has_options: bool = False


QUESTION_TYPE_DEFINITIONS: list[QuestionTypeDefinition] = [
    QuestionTypeDefinition(code="yes_no", name="Тийм/Үгүй", description="Тийм эсвэл Үгүй сонгоно"),
    QuestionTypeDefinition(code="number", name="Тоо", description="Тоо оруулна"),
    QuestionTypeDefinition(code="text", name="Текст", description="Чөлөөт текст оруулна"),
    QuestionTypeDefinition(code="single_choice", name="Нэг сонголт", description="Нэг сонголт сонгоно", has_options=True),
    QuestionTypeDefinition(code="multiple_choice", name="Олон сонголт", description="Олон сонголт сонгоно", has_options=True),
    QuestionTypeDefinition(code="photo", name="Зураг", description="Зураг шаардана"),
    QuestionTypeDefinition(code="dropdown", name="Dropdown", description="Жагсаалтаас нэгийг сонгоно", has_options=True),
    QuestionTypeDefinition(code="rating", name="Үнэлгээ", description="Оноо эсвэл үнэлгээ өгнө"),
]


class QuestionBase(BaseModel):
    """Base question fields."""
    text: str = Field(..., min_length=5, max_length=500)
    type: QuestionType = "yes_no"
    options: List[str] = Field(default_factory=list)
    required: bool = True
    order: int = Field(0, ge=0)
    group_id: str
    product_class: Optional[str] = Field(
        None,
        description="YOLO product class name for auto-answering"
    )
    detection_based: bool = False

    @model_validator(mode="after")
    def validate_shape(self):
        option_based_types = {"single_choice", "multiple_choice", "dropdown"}
        if self.type in option_based_types and not self.options:
            raise ValueError("Options are required for choice-based question types")
        if self.type not in option_based_types:
            self.options = []
        if self.detection_based and not self.product_class:
            raise ValueError("product_class is required when detection_based is enabled")
        return self


class QuestionCreate(QuestionBase):
    """Create question request."""
    survey_id: str


class QuestionUpdate(BaseModel):
    """Update question request."""
    text: Optional[str] = Field(None, min_length=5, max_length=500)
    type: Optional[QuestionType] = None
    options: Optional[List[str]] = None
    required: Optional[bool] = None
    order: Optional[int] = Field(None, ge=0)
    group_id: Optional[str] = None
    product_class: Optional[str] = None
    detection_based: Optional[bool] = None


class QuestionResponse(QuestionBase):
    """Question response."""
    id: str
    survey_id: str
    created_at: datetime

    class Config:
        populate_by_name = True


class QuestionReorder(BaseModel):
    """Reorder questions request."""
    question_ids: List[str] = Field(..., description="Question IDs in new order")
