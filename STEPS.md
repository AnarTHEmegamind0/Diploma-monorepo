# STEPS.md — Хэрэгжүүлэлтийн Төлөвлөгөө

> **Дипломын ажил: Image-Based Product Recognition & Automated Audit Decision System**
>
> Энэ файлд төслийг бүрэн хэрэгжүүлэх алхмууд байна.
> Алхам бүрийг дарааллаар нь хийнэ.

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

| ID | Нэр | Тайлбар |
|----|-----|---------|
| 0 | bonaqua_500ml | Бонаква ус |
| 1 | coca_cola_500ml | Кока-Кола |
| 2 | fanta_500ml | Фанта (бүх өнгө) |
| 3 | sprite_500ml | Спрайт |

---

## ҮЕ ШАТ 1: BACKEND & FRONTEND ✅ ДУУССАН

Эдгээр бүгд хийгдсэн:

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

### Алхам 1 ✅ — Зураг цуглуулах

**Хийсэн:**
- 96 зураг авсан (iPhone HEIC format)
- HEIC → JPG хөрвүүлсэн (`sips` command)
- `data/raw/` хавтаст хадгалсан

---

### Алхам 2 ✅ — Roboflow ашиглан Auto-Label

**Хийсэн:**
- LabelImg Python 3.12 дээр ажиллахгүй болсон (PyQt5 compatibility)
- Roboflow.com дээр зураг upload хийсэн
- SAM3 (Segment Anything Model) ашиглан auto-label хийсэн
- 4 class: bonaqua, coca_cola, fanta, sprite

**Тэмдэглэл:**
- Fanta бүх өнгө (улбар шар, ягаан, ногоон) нэг class болгосон
- Roboflow polygon/segmentation format-аар export хийдэг

---

### Алхам 3 ✅ — Roboflow Export татах

**Хийсэн:**
- YOLOv8 format-аар export хийсэн
- `ProductDetection.yolov8/` хавтаст татсан
- Зөвхөн `train/` folder ирсэн (val/test байхгүй)

---

### Алхам 4 ✅ — Polygon → Bounding Box хөрвүүлэх

**Хийсэн:**
- `scripts/convert_polygon_to_bbox.py` script бичсэн
- Roboflow polygon labels → YOLO bounding box format

---

### Алхам 5 ✅ — Dataset хуваах (Train/Val/Test)

**Хийсэн:**
- `scripts/split_roboflow_dataset.py` script бичсэн
- 70/20/10 хуваалт (seed=42 reproducibility)

**Үр дүн:**
```
data/splits/
├── train/images/  (67 зураг - 70%)
├── train/labels/  (67 label файл)
├── val/images/    (19 зураг - 20%)
├── val/labels/    (19 label файл)
├── test/images/   (10 зураг - 10%)
└── test/labels/   (10 label файл)
```

---

### Алхам 6 ✅ — Dataset Config шинэчлэх

**Хийсэн:**
- `models/configs/dataset.yaml` файл 4 class-д тохируулан шинэчлэгдсэн
- Class дараалал Roboflow-тэй таарсан (bonaqua=0, coca_cola=1, fanta=2, sprite=3)

---

### Алхам 7 ✅ — Training Scripts бэлтгэх

**Хийсэн:**
- `scripts/train_rtx3070.py` - RTX 3070 training script
- `scripts/test_model.py` - Model тест хийх script
- `WINDOWS_TRAINING_GUIDE.md` - Бүрэн заавар

---

## ҮЕ ШАТ 3: MODEL СУРГАХ 🔄 ОДОО ХИЙХ

### Алхам 8 ⬜ — Windows руу хуулах

**Хийх:**
1. Project folder-ийг USB/Cloud-аар хуулах
2. Шаардлагатай файлууд:
   - `data/splits/` (бүх train/val/test)
   - `models/configs/dataset.yaml`
   - `scripts/train_rtx3070.py`
   - `scripts/test_model.py`
   - `requirements.txt`

---

### Алхам 9 ⬜ — Windows Environment бэлтгэх

**Хийх:**
```cmd
# Python 3.10+ суулгах
python --version

# Virtual environment үүсгэх
python -m venv venv
venv\Scripts\activate.bat

# Dependencies суулгах
pip install ultralytics torch torchvision opencv-python

# CUDA шалгах
python -c "import torch; print(torch.cuda.is_available())"
```

