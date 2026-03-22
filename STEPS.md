# STEPS.md — Хэрэгжүүлэлтийн Төлөвлөгөө

> **Дипломын ажил: Image-Based Product Recognition & Automated Audit Decision System**
>
> **Сүүлд шинэчлэгдсэн:** 2026-03-22
> **Статус:** Хамгаалалтад бэлтгэж байна

---

## Төлөв

- ✅ = Дууссан
- 🔄 = Хийгдэж байгаа
- ⬜ = Хийгдээгүй

---

## Одоогийн Dataset (Roboflow-оос)

| Үзүүлэлт | Утга |
|----------|------|
| Нийт зураг | 96 |
| Train set | 67 (70%) |
| Val set | 19 (20%) |
| Test set | 10 (10%) |
| Ангиллын тоо | 4 |
| Нийт annotation | 684 |

### 4 Ангилал (Roboflow дараалал):

| ID | Нэр | Annotations | Статус |
|----|-----|-------------|--------|
| 0 | bonaqua_500ml | 74 | ⚠️ Цөөн |
| 1 | coca_cola_500ml | 376 | ✅ Хангалттай |
| 2 | fanta_500ml | 171 | ✅ Хангалттай |
| 3 | sprite_500ml | 76 | ⚠️ Цөөн |

---

## ҮЕ ШАТ 1: BACKEND & FRONTEND ✅ ДУУССАН

- ✅ FastAPI backend бүтэц
- ✅ MongoDB холболт
- ✅ Authentication (JWT)
- ✅ Auditor, Group, Category, Tradeshop CRUD
- ✅ Campaign, Survey, Question CRUD
- ✅ Question Groups (Survey доторх бүлгүүд)
- ✅ Mobile API endpoints (`/api/mobile/*`)
- ✅ Audit submission with photos
- ✅ React Dashboard (Login, Campaigns, Surveys, SurveyBuilder, etc.)
- ✅ Flutter Mobile App (Login, Campaigns, Tradeshops, Survey, Photo capture)
- ✅ Demo seed data

---

## ҮЕ ШАТ 2: ӨГӨГДӨЛ БЭЛТГЭХ ✅ ДУУССАН

- ✅ 96 зураг авсан (iPhone)
- ✅ Roboflow SAM3 auto-label хийсэн
- ✅ Polygon → Bounding Box хөрвүүлсэн
- ✅ Train/Val/Test хуваасан (70/20/10)
- ✅ `data/splits/` хавтас бэлэн

---

## ҮЕ ШАТ 3: MODEL СУРГАХ ✅ ДУУССАН

- ✅ Windows RTX 3070 дээр сургасан
- ✅ YOLOv8n, 50 epochs, batch=16, imgsz=640
- ✅ Model weights: `models/weights/product_detector/weights/best.pt`

### Training Үр Дүн:

| Metric | Утга | Зорилго |
|--------|------|---------|
| mAP50 | 49.7% | > 70% |
| mAP50-95 | 28.0% | > 50% |
| Precision | 45.3% | > 80% |
| Recall | 52.9% | > 80% |

**Тэмдэглэл:** Үр дүн хангалттай биш, гэхдээ хамгаалалтад хүрэлцэнэ. Сайжруулах арга доор.

---

## ҮЕ ШАТ 4: BACKEND ХОЛБОЛТ 🔄 ХАГАС

- ✅ Detection endpoint бэлэн (`/api/detection/detect`)
- ✅ Model path тохируулсан
- ✅ .env файл бэлэн
- ⬜ Auto-answer logic холбох
- ⬜ End-to-end тест хийх

---

## ҮЕ ШАТ 5: NOTEBOOKS ✅ ДУУССАН

- ✅ `01_model_analysis.ipynb` - Training analysis
- ✅ `02_inference_demo.ipynb` - Inference demo
- ✅ Thesis график үүсгэсэн (`thesis_*.png`)

---

## ҮЕ ШАТ 6: THESIS & DOCUMENTATION 🔄 ХАГАС

- ✅ LaTeX thesis бүтэц бэлэн
- ✅ Sections бичсэн (introduction, methodology, implementation)
- ✅ Screenshots авсан
- ✅ Architecture diagrams
- ⬜ Final review хийх
- ⬜ PDF compile хийх

---

## ҮЕ ШАТ 7: ХАМГААЛАЛТ БЭЛТГЭЛ 🔄 ОДОО ХИЙХ

### A. PPT Бэлдэх (Яаралтай!)

