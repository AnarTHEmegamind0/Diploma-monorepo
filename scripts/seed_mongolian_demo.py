#!/usr/bin/env python3
"""
Seed deterministic Mongolian demo data for the inventory audit system.

Usage:
    python scripts/seed_mongolian_demo.py
"""

import asyncio
import json
from datetime import datetime, timedelta
from pathlib import Path

from motor.motor_asyncio import AsyncIOMotorClient

from backend.app.config import settings
from backend.app.services.auth_service import hash_password


NOW = datetime.utcnow()

GROUPS = [
    {
        "_id": "group-ub-central",
        "name": "Улаанбаатар - Төв",
        "description": "Төвийн бүсийн аудитор болон дэлгүүрүүд",
    },
    {
        "_id": "group-ub-bz",
        "name": "Улаанбаатар - Баянзүрх",
        "description": "Баянзүрх бүсийн аудитор болон дэлгүүрүүд",
    },
    {
        "_id": "group-darkhan",
        "name": "Дархан",
        "description": "Дархан хотын аудитын бүс",
    },
    {
        "_id": "group-erdenet",
        "name": "Эрдэнэт",
        "description": "Эрдэнэт хотын аудитын бүс",
    },
]

PRODUCT_CATEGORIES = [
    ("cat-product-water", "Ус"),
    ("cat-product-milk", "Сүү"),
    ("cat-product-beverage", "Ундаа"),
    ("cat-product-flour", "Гурил, гурилан бүтээгдэхүүн"),
]

TRADESHOP_CATEGORIES = [
    ("cat-shop-chain", "Сүлжээ дэлгүүр"),
    ("cat-shop-minimart", "Мини маркет"),
    ("cat-shop-grocery", "Хүнсний дэлгүүр"),
    ("cat-shop-supermarket", "Супермаркет"),
]

AUDITORS = [
    {
        "_id": "auditor-admin",
        "name": "Систем Админ",
        "phone": "99999999",
        "email": "admin@inventory.mn",
        "group_id": None,
        "is_admin": True,
        "password": "admin123",
    },
    {
        "_id": "auditor-bat-erdene",
        "name": "Бат-Эрдэнэ",
        "phone": "88001122",
        "email": "bat.erdene@inventory.mn",
        "group_id": "group-ub-central",
        "is_admin": False,
        "password": "audit123",
    },
    {
        "_id": "auditor-suvd",
        "name": "Сувд-Эрдэнэ",
        "phone": "88002233",
        "email": "suvd@inventory.mn",
        "group_id": "group-ub-bz",
        "is_admin": False,
        "password": "audit123",
    },
    {
        "_id": "auditor-darkhan",
        "name": "Мөнх-Оргил",
        "phone": "88003344",
        "email": "munkh.orgil@inventory.mn",
        "group_id": "group-darkhan",
        "is_admin": False,
        "password": "audit123",
    },
    {
        "_id": "auditor-erdenet",
        "name": "Номин-Эрдэнэ",
        "phone": "88004455",
        "email": "nomin.erdene@inventory.mn",
        "group_id": "group-erdenet",
        "is_admin": False,
        "password": "audit123",
    },
]

