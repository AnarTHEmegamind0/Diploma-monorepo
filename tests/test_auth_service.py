"""Unit tests for backend authentication helpers."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from backend.app.services.auth_service import hash_password, verify_password


def test_hash_and_verify_password_round_trip():
    password = "audit123"

    hashed = hash_password(password)

    assert hashed != password
    assert verify_password(password, hashed) is True


def test_verify_password_returns_false_for_wrong_password():
    hashed = "$2b$12$IsnYZjj8UN9Yf13n.3rvsuTuHwhy6TyQITJiSdYNSRq6GQAJdfX.C"

    assert verify_password("wrong-password", hashed) is False


def test_verify_password_returns_false_for_missing_hash():
    assert verify_password("audit123", "") is False