---

### Алхам 10 ⬜ — Model сургах (RTX 3070)

**Хийх:**
```cmd
cd inventory_project
venv\Scripts\activate.bat
python scripts/train_rtx3070.py
```

**Хүлээгдэж буй:**
- Хугацаа: ~8-10 минут
- Output: `models/weights/product_detector_4class/weights/best.pt`

---

### Алхам 11 ⬜ — Model үнэлэх

**Хийх:**
```cmd
python scripts/test_model.py --evaluate
```

**Хүлээгдэж буй үр дүн:**
- mAP@50: 0.70+
- Precision: 0.75+
- Recall: 0.70+

---

### Алхам 12 ⬜ — Model шалгах (Inference test)

**Хийх:**
```cmd
python scripts/test_model.py --image data/splits/test/images/IMG_0001.jpg
```

---

## ҮЕ ШАТ 4: BACKEND ХОЛБОЛТ

### Алхам 13 ⬜ — Model Mac руу хуулах

**Хийх:**
- `models/weights/product_detector_4class/weights/best.pt` файлыг Mac руу хуулах

---

### Алхам 14 ⬜ — .env тохируулах

```bash
cp .env.example .env

# MODEL_PATH засах:
# MODEL_PATH=models/weights/product_detector_4class/weights/best.pt
```

---

### Алхам 15 ⬜ — Detection route идэвхжүүлэх

**Хийх:**
- `backend/app/routes/detection.py` дээр `ProductDetector` import-ийг uncomment хийх
- Placeholder код устгах

---

### Алхам 16 ⬜ — Backend эхлүүлэх ба туршиж үзэх

```bash
source inventory_env/bin/activate
uvicorn backend.app.main:app --reload --port 8000

# API туршиж үзэх:
curl -X POST http://localhost:8000/api/detection/detect \
  -F "file=@data/splits/test/images/IMG_0001.jpg"
```

---

## ҮЕ ШАТ 5: БҮРЭН ТЕСТ

### Алхам 17 ⬜ — Unit tests

```bash
pytest tests/ -v
```

---

### Алхам 18 ⬜ — Flutter app тест

1. Login (88001122 / audit123)
2. Campaign сонгох
3. Tradeshop сонгох
4. Survey бөглөх
5. Зураг авах → Detection!
6. Submit

---

## ҮЕ ШАТ 6: DOCUMENTATION

### Алхам 19 ⬜ — Screenshot авах

- Flutter app screens
- React dashboard
- Detection results

---

### Алхам 20 ⬜ — Thesis засварлах

- Бодит model metrics оруулах (4 class, 96 images)
- Screenshot нэмэх

---

### Алхам 21 ⬜ — Demo video бэлтгэх

---

## Түргэн Commands

```bash
# === Mac Setup ===
source inventory_env/bin/activate

# === Backend ===
uvicorn backend.app.main:app --reload --port 8000

# === Tests ===
pytest tests/ -v

# === Flutter ===
cd application && flutter run

# === Windows Training ===
venv\Scripts\activate.bat
python scripts/train_rtx3070.py
python scripts/test_model.py --evaluate
```

---

## Файлын Байршил

| Юу | Хаана |
|----|-------|
| Raw зураг | `data/raw/` |
| Train/Val/Test | `data/splits/` |
| Roboflow export | `ProductDetection.yolov8/` |
| Dataset config | `models/configs/dataset.yaml` |
| Training script | `scripts/train_rtx3070.py` |
| Test script | `scripts/test_model.py` |
| Model weights | `models/weights/product_detector_4class/weights/best.pt` |
| Windows заавар | `WINDOWS_TRAINING_GUIDE.md` |

---

## Өмнөх ажилд тохиолдсон асуудлууд

| Асуудал | Шийдэл |
|---------|--------|
| LabelImg Python 3.12-д ажиллахгүй | Roboflow auto-label ашигласан |
| HEIC зураг format | `sips` command ашиглан JPG болгосон |
| Roboflow polygon format | `convert_polygon_to_bbox.py` script бичсэн |
| Roboflow зөвхөн train folder export | `split_roboflow_dataset.py` script бичсэн |