TRADESHOPS = [
    {
        "_id": "shop-nomin-sansar",
        "name": "Номин Сансар",
        "address": "Баянзүрх дүүрэг, 13-р хороолол",
        "location": {"lat": 47.9186, "lng": 106.9375},
        "group_id": "group-ub-bz",
        "category_id": "cat-shop-supermarket",
        "phone": "70112233",
        "assigned_auditor_id": "auditor-suvd",
    },
    {
        "_id": "shop-cu-peace",
        "name": "CU Peace Mall",
        "address": "Сүхбаатар дүүрэг, Peace Mall",
        "location": {"lat": 47.9183, "lng": 106.9170},
        "group_id": "group-ub-central",
        "category_id": "cat-shop-minimart",
        "phone": "70118899",
        "assigned_auditor_id": "auditor-bat-erdene",
    },
    {
        "_id": "shop-orgil-13",
        "name": "Оргил 13-р хороолол",
        "address": "Баянзүрх дүүрэг, 13-р хороолол",
        "location": {"lat": 47.9189, "lng": 106.9440},
        "group_id": "group-ub-bz",
        "category_id": "cat-shop-chain",
        "phone": "70117766",
        "assigned_auditor_id": "auditor-suvd",
    },
    {
        "_id": "shop-bosa-bz",
        "name": "Боса Баянзүрх",
        "address": "Баянзүрх дүүрэг, 26-р хороо",
        "location": {"lat": 47.9211, "lng": 106.9542},
        "group_id": "group-ub-bz",
        "category_id": "cat-shop-grocery",
        "phone": "70119988",
        "assigned_auditor_id": "auditor-suvd",
    },
    {
        "_id": "shop-state-dept",
        "name": "State Department Store Express",
        "address": "Чингэлтэй дүүрэг, Их дэлгүүр",
        "location": {"lat": 47.9191, "lng": 106.9179},
        "group_id": "group-ub-central",
        "category_id": "cat-shop-chain",
        "phone": "70115544",
        "assigned_auditor_id": "auditor-bat-erdene",
    },
    {
        "_id": "shop-darkhan-nomin",
        "name": "Дархан Номин",
        "address": "Дархан-Уул, 15-р баг",
        "location": {"lat": 49.4867, "lng": 105.9228},
        "group_id": "group-darkhan",
        "category_id": "cat-shop-supermarket",
        "phone": "70371234",
        "assigned_auditor_id": "auditor-darkhan",
    },
    {
        "_id": "shop-erdenet-8",
        "name": "Эрдэнэт 8-р микр",
        "address": "Орхон аймаг, 8-р микрорайон",
        "location": {"lat": 49.0286, "lng": 104.0440},
        "group_id": "group-erdenet",
        "category_id": "cat-shop-grocery",
        "phone": "70353344",
        "assigned_auditor_id": "auditor-erdenet",
    },
    {
        "_id": "shop-tumen-huns",
        "name": "Түмэн Хүнс",
        "address": "Сүхбаатар дүүрэг, 6-р хороо",
        "location": {"lat": 47.9230, "lng": 106.9143},
        "group_id": "group-ub-central",
        "category_id": "cat-shop-grocery",
        "phone": "70116677",
        "assigned_auditor_id": "auditor-bat-erdene",
    },
]

SURVEYS = [
    {
        "_id": "survey-beverage-execution",
        "name": "Ундааны байршуулалтын аудит",
        "description": "Cash zone, нэмэлт тавиур, хөргөгч болон үндсэн лангууны шалгалт",
        "category_id": "cat-product-beverage",
    },
    {
        "_id": "survey-dairy-freshness",
        "name": "Сүүний шинэлэг байдлын аудит",
        "description": "Сүүний хөргөлт, хугацаа, үнийн мэдээллийн шалгалт",
        "category_id": "cat-product-milk",
    },
]

QUESTION_GROUPS = [
    {
        "_id": "qg-cash-zone",
        "survey_id": "survey-beverage-execution",
        "name": "Cash Zone",
        "description": "Касс орчмын байршуулалт",
        "order": 1,
    },
    {
        "_id": "qg-extra-shelf",
        "survey_id": "survey-beverage-execution",
        "name": "Нэмэлт тавиур",
        "description": "Промо эсвэл нэмэлт тавиурын шалгалт",
        "order": 2,
    },
    {
        "_id": "qg-fridge",
        "survey_id": "survey-beverage-execution",
        "name": "Хөргөгч",
        "description": "Хөргөгчийн байршуулалт болон POSM",
        "order": 3,
    },
    {
        "_id": "qg-main-counter",
        "survey_id": "survey-beverage-execution",
        "name": "Үндсэн лангуу",
        "description": "Үндсэн лангуу болон үнийн мэдээлэл",
        "order": 4,
    },
    {
        "_id": "qg-dairy-fridge",
        "survey_id": "survey-dairy-freshness",
        "name": "Сүүний хөргөгч",
        "description": "Сүүний хөргөгчийн төлөв",
        "order": 1,
    },
    {
        "_id": "qg-dairy-price",
        "survey_id": "survey-dairy-freshness",
        "name": "Үнийн мэдээлэл",
        "description": "Үнийн шошго, хугацааны мэдээлэл",
        "order": 2,
    },
]

