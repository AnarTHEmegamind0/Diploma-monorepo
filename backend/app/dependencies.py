"""
FastAPI dependencies - Auth, database access, etc.
"""

from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from .services.auth_service import decode_access_token
from .database import get_auditors_collection

security = HTTPBearer(auto_error=False)


async def get_current_auditor(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> dict:
    """
    Get current authenticated auditor from JWT token.
    Raises 401 if not authenticated.
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = credentials.credentials
    payload = decode_access_token(token)
    
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    auditor_id = payload.get("sub")
    if not auditor_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )
    
    # Get auditor from database
    collection = get_auditors_collection()
    auditor = await collection.find_one({"_id": auditor_id})
    
    if not auditor:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Auditor not found",
        )
    
    if not auditor.get("is_active", True):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Auditor account is deactivated",
        )
    
    return auditor


async def get_current_auditor_optional(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> Optional[dict]:
    """
    Get current auditor if authenticated, None otherwise.
    Does not raise exception if not authenticated.
    """
    if not credentials:
        return None
    
    try:
        return await get_current_auditor(credentials)
    except HTTPException:
        return None


async def get_admin_auditor(
    current_auditor: dict = Depends(get_current_auditor)
) -> dict:
    """
    Get current auditor and verify they have admin privileges.
    """
    if not current_auditor.get("is_admin", False):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required",
        )
    return current_auditor
