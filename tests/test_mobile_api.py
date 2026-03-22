"""Tests for mobile API helper functions."""

import asyncio
import sys
from pathlib import Path

import pytest
from fastapi import HTTPException

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from backend.app.routes.audit_submit import parse_manual_answers
from backend.app.routes.mobile import build_mobile_tradeshop_summaries, can_access_tradeshop


def test_parse_manual_answers_uses_question_text_fallback():
    """Manual answers should inherit question text from the survey definition."""
    answers = parse_manual_answers(
        '[{"question_id": "q-1", "answer": 3}]',
        {"q-1": {"text": "Cash zone хэдэн ширхэг вэ?"}},
    )

    assert len(answers) == 1
    assert answers[0].question_text == "Cash zone хэдэн ширхэг вэ?"
    assert answers[0].answer == 3
    assert answers[0].auto_answered is False


def test_parse_manual_answers_rejects_unknown_question():
    """Unknown question IDs should be rejected immediately."""
    with pytest.raises(HTTPException) as exc:
        parse_manual_answers(
            '[{"question_id": "missing", "answer": "Тийм"}]',
            {"q-1": {"text": "Test question"}},
        )

    assert exc.value.status_code == 400
    assert "Unknown question_id" in exc.value.detail


def test_can_access_tradeshop_by_assignment_or_group():
    """Auditors can access explicitly assigned shops or shops in their group."""
    auditor = {"_id": "auditor-1", "group_id": "group-1", "is_admin": False}

    assert can_access_tradeshop(auditor, {"assigned_auditor_id": "auditor-1", "group_id": "group-2"}) is True
    assert can_access_tradeshop(auditor, {"assigned_auditor_id": "auditor-2", "group_id": "group-1"}) is True
    assert can_access_tradeshop(auditor, {"assigned_auditor_id": "auditor-2", "group_id": "group-2"}) is False


def test_build_mobile_tradeshop_summaries_includes_location(monkeypatch):
    """Mobile tradeshop payloads must expose location for map/radius checks."""

    class FakeCursor:
        def sort(self, *_args, **_kwargs):
            return self

        async def to_list(self, length=None):
            _ = length
            return []

    class FakeResponsesCollection:
        def find(self, *_args, **_kwargs):
            return FakeCursor()

    class FakeLookupCollection:
        async def find_one(self, *_args, **_kwargs):
            return None

    monkeypatch.setattr("backend.app.routes.mobile.get_groups_collection", lambda: FakeLookupCollection())
    monkeypatch.setattr("backend.app.routes.mobile.get_categories_collection", lambda: FakeLookupCollection())
    monkeypatch.setattr("backend.app.routes.mobile.get_auditors_collection", lambda: FakeLookupCollection())
    monkeypatch.setattr(
        "backend.app.routes.mobile.get_audit_responses_collection",
        lambda: FakeResponsesCollection(),
    )

    summaries = asyncio.run(
        build_mobile_tradeshop_summaries(
            [
                {
                    "_id": "shop-1",
                    "name": "CU SBD",
                    "address": "Seoul Street",
                    "location": {"lat": 47.9186, "lng": 106.9177},
                }
            ],
            {"_id": "auditor-1", "is_admin": False},
        )
    )

    assert len(summaries) == 1
    assert summaries[0].location is not None
    assert summaries[0].location.lat == pytest.approx(47.9186)
    assert summaries[0].location.lng == pytest.approx(106.9177)