QUESTIONS = [
    {
        "_id": "q-cash-yes-no",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-cash-zone",
        "text": "Cash zone дээр Coca-Cola бүтээгдэхүүн байна уу?",
        "type": "yes_no",
        "options": [],
        "required": True,
        "order": 1,
        "product_class": "coca_cola_500ml",
        "detection_based": True,
    },
    {
        "_id": "q-cash-count",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-cash-zone",
        "text": "Cash zone дээр хэдэн Coca-Cola бүтээгдэхүүн байна вэ?",
        "type": "number",
        "options": [],
        "required": True,
        "order": 2,
        "product_class": "coca_cola_500ml",
        "detection_based": True,
    },
    {
        "_id": "q-cash-photo",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-cash-zone",
        "text": "Cash zone зургийг баталгаажуулна уу.",
        "type": "photo",
        "options": [],
        "required": True,
        "order": 3,
        "product_class": None,
        "detection_based": False,
    },
    {
        "_id": "q-extra-shelf-exists",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-extra-shelf",
        "text": "Нэмэлт тавиур дээр Fanta байна уу?",
        "type": "yes_no",
        "options": [],
        "required": True,
        "order": 1,
        "product_class": "fanta_orange",
        "detection_based": True,
    },
    {
        "_id": "q-extra-shelf-count",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-extra-shelf",
        "text": "Нэмэлт тавиурын Fanta хэдэн facing байна вэ?",
        "type": "number",
        "options": [],
        "required": True,
        "order": 2,
        "product_class": "fanta_orange",
        "detection_based": True,
    },
    {
        "_id": "q-fridge-brand",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-fridge",
        "text": "Хөргөгчийн брэндийг сонгоно уу.",
        "type": "single_choice",
        "options": ["Coca-Cola", "Pepsi", "Бусад"],
        "required": True,
        "order": 1,
        "product_class": None,
        "detection_based": False,
    },
    {
        "_id": "q-fridge-count",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-fridge",
        "text": "Sprite бүтээгдэхүүнтэй хөргөгч хэд байна вэ?",
        "type": "number",
        "options": [],
        "required": True,
        "order": 2,
        "product_class": "sprite_500ml",
        "detection_based": True,
    },
    {
        "_id": "q-main-price-label",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-main-counter",
        "text": "Үнийн шошго бүрэн байна уу?",
        "type": "yes_no",
        "options": [],
        "required": True,
        "order": 1,
        "product_class": None,
        "detection_based": False,
    },
    {
        "_id": "q-main-expiry",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-main-counter",
        "text": "Хугацааны мэдээллийн төлөв ямар байна вэ?",
        "type": "dropdown",
        "options": ["Хэвийн", "Анхааруулах", "Дууссан"],
        "required": True,
        "order": 2,
        "product_class": None,
        "detection_based": False,
    },
    {
        "_id": "q-main-rating",
        "survey_id": "survey-beverage-execution",
        "group_id": "qg-main-counter",
        "text": "Үндсэн лангууны ерөнхий үнэлгээ хэд вэ?",
        "type": "rating",
        "options": [],
        "required": True,
        "order": 3,
        "product_class": None,
        "detection_based": False,
    },
    {
        "_id": "q-dairy-fridge-clean",
        "survey_id": "survey-dairy-freshness",
        "group_id": "qg-dairy-fridge",
        "text": "Сүүний хөргөгч цэвэрхэн байна уу?",
        "type": "yes_no",
        "options": [],
        "required": True,
        "order": 1,
        "product_class": None,
        "detection_based": False,
    },
    {
        "_id": "q-dairy-date-check",
        "survey_id": "survey-dairy-freshness",
        "group_id": "qg-dairy-price",
        "text": "Хугацаа нь дуусах дөхсөн сүү хэд байна вэ?",
        "type": "number",
        "options": [],
        "required": True,
        "order": 1,
        "product_class": "milk_1l",
        "detection_based": True,
    },
]

