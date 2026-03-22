"""
Authentication routes - Login, register, password change.
"""

from datetime import datetime
import uuid

from fastapi import APIRouter, HTTPException, Depends, status

from ..models.auth import LoginRequest, LoginResponse, PasswordChange
from ..models.auditor import AuditorCreate, AuditorResponse
from ..database import get_auditors_collection, get_groups_collection
from ..services.auth_service import (
    hash_password,
    verify_password,
    create_access_token,
)
from ..dependencies import get_current_auditor, get_admin_auditor

router = APIRouter()


@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest):
    """
    Login with phone and password.
    Returns JWT access token.
    """
    collection = get_auditors_collection()
    auditor = await collection.find_one({"phone": request.phone})
    
    if not auditor:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid phone or password",
        )
    
    if not verify_password(request.password, auditor.get("password_hash", "")):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid phone or password",
        )
    
    if not auditor.get("is_active", True):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is deactivated",
        )

    group_name = None
    if auditor.get("group_id"):
        groups_collection = get_groups_collection()
        group = await groups_collection.find_one({"_id": auditor["group_id"]})
        if group:
            group_name = group["name"]
    
    # Create access token
    token_data = {
        "sub": auditor["_id"],
        "name": auditor["name"],
        "is_admin": auditor.get("is_admin", False),
    }
    access_token = create_access_token(token_data)
    
    return LoginResponse(
        access_token=access_token,
        token_type="bearer",
        auditor_id=auditor["_id"],
        auditor_name=auditor["name"],
        phone=auditor["phone"],
        email=auditor.get("email"),
        group_id=auditor.get("group_id"),
        group_name=group_name,
        is_active=auditor.get("is_active", True),
        is_admin=auditor.get("is_admin", False),
    )


@router.post("/register", response_model=AuditorResponse, status_code=status.HTTP_201_CREATED)
async def register(
    request: AuditorCreate,
    current_admin: dict = Depends(get_admin_auditor)
):
    """
    Register a new auditor (admin only).
    """
    collection = get_auditors_collection()
    
    # Check if phone already exists
    existing = await collection.find_one({"phone": request.phone})
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered",
        )
    
    # Check if email already exists (if provided)
    if request.email:
        existing_email = await collection.find_one({"email": request.email})
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )
    
    now = datetime.utcnow()
    auditor_id = str(uuid.uuid4())
    
    auditor_doc = {
        "_id": auditor_id,
        "name": request.name,
        "phone": request.phone,
        "email": request.email,
        "group_id": request.group_id,
        "is_active": request.is_active,
        "is_admin": False,
        "password_hash": hash_password(request.password),
        "created_at": now,
        "updated_at": now,
    }
    
    await collection.insert_one(auditor_doc)
    
    # Get group name if group_id provided
    group_name = None
    if request.group_id:
        groups_collection = get_groups_collection()
        group = await groups_collection.find_one({"_id": request.group_id})
        if group:
            group_name = group["name"]
    
    return AuditorResponse(
        id=auditor_id,
        name=request.name,
        phone=request.phone,
        email=request.email,
        group_id=request.group_id,
        group_name=group_name,
        is_active=request.is_active,
        is_admin=False,
        created_at=now,
        updated_at=now,
    )


@router.get("/me", response_model=AuditorResponse)
async def get_me(current_auditor: dict = Depends(get_current_auditor)):
    """
    Get current authenticated auditor's info.
    """
    # Get group name if group_id exists
    group_name = None
    if current_auditor.get("group_id"):
        groups_collection = get_groups_collection()
        group = await groups_collection.find_one({"_id": current_auditor["group_id"]})
        if group:
            group_name = group["name"]
    
    return AuditorResponse(
        id=current_auditor["_id"],
        name=current_auditor["name"],
        phone=current_auditor["phone"],
        email=current_auditor.get("email"),
        group_id=current_auditor.get("group_id"),
        group_name=group_name,
        is_active=current_auditor.get("is_active", True),
        is_admin=current_auditor.get("is_admin", False),
        created_at=current_auditor["created_at"],
        updated_at=current_auditor["updated_at"],
    )


@router.post("/change-password")
async def change_password(
    request: PasswordChange,
    current_auditor: dict = Depends(get_current_auditor)
):
    """
    Change current auditor's password.
    """
    # Verify current password
    if not verify_password(request.current_password, current_auditor.get("password_hash", "")):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect",
        )
    
    # Update password
    collection = get_auditors_collection()
    await collection.update_one(
        {"_id": current_auditor["_id"]},
        {
            "$set": {
                "password_hash": hash_password(request.new_password),
                "updated_at": datetime.utcnow(),
            }
        }
    )
    
    return {"message": "Password changed successfully"}


@router.post("/init-admin")
async def init_admin():
    """
    Initialize first admin user (only works if no admins exist).
    This is for initial setup only.
    """
    collection = get_auditors_collection()
    
    # Check if any admin exists
    admin_exists = await collection.find_one({"is_admin": True})
    if admin_exists:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin already exists. Use normal registration.",
        )
    
    now = datetime.utcnow()
    admin_id = str(uuid.uuid4())
    
    admin_doc = {
        "_id": admin_id,
        "name": "Admin",
        "phone": "99999999",
        "email": "admin@example.com",
        "group_id": None,
        "is_active": True,
        "is_admin": True,
        "password_hash": hash_password("admin123"),
        "created_at": now,
        "updated_at": now,
    }
    
    await collection.insert_one(admin_doc)
    
    return {
        "message": "Admin created successfully",
        "phone": "99999999",
        "password": "admin123",
        "warning": "Please change this password immediately!",
    }
