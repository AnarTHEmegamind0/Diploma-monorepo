"""
Auth models - Authentication and authorization.
"""

from typing import Optional
from pydantic import BaseModel, Field, EmailStr


class LoginRequest(BaseModel):
    """Login request."""
    phone: str = Field(..., min_length=8, max_length=20)
    password: str = Field(..., min_length=6)


class LoginResponse(BaseModel):
    """Login response."""
    access_token: str
    token_type: str = "bearer"
    auditor_id: str
    auditor_name: str
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    group_id: Optional[str] = None
    group_name: Optional[str] = None
    is_active: bool = True
    is_admin: bool = False


class TokenPayload(BaseModel):
    """JWT token payload."""
    sub: str  # auditor_id
    name: str
    is_admin: bool = False
    exp: int


class PasswordChange(BaseModel):
    """Password change request."""
    current_password: str = Field(..., min_length=6)
    new_password: str = Field(..., min_length=6)