CAMPAIGNS = [
    {
        "_id": "campaign-coke-spring-2026",
        "name": "Coca-Cola Хаврын Аудит 2026",
        "description": "Ундааны байршуулалт, cash zone болон хөргөгчийн идэвхжил шалгах кампанит ажил",
        "start_date": NOW - timedelta(days=5),
        "end_date": NOW + timedelta(days=25),
        "survey_id": "survey-beverage-execution",
        "target_tradeshop_ids": [
            "shop-cu-peace",
            "shop-state-dept",
            "shop-tumen-huns",
            "shop-nomin-sansar",
            "shop-orgil-13",
        ],
        "is_active": True,
    },
    {
        "_id": "campaign-dairy-march-2026",
        "name": "Сүүний Хөргөлтийн Хяналт 2026",
        "description": "Сүүний хөргөгч, хугацаа, үнийн мэдээлэл шалгах кампанит ажил",
        "start_date": NOW - timedelta(days=3),
        "end_date": NOW + timedelta(days=18),
        "survey_id": "survey-dairy-freshness",
        "target_tradeshop_ids": [
            "shop-darkhan-nomin",
            "shop-erdenet-8",
            "shop-bosa-bz",
        ],
        "is_active": True,
    },
    {
        "_id": "campaign-archive-winter-2025",
        "name": "Өвлийн Архив Аудит 2025",
        "description": "Demo зорилгоор дууссан кампанит ажил",
        "start_date": NOW - timedelta(days=120),
        "end_date": NOW - timedelta(days=80),
        "survey_id": "survey-beverage-execution",
        "target_tradeshop_ids": [
            "shop-cu-peace",
            "shop-erdenet-8",
        ],
        "is_active": False,
    },
]

DETECTIONS = [
    {
        "_id": "det-cu-peace-1",
        "image_path": "data/uploads/demo/cu_peace_1.jpg",
        "tradeshop_id": "shop-cu-peace",
        "auditor_id": "auditor-bat-erdene",
        "campaign_id": "campaign-coke-spring-2026",
        "detections": [
            {"class_id": 0, "class_name": "coca_cola_500ml", "confidence": 0.96, "bbox": [44.0, 82.0, 188.0, 390.0]},
            {"class_id": 0, "class_name": "coca_cola_500ml", "confidence": 0.94, "bbox": [200.0, 88.0, 338.0, 392.0]},
            {"class_id": 1, "class_name": "fanta_orange", "confidence": 0.91, "bbox": [356.0, 104.0, 488.0, 386.0]},
        ],
        "total_products": 3,
        "processing_time_ms": 128.4,
        "timestamp": NOW - timedelta(days=1),
    },
    {
        "_id": "det-state-dept-1",
        "image_path": "data/uploads/demo/state_department_1.jpg",
        "tradeshop_id": "shop-state-dept",
        "auditor_id": "auditor-bat-erdene",
        "campaign_id": "campaign-coke-spring-2026",
        "detections": [
            {"class_id": 0, "class_name": "coca_cola_500ml", "confidence": 0.95, "bbox": [52.0, 76.0, 196.0, 402.0]},
            {"class_id": 2, "class_name": "sprite_500ml", "confidence": 0.89, "bbox": [212.0, 98.0, 350.0, 398.0]},
        ],
        "total_products": 2,
        "processing_time_ms": 141.7,
        "timestamp": NOW - timedelta(hours=16),
    },
]

