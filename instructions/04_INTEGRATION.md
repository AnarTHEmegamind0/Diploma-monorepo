# Phase 4: Backend-тай Холбох Заавар

## Зорилго

Сургаж дуусаад model-ийг FastAPI backend-тай холбож, 
Flutter app-аас зураг илгээхэд автоматаар detection хийх.

---

## Урьдчилсан Нөхцөл

1. ✅ Model сургаж дууссан
2. ✅ `models/weights/product_detector/weights/best.pt` байгаа
3. ✅ MongoDB ажиллаж байгаа
4. ✅ Backend сервер ажиллаж байгаа

---

## Алхам 1: .env файл тохируулах

`.env` файл үүсгэх эсвэл засах:

```bash
# .env.example-ээс хуулах
cp .env.example .env

# Засах
nano .env   # эсвэл code .env
```

**.env файлын агуулга:**

```env
# MongoDB
MONGODB_URI=mongodb://localhost:27017
MONGODB_DB_NAME=inventory_audit

# API Server
API_HOST=0.0.0.0
API_PORT=8000
API_DEBUG=true

# YOLO Model - ЧУХАЛ!
MODEL_PATH=models/weights/product_detector/weights/best.pt
CONFIDENCE_THRESHOLD=0.25
IOU_THRESHOLD=0.45

# Audit Thresholds
AUDIT_TOLERANCE=0.1
AUDIT_CRITICAL_THRESHOLD=0.3

# File Upload
UPLOAD_DIR=data/uploads
MAX_UPLOAD_SIZE=10485760

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

---

## Алхам 2: Model ачаалагдаж байгаа эсэхийг шалгах

```bash
# Virtual environment идэвхжүүлэх
source inventory_env/bin/activate

# Model шалгах
python -c "
from backend.app.services.detection_service import DetectionService
detector = DetectionService.get_detector()
if detector:
    print('✅ Model амжилттай ачаалагдлаа!')
else:
    print('❌ Model олдсонгүй. MODEL_PATH шалгана уу.')
"
```

---

## Алхам 3: Backend сервер эхлүүлэх

```bash
# Сервер эхлүүлэх
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
```

**Үр дүн:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [12345]
INFO:     Started server process [12346]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

---

## Алхам 4: Detection API туршиж үзэх

### Terminal-аас:

```bash
# Test зураг илгээх
curl -X POST http://localhost:8000/api/detection/detect \
  -F "file=@data/splits/test/images/test_image.jpg"
```

### Swagger UI-аас:

1. Browser нээж `http://localhost:8000/docs` руу орох
2. `POST /api/detection/detect` endpoint олох
3. "Try it out" дарах
4. Зураг сонгоод "Execute" дарах

---

## Алхам 5: Хүлээгдэж буй хариу

**Амжилттай detection:**
```json
{
  "detection_id": "abc123",
  "image_path": "data/uploads/image_001.jpg",
  "timestamp": "2026-03-18T10:30:00",
  "detections": [
    {
      "class_id": 0,
      "class_name": "coca_cola",
      "confidence": 0.92,
      "bbox": [120, 50, 280, 350]
    },
    {
      "class_id": 1,
      "class_name": "fanta",
      "confidence": 0.87,
      "bbox": [300, 55, 460, 355]
    }
  ],
  "total_products": 2,
  "processing_time_ms": 145.5
}
```

**Model байхгүй үед:**
```json
{
  "image_path": "data/uploads/image_001.jpg",
  "timestamp": "2026-03-18T10:30:00",
  "detections": [],
  "total_products": 0,
  "processing_time_ms": 0,
  "message": "Model not loaded. Train a model first."
}
```

---

## Алхам 6: Flutter App-тай холболт шалгах

### 1. Backend ажиллаж байгаа эсэх:

```bash
curl http://localhost:8000/health
# {"status": "healthy"}
```

### 2. Flutter app эхлүүлэх:

```bash
cd application
flutter run
```

### 3. App дээр:
1. Нэвтрэх (88001122 / audit123)
2. Campaign сонгох
3. Tradeshop сонгох
4. Зураг авах → Detection ажиллана!

---

## Detection Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Flutter App │────▶│   FastAPI   │────▶│   YOLOv8    │
│ (Зураг авах)│     │  Backend    │     │   Model     │
└─────────────┘     └──────┬──────┘     └─────────────┘
                           │
                    ┌──────▼──────┐
                    │   MongoDB   │
                    │ (хадгалах)  │
                    └─────────────┘
```

---

## Алхам 7: Auto-answer тохируулах

Survey-ийн асуултууд detection-д суурилж автоматаар хариулагдана.

### Question model дахь detection холболт:

```json
{
  "text": "Coca-Cola хэдэн ширхэг байна вэ?",
  "type": "number",
  "detection_based": true,
  "product_class": "coca_cola"
}
```

### Backend дээр auto-answer logic:

Detection хийгдсэний дараа:
1. `detection_based: true` асуултуудыг олно
2. `product_class` дагуу detection тоолно
3. Автоматаар хариу бөглөнө

---

## Түгээмэл Асуудлууд

### 1. "Model not loaded"

**Шалгах:**
```bash
ls -la models/weights/product_detector/weights/best.pt
```

**Шийдэл:** MODEL_PATH зөв эсэхийг .env дээр шалгах

### 2. "Detection буцаахгүй"

**Шалгах:**
```bash
# Backend log харах
uvicorn backend.app.main:app --reload --log-level debug
```

### 3. "Processing time хэт удаан"

**Шийдэл:**
1. Image size бууруулах (640 → 416)
2. Бага model ашиглах (yolov8n.pt)

---

## Дараагийн Алхам

Backend холболт бэлэн болсны дараа:

➡️ `05_TESTING.md` - Бүрэн тест хийх

---

## Хураангуй Commands

```bash
# 1. .env тохируулах
cp .env.example .env
# MODEL_PATH=models/weights/product_detector/weights/best.pt гэж засах

# 2. Backend эхлүүлэх
source inventory_env/bin/activate
uvicorn backend.app.main:app --reload --port 8000

# 3. Detection тест
curl -X POST http://localhost:8000/api/detection/detect \
  -F "file=@test_image.jpg"

# 4. Flutter app тест
cd application && flutter run
```
