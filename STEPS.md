# STEPS.md — Хэрэгжүүлэлтийн Төлөвлөгөө

> **Дипломын ажил: Image-Based Product Recognition & Automated Audit Decision System**
>
> **Сүүлд шинэчлэгдсэн:** 2026-04-18
> **Статус:** УРЬДЧИЛСАН ХАМГААЛАЛТ МАРГААШ

---

## СИСТЕМИЙН БҮРЭН БАЙДАЛ

| Хэсэг | Статус | Хувь |
|-------|--------|------|
| Backend API | ✅ Бэлэн | 98% |
| Flutter App | ✅ Бэлэн | 95% |
| Detection Integration | ✅ Бэлэн | 100% |
| Model Training | ⚠️ Dataset цөөн | 50% |
| Infrastructure | ⚠️ Тест дутуу | 60% |

---

## ҮЕ ШАТ 1: BACKEND & FRONTEND ✅ ДУУССАН

- ✅ FastAPI backend бүтэц (12 route module)
- ✅ MongoDB холболт (Motor async driver)
- ✅ Authentication (JWT, bcrypt)
- ✅ Auditor, Group, Category, Tradeshop CRUD
- ✅ Campaign, Survey, Question, Question Groups CRUD
- ✅ Mobile API endpoints (`/api/mobile/*`)
- ✅ Audit submission with photos + detection
- ✅ Auto-answer logic (detection → survey answers)
- ✅ React Dashboard
- ✅ Flutter Mobile App
- ✅ Demo seed data

---

## ҮЕ ШАТ 2: ӨГӨГДӨЛ БЭЛТГЭХ ⚠️ ХИЙГДЭЖ БАЙГАА

- ✅ 96 зураг авсан (iPhone)
- ✅ Roboflow SAM3 auto-label хийсэн
- ✅ Train/Val/Test хуваасан (70/20/10)
- ⬜ **920+ зураг нэмэх** (өнөөдөр хийх)
- ⬜ **Roboflow дээр label хийх**

### Одоогийн Dataset:

| Ангилал | Annotations | Статус |
|---------|-------------|--------|
| bonaqua_500ml | 74 | ⚠️ Цөөн |
| coca_cola_500ml | 376 | ✅ Хангалттай |
| fanta_500ml | 171 | ✅ Хангалттай |
| sprite_500ml | 76 | ⚠️ Цөөн |

---

## ҮЕ ШАТ 3: MODEL СУРГАХ ⚠️ ДАХИН СУРГАХ

- ✅ Windows RTX 3070 дээр сургасан
- ✅ YOLOv8n, 50 epochs, batch=16, imgsz=640
- ✅ Model weights: `models/weights/product_detector/weights/best.pt`
- ⬜ **Дахин сургах** (100 epochs, 200+ зураг)

### Одоогийн Үр Дүн:

| Metric | Одоо | Зорилго |
|--------|------|---------|
| mAP50 | 49.7% | > 70% |
| mAP50-95 | 28.0% | > 50% |
| Precision | 45.3% | > 80% |
| Recall | 52.9% | > 80% |

---

## ҮЕ ШАТ 4: BACKEND ХОЛБОЛТ ✅ ДУУССАН

- ✅ Detection endpoint (`/api/detection/detect`)
- ✅ Detection history endpoint
- ✅ Detection status endpoint (`/api/detection/status`)
- ✅ Model loading (lazy load, singleton)
- ✅ MongoDB хадгалалт
- ✅ Auto-answer endpoint (`/api/audit-submit/submit`)
- ✅ Audit result logic (`pass / warning / fail`)
- ✅ Campaign stats тооцоолол
- ✅ Mobile API бүрэн

---

## ҮЕ ШАТ 5: FLUTTER INTEGRATION ✅ ДУУССАН

- ✅ Detection model (`detection_result.dart`)
- ✅ Detection repository layer
- ✅ Detection service (`detection_service.dart`)
- ✅ Detection provider (`detection_provider.dart`)
- ✅ Detection widget (`detection_result_widget.dart`)
- ✅ ImagePage detection integration
- ✅ Auto-fill answers from detection
- ✅ Provider registration

---

## ҮЕ ШАТ 6: THESIS & DOCUMENTATION ✅ ДУУССАН

- ✅ LaTeX thesis бүтэц бэлэн
- ✅ Sections бичсэн (introduction, methodology, implementation, evaluation)
- ✅ Screenshots авсан
- ✅ Architecture diagrams
- ✅ Notebooks (model analysis, inference demo)

---

## ҮЕ ШАТ 7: ХАМГААЛАЛТ БЭЛТГЭЛ 🔄 ОДОО

### Техникийн Бэлтгэл:
- ✅ Backend ажиллаж байна
- ✅ Flutter app ажиллаж байна
- ✅ Detection API холбогдсон
- ⬜ Model сайжруулах (зураг нэмсний дараа)

### Хамгаалалтад:
- ⬜ Demo ажиллуулах
- ⬜ Presentation
- ⬜ Асуултад хариулах

---

## YOLOV8 MODEL ТЕХНИКИЙН МЭДЭЭЛЭЛ

### Architecture: YOLOv8n (Nano)
- Backbone: CSPDarknet
- Neck: PANet (FPN)
- Head: Decoupled Head (anchor-free)

### Loss Functions:
| Loss | Нэр | Тайлбар |
|------|-----|---------|
| box_loss | CIoU Loss | Bounding box regression |
| cls_loss | BCE + Focal | Classification loss |
| dfl_loss | Distribution Focal Loss | Regression distribution |

### Detection Pipeline:
```python
from ultralytics import YOLO
model = YOLO("models/weights/product_detector/weights/best.pt")
results = model(image, conf=0.25, iou=0.45)
```

---

## ТҮРГЭН COMMANDS

```bash
# Backend эхлүүлэх
cd backend && uvicorn app.main:app --reload --port 8000

# Flutter app
cd application && flutter run

# Model test
python scripts/test_model.py --evaluate

# Model сургах (Windows)
python scripts/train_rtx3070.py --epochs 100 --batch 16
```

---

## АСУУЛТАД БЭЛДЭХ

| Асуулт | Хариулт |
|--------|---------|
| Яагаад YOLOv8? | Real-time detection, anchor-free, SOTA, easy deploy |
| mAP 49.7% бага биш үү? | PoC-д хангалттай. Production-д: 200+ зураг, YOLOv8s, 100 epochs |
| Loss function? | CIoU (box), Focal (cls), DFL (regression) |
| Real-time хурд? | ~15-20ms (RTX 3070), ~50ms (CPU) |
| Өөр бүтээгдэхүүн нэмэхэд? | Roboflow-д class нэмж, retrain хийнэ |

---

**Зохиогч:** Түвшинжаргал Анар
**Удирдагч:** Рэнцэндорж Жавхлан
**МУИС, МХТС, 2026**