AUDIT_RESPONSES = [
    {
        "_id": "resp-cu-peace-1",
        "campaign_id": "campaign-coke-spring-2026",
        "tradeshop_id": "shop-cu-peace",
        "auditor_id": "auditor-bat-erdene",
        "survey_id": "survey-beverage-execution",
        "detection_id": "det-cu-peace-1",
        "answers": [
            {"question_id": "q-cash-yes-no", "question_text": "Cash zone дээр Coca-Cola бүтээгдэхүүн байна уу?", "answer": "Тийм", "auto_answered": True},
            {"question_id": "q-cash-count", "question_text": "Cash zone дээр хэдэн Coca-Cola бүтээгдэхүүн байна вэ?", "answer": 2, "auto_answered": True},
            {"question_id": "q-extra-shelf-exists", "question_text": "Нэмэлт тавиур дээр Fanta байна уу?", "answer": "Тийм", "auto_answered": True},
            {"question_id": "q-main-price-label", "question_text": "Үнийн шошго бүрэн байна уу?", "answer": "Тийм", "auto_answered": False},
            {"question_id": "q-main-expiry", "question_text": "Хугацааны мэдээллийн төлөв ямар байна вэ?", "answer": "Хэвийн", "auto_answered": False},
            {"question_id": "q-main-rating", "question_text": "Үндсэн лангууны ерөнхий үнэлгээ хэд вэ?", "answer": 4, "auto_answered": False},
        ],
        "photos": [
            "data/uploads/demo/cu_peace_1.jpg",
            "data/uploads/demo/cu_peace_2.jpg",
        ],
        "location": {"lat": 47.9183, "lng": 106.9170, "accuracy": 8.4},
        "notes": "Cash zone дээрх Coca-Cola facing сайн, үнийн шошго бүрэн байна.",
        "status": "completed",
        "submitted_at": NOW - timedelta(days=1),
        "created_at": NOW - timedelta(days=1),
    },
    {
        "_id": "resp-state-dept-1",
        "campaign_id": "campaign-coke-spring-2026",
        "tradeshop_id": "shop-state-dept",
        "auditor_id": "auditor-bat-erdene",
        "survey_id": "survey-beverage-execution",
        "detection_id": "det-state-dept-1",
        "answers": [
            {"question_id": "q-cash-yes-no", "question_text": "Cash zone дээр Coca-Cola бүтээгдэхүүн байна уу?", "answer": "Тийм", "auto_answered": True},
            {"question_id": "q-fridge-count", "question_text": "Sprite бүтээгдэхүүнтэй хөргөгч хэд байна вэ?", "answer": 1, "auto_answered": True},
            {"question_id": "q-main-price-label", "question_text": "Үнийн шошго бүрэн байна уу?", "answer": "Үгүй", "auto_answered": False},
            {"question_id": "q-main-expiry", "question_text": "Хугацааны мэдээллийн төлөв ямар байна вэ?", "answer": "Анхааруулах", "auto_answered": False},
            {"question_id": "q-main-rating", "question_text": "Үндсэн лангууны ерөнхий үнэлгээ хэд вэ?", "answer": 3, "auto_answered": False},
        ],
        "photos": [
            "data/uploads/demo/state_department_1.jpg",
        ],
        "location": {"lat": 47.9191, "lng": 106.9179, "accuracy": 9.1},
        "notes": "Үнийн шошго хэсэгчлэн дутуу байсан тул follow-up шаардлагатай.",
        "status": "completed",
        "submitted_at": NOW - timedelta(hours=16),
        "created_at": NOW - timedelta(hours=16),
    },
]


async def upsert_many(collection, documents):
    """Upsert a list of documents by _id."""
    for document in documents:
        payload = {**document, "demo_seed": True}
        await collection.replace_one({"_id": payload["_id"]}, payload, upsert=True)