**Файл:** `docs/ppt_making.md` (дээр үүсгэсэн)

**PPT Бүтэц (30 хуудас):**
```
1. Нүүр хуудас (1)
2. Агуулга (1)
3. Асуудал тодорхойлолт (2)
4. Зорилго, зорилт (2)
5. Онолын үндэс (4)
   - Computer Vision
   - Object Detection
   - YOLO Architecture
6. Системийн архитектур (3)
7. Технологиуд (2)
8. Dataset бэлтгэл (3)
9. Model сургалт (4)
10. Backend хөгжүүлэлт (2)
11. Frontend/Mobile (2)
12. Үр дүн & Demo (3)
13. Дүгнэлт (1)
```

### B. Demo Бэлдэх

- ⬜ Backend + Frontend ажиллуулах
- ⬜ Detection demo харуулах
- ⬜ Mobile app demo

### C. Асуултад Бэлдэх

Хамгаалалтын үед асуух боломжтой асуултууд:
1. "Яагаад YOLOv8 сонгосон бэ?"
2. "Dataset хэрхэн цуглуулсан бэ?"
3. "mAP 49.7% бага биш үү? Яаж сайжруулах вэ?"
4. "Real-time inference хурд?"
5. "Өөр бүтээгдэхүүн нэмэхэд яах вэ?"

---

## Model Дахин Сургах Зөвлөмж

### Асуудал
1. **Sprite, Bonaqua цөөн** - тус бүр ~75 annotation
2. **mAP50 = 49.7%** - хангалтгүй (зорилго 70%+)
3. **Epochs = 50** - илүү олон хэрэгтэй

### Сайжруулах Арга

#### Арга 1: Илүү олон зураг нэмэх
```
Roboflow дээр:
- Sprite зураг 50+ нэмэх
- Bonaqua зураг 50+ нэмэх
- Re-annotate
- Export YOLO format
```

#### Арга 2: Илүү олон epochs
```python
# scripts/train_rtx3070.py
model.train(
    data='models/configs/dataset.yaml',
    epochs=100,           # 50 → 100
    batch=16,
    imgsz=640,
    augment=True,
)
```

#### Арга 3: Илүү том model
```python
from ultralytics import YOLO
model = YOLO('yolov8s.pt')  # 's' instead of 'n'
```

### Дахин Сургах Command
```bash
# Windows RTX 3070
cd inventory_project
python scripts/train_rtx3070.py

# Шинэ model-ийг Mac руу хуулах:
# models/weights/product_detector_v2/weights/best.pt
```

---

## Folder Structure (Зөв)

```
inventory_project/
├── data/
│   └── splits/              ✅ Dataset (200 files)
├── models/
│   ├── configs/
│   │   └── dataset.yaml     ✅ 4 class config
│   └── weights/
│       └── product_detector/
│           ├── weights/
│           │   ├── best.pt  ✅ Best model (5.9 MB)
│           │   └── last.pt  ✅ Last checkpoint
│           ├── results.csv  ✅ Training metrics
│           └── thesis_*.png ✅ Thesis graphics
├── src/
│   ├── training/            ✅ Training код
│   └── inference/           ✅ Inference код
├── backend/                 ✅ FastAPI
├── frontend/                ✅ React
├── application/             ✅ Flutter
├── notebooks/               ✅ Analysis (2 notebooks)
├── latex/                   ✅ Thesis
├── instructions/            ✅ 10 guide files
├── scripts/                 ✅ Utilities
├── tests/                   ✅ Tests
├── docs/                    📁 Documentation
│   └── ppt_making.md        ✅ PPT prompts
├── STEPS.md                 ✅ Энэ файл
├── PROGRESS.md              ✅ Явцын тайлан
└── README.md                ✅ Project overview
```

---

## Түргэн Commands

```bash
# Backend эхлүүлэх
cd backend && uvicorn app.main:app --reload --port 8000

# Frontend эхлүүлэх
cd frontend && npm start

# Flutter app
cd application && flutter run

# Model test
python scripts/test_model.py --evaluate

# Notebooks
cd notebooks && jupyter notebook
```

---

## Хамгаалалтын Checklist

- [ ] PPT 30 хуудас бэлэн
- [ ] LaTeX thesis PDF
- [ ] Demo ажиллаж байгаа
- [ ] Асуултуудад бэлтгэсэн
- [ ] Presentation дасгал хийсэн

---

**Зохиогч:** Түвшинжаргал Анар
**Удирдагч:** Рэнцэндорж Жавхлан
**МУИС, МХТС, 2026**
