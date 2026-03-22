# Дипломын Ажлын Заавар

## Төслийн Тойм

**Нэр:** Image-Based Product Recognition & Automated Audit Decision System  
**Зорилго:** Дэлгүүрийн тавиурын зураг дээрээс бүтээгдэхүүн автоматаар таньж, аудит хийх систем

## Системийн Архитектур

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│   FastAPI       │────▶│   YOLOv8        │
│   (Auditor)     │     │   Backend       │     │   ML Model      │
└─────────────────┘     └────────┬────────┘     └─────────────────┘
                                 │
                        ┌────────▼────────┐
                        │    MongoDB      │
                        │   Database      │
                        └─────────────────┘
```

## Үе Шатууд

| Үе шат | Нэр | Хугацаа | Статус |
|--------|-----|---------|--------|
| Phase 1 | Bug Fixes | 1 өдөр | ✅ ДУУССАН |
| Phase 2 | Data Collection | 2-3 өдөр | ⬜ ХИЙГДЭЭГҮЙ |
| Phase 3 | Model Training | 1-2 өдөр | ⬜ ХИЙГДЭЭГҮЙ |
| Phase 4 | Backend Integration | 1 өдөр | 🔄 ХАГАС |
| Phase 5 | Frontend UI | 2 өдөр | ✅ ДУУССАН |
| Phase 6 | End-to-End Testing | 1 өдөр | ⬜ ХИЙГДЭЭГҮЙ |
| Phase 7 | Docker Deployment | 1 өдөр | ⬜ ХИЙГДЭЭГҮЙ |
| Phase 8 | Documentation | 1 өдөр | ⬜ ХИЙГДЭЭГҮЙ |

## Заавар Файлууд

1. `01_DATA_COLLECTION.md` - Зураг цуглуулах заавар
2. `02_LABELING.md` - LabelImg ашиглан label хийх
3. `03_TRAINING.md` - YOLOv8 model сургах
4. `04_INTEGRATION.md` - Backend-тай холбох
5. `05_TESTING.md` - Бүрэн тест хийх
6. `06_DEPLOYMENT.md` - Docker-ээр deploy хийх
7. `07_DOCUMENTATION.md` - Thesis бичих

## Өнөөдрийн Ажил

Хамгийн эхэнд `01_DATA_COLLECTION.md` уншиж, зураг цуглуулж эхэлнэ.