async def main():
    client = AsyncIOMotorClient(settings.MONGODB_URI, serverSelectionTimeoutMS=5000)
    try:
        await client.admin.command("ping")
    except Exception as exc:
        raise RuntimeError(f"MongoDB connection failed: {exc}") from exc

    db = client[settings.MONGODB_DB_NAME]

    groups_collection = db["groups"]
    categories_collection = db["categories"]
    auditors_collection = db["auditors"]
    tradeshops_collection = db["tradeshops"]
    surveys_collection = db["surveys"]
    question_groups_collection = db["question_groups"]
    questions_collection = db["questions"]
    campaigns_collection = db["campaigns"]
    detections_collection = db["detections"]
    audit_responses_collection = db["audit_responses"]

    await upsert_many(
        groups_collection,
        [
            {
                **item,
                "created_at": NOW,
            }
            for item in GROUPS
        ],
    )

    await upsert_many(
        categories_collection,
        [
            {
                "_id": item_id,
                "name": name,
                "type": "product",
                "description": f"{name} төрлийн бүтээгдэхүүний ангилал",
                "created_at": NOW,
            }
            for item_id, name in PRODUCT_CATEGORIES
        ]
        + [
            {
                "_id": item_id,
                "name": name,
                "type": "tradeshop",
                "description": f"{name} төрлийн дэлгүүрийн ангилал",
                "created_at": NOW,
            }
            for item_id, name in TRADESHOP_CATEGORIES
        ],
    )

    await upsert_many(
        auditors_collection,
        [
            {
                "_id": item["_id"],
                "name": item["name"],
                "phone": item["phone"],
                "email": item["email"],
                "group_id": item["group_id"],
                "is_active": True,
                "is_admin": item["is_admin"],
                "password_hash": hash_password(item["password"]),
                "created_at": NOW,
                "updated_at": NOW,
            }
            for item in AUDITORS
        ],
    )

    await upsert_many(
        tradeshops_collection,
        [
            {
                **item,
                "is_active": True,
                "created_at": NOW,
                "updated_at": NOW,
            }
            for item in TRADESHOPS
        ],
    )

    await upsert_many(
        surveys_collection,
        [
            {
                **item,
                "is_active": True,
                "created_at": NOW,
                "updated_at": NOW,
            }
            for item in SURVEYS
        ],
    )

    await upsert_many(
        question_groups_collection,
        [
            {
                **item,
                "created_at": NOW,
                "updated_at": NOW,
            }
            for item in QUESTION_GROUPS
        ],
    )

    await upsert_many(
        questions_collection,
        [
            {
                **item,
                "created_at": NOW,
            }
            for item in QUESTIONS
        ],
    )

    await upsert_many(
        campaigns_collection,
        [
            {
                **item,
                "created_at": NOW,
                "updated_at": NOW,
            }
            for item in CAMPAIGNS
        ],
    )

    await upsert_many(detections_collection, DETECTIONS)
    await upsert_many(audit_responses_collection, AUDIT_RESPONSES)

    summary = {
        "database": settings.MONGODB_DB_NAME,
        "seeded_at": NOW.isoformat(),
        "admin": {
            "phone": "99999999",
            "password": "admin123",
        },
        "mobile_demo_user": {
            "name": "Бат-Эрдэнэ",
            "phone": "88001122",
            "password": "audit123",
        },
        "ids": {
            "group_id": "group-ub-central",
            "campaign_id": "campaign-coke-spring-2026",
            "survey_id": "survey-beverage-execution",
            "tradeshop_id": "shop-cu-peace",
            "response_id": "resp-cu-peace-1",
            "question_id": "q-cash-yes-no",
        },
        "counts": {
            "groups": len(GROUPS),
            "categories": len(PRODUCT_CATEGORIES) + len(TRADESHOP_CATEGORIES),
            "auditors": len(AUDITORS),
            "tradeshops": len(TRADESHOPS),
            "surveys": len(SURVEYS),
            "question_groups": len(QUESTION_GROUPS),
            "questions": len(QUESTIONS),
            "campaigns": len(CAMPAIGNS),
            "audit_responses": len(AUDIT_RESPONSES),
        },
    }

    output_path = Path("data/demo_seed_summary.json")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2))

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    client.close()


if __name__ == "__main__":
    asyncio.run(main())
