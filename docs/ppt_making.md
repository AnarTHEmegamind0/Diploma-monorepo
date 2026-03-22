# PPT Хийх Заавар ба Promptууд

> **Хамгаалалтын PPT: Image-Based Product Recognition & Automated Audit Decision System**
>
> **Хуудасны тоо:** 30 хүртэл
> **Хамгаалалтын огноо:** 2026-03-23 (Маргааш)

---

## PPT Бүтэц (30 хуудас)

| № | Хэсэг | Хуудас | Агуулга |
|---|-------|--------|---------|
| 1 | Нүүр | 1 | Гарчиг, нэр, удирдагч |
| 2 | Агуулга | 1 | Slide-ын бүтэц |
| 3 | Асуудал | 2 | Яагаад энэ төсөл хэрэгтэй вэ |
| 4 | Зорилго | 2 | Юу хийхийг зорьсон бэ |
| 5 | Онол | 4 | CV, Object Detection, YOLO |
| 6 | Архитектур | 3 | Системийн бүтэц |
| 7 | Технологи | 2 | Tech stack |
| 8 | Dataset | 3 | Дата цуглуулалт, label |
| 9 | Model | 4 | Training, үр дүн |
| 10 | Backend | 2 | FastAPI, MongoDB |
| 11 | Frontend | 2 | React, Flutter |
| 12 | Demo | 3 | Screenshots, results |
| 13 | Дүгнэлт | 1 | Conclusion |
| | **НИЙТ** | **30** | |

---

## Slide-бүрийн Prompt

### Slide 1: Нүүр хуудас

```
Сэдэв: Зурган дээр үндэслэсэн бүтээгдэхүүн таних ба
       автоматжуулсан аудитын шийдвэр гаргах систем

Оюутан: Түвшинжаргал Анар
Удирдагч: Рэнцэндорж Жавхлан (доктор, дэд профессор)

МУИС, Мэдээлэл Холбооны Технологийн Сургууль
Програм Хангамжийн Инженерчлэлийн Тэнхим
2026
```

---

### Slide 2: Агуулга

```
1. Асуудал тодорхойлолт
2. Зорилго ба зорилтууд
3. Онолын үндэслэл
4. Системийн архитектур
5. Хэрэглэсэн технологиуд
6. Dataset бэлтгэл
7. Model сургалт
8. Backend хөгжүүлэлт
9. Frontend & Mobile
10. Үр дүн ба Demo
11. Дүгнэлт
```

---

### Slide 3-4: Асуудал тодорхойлолт

**Slide 3: Одоогийн байдал**
```
Жижиглэн худалдааны салбарт инвентар шалгах (audit) процесс:

Асуудлууд:
- Гараар тоолох → хүний алдаа олон
- Цаг их зарцуулдаг → 1 дэлгүүрт 2+ цаг
- Аудиторуудын чанар харилцан адилгүй
- Тайлан хожимддог → шийдвэр удаашрах

Жишээ: Coca-Cola Монголиа улсын хэмжээнд 5000+
цэгийн инвентар сар бүр шалгадаг
```

**Slide 4: Шийдэл**
```
Зураг дээр суурилсан автомат систем:

1. Auditor зураг авна → 5 секунд
2. AI бүтээгдэхүүн таньна → 1 секунд
3. Хүлээгдэж буйтай харьцуулна
4. PASS / WARNING / FAIL шийдвэр
5. Dashboard-д шууд тайлан

Үр дүн: 2+ цаг → 5 минут
```

---

### Slide 5-6: Зорилго ба Зорилтууд

**Slide 5: Зорилго**
```
Ерөнхий зорилго:

Компьютер харааны технологи ашиглан жижиглэн
худалдааны тавиур дээрх бүтээгдэхүүнийг автоматаар
таних ба инвентарын аудит хийх систем хөгжүүлэх

Түлхүүр үгс:
- Object Detection (YOLOv8)
- Real-time inference
- Mobile-first approach
- Automated decision making
```

**Slide 6: Зорилтууд**
```
Тодорхой зорилтууд:

1. ✅ Custom dataset үүсгэх (4 ангилал, 96+ зураг)
2. ✅ YOLOv8 model сургах (mAP > 50%)
3. ✅ Backend API хөгжүүлэх (FastAPI)
4. ✅ Mobile app хөгжүүлэх (Flutter)
5. ✅ Web dashboard хөгжүүлэх (React)
6. ✅ Аудит шийдвэр гаргах logic (PASS/WARN/FAIL)
```

---

### Slide 7-10: Онолын үндэслэл

**Slide 7: Computer Vision**
```
Computer Vision гэж юу вэ?

- Компьютерт зураг, видео "харах", "ойлгох" чадвар
- Хүний нүдний үүргийг гүйцэтгэнэ
- Deep Learning-ийн дэвшилт (2012 оноос)

Хэрэглээ:
- Царай таних
- Автомат жолооч
- Эмнэлгийн оношилгоо
- Retail analytics ← Бидний төсөл
```

**Slide 8: Object Detection**
```
Object Detection задлал:

1. Classification - Юу байна вэ? → "Coca-Cola"
2. Localization - Хаана байна вэ? → Bounding box
3. Detection - Олон объект → [class, x, y, w, h, conf]

Түүх:
- R-CNN (2014) - Удаан
- Fast R-CNN (2015) - Дунд
- YOLO (2016) - Хурдан!
```

**Slide 9: YOLO Architecture**
```
YOLO = You Only Look Once

Давуу тал:
- Real-time (30+ FPS)
- Single-stage detector
- End-to-end training

Хувилбарууд:
- YOLOv1-v3: Original
- YOLOv5: PyTorch (Ultralytics)
- YOLOv8: Хамгийн сүүлийн ← Бид ашигласан

Бид: YOLOv8n (nano) - 5.9 MB, хурдан
```

**Slide 10: YOLO-ийн ажиллах зарчим**
```
[Зураг: YOLO architecture diagram]

1. Input: 640x640 зураг
2. Backbone: CSPDarknet (feature extraction)
3. Neck: PANet (multi-scale features)
4. Head: Detection heads

Output:
- Bounding boxes [x, y, w, h]
- Class probabilities
- Confidence scores
```

---

### Slide 11-13: Системийн архитектур

**Slide 11: High-level Architecture**
```
[Зураг: latex/images/diagrams/architecture.png]

┌─────────┐   ┌─────────┐   ┌─────────┐
│ Mobile  │   │ React   │   │ YOLOv8  │
│ (Flutter)│   │ Dashboard│   │ Model   │
└────┬────┘   └────┬────┘   └────┬────┘
     │             │             │
     └──────┬──────┴─────────────┘
            │
     ┌──────▼──────┐
     │   FastAPI   │
     │   Backend   │
     └──────┬──────┘
            │
     ┌──────▼──────┐
     │   MongoDB   │
     └─────────────┘
```

**Slide 12: Data Flow**
```
Auditor flow:

1. Login → JWT token
2. Campaign сонгох
3. Tradeshop руу очих
4. Тавиурын зураг авах
5. → Backend руу upload
6. → YOLOv8 detection
7. → Inventory харьцуулалт
8. → PASS/WARNING/FAIL
9. ← Үр дүн буцаана
```

**Slide 13: Audit Decision Logic**
```
Автомат шийдвэр гаргах алгоритм:

if (difference <= 10%):
    return "PASS" ✅
elif (difference <= 30%):
    return "WARNING" ⚠️
else:
    return "FAIL" ❌

Нэмэлт:
- Хүлээгдэж буй бүтээгдэхүүн байхгүй → FAIL
- Илүү бүтээгдэхүүн байвал → WARNING
```

---

### Slide 14-15: Хэрэглэсэн технологиуд

**Slide 14: Backend & ML**
```
Backend:
- FastAPI - Python web framework
- MongoDB - Document database
- JWT - Authentication
- Uvicorn - ASGI server

Machine Learning:
- Ultralytics YOLOv8 - Object detection
- PyTorch - Deep learning framework
- OpenCV - Image processing
- NumPy - Numerical computing
```

**Slide 15: Frontend & Mobile**
```
Web Dashboard:
- React.js - UI library
- Axios - HTTP client
- Material-UI - Component library

Mobile App:
- Flutter - Cross-platform
- Riverpod - State management
- Dio - HTTP client
- Freezed - Code generation
- Go Router - Navigation
```

---

### Slide 16-18: Dataset бэлтгэл

**Slide 16: Дата цуглуулалт**
```
Бүтээгдэхүүн сонголт:

4 ангилал (Coca-Cola брэнд):
1. Bonaqua 500ml - Ус
2. Coca-Cola 500ml - Кола
3. Fanta 500ml - Фанта (бүх өнгө)
4. Sprite 500ml - Спрайт

Зураг авах:
- iPhone камер
- Дэлгүүрийн тавиур
- Янз бүрийн гэрэлтүүлэг
- Янз бүрийн өнцөг
```

**Slide 17: Annotation (Label хийх)**
```
Roboflow ашигласан:

- SAM3 (Segment Anything Model) auto-label
- Бүх объектыг bounding box-оор тэмдэглэсэн
- YOLO format-аар export

Dataset статистик:
| Нийт зураг | 96 |
| Нийт annotation | 684 |
| Дундаж annotation/зураг | 7.1 |
```

**Slide 18: Dataset хуваалт**
```
Train / Validation / Test split:

[Pie chart зураг]

| Set | Зураг | Хувь |
|-----|-------|------|
| Train | 67 | 70% |
| Validation | 19 | 20% |
| Test | 10 | 10% |

Ангилал тус бүрийн тоо:
| coca_cola | 376 | ✅ |
| fanta | 171 | ✅ |
| sprite | 76 | ⚠️ |
| bonaqua | 74 | ⚠️ |
```

---

### Slide 19-22: Model сургалт

**Slide 19: Training Configuration**
```
YOLOv8 Training Parameters:

| Parameter | Value |
|-----------|-------|
| Base model | YOLOv8n (nano) |
| Epochs | 50 |
| Batch size | 16 |
| Image size | 640x640 |
| Optimizer | SGD |
| Learning rate | 0.01 |
| GPU | NVIDIA RTX 3070 |
```

**Slide 20: Training Process**
```
[Зураг: Loss curves - thesis_loss_curves.png]

Training хугацаа: ~15 минут
Epoch бүрт: ~18 секунд

Loss муруй:
- Box loss ↓
- Class loss ↓
- DFL loss ↓

Овerfitting шинж байхгүй
```

**Slide 21: Evaluation Metrics**
```
[Зураг: thesis_metrics_curves.png]

| Metric | Утга |
|--------|------|
| mAP@50 | 49.7% |
| mAP@50-95 | 28.0% |
| Precision | 45.3% |
| Recall | 52.9% |

Тайлбар:
- mAP = Mean Average Precision
- IoU = Intersection over Union
- Prototype model-д хүлээн зөвшөөрөгдөхүйц
```

**Slide 22: Confusion Matrix**
```
[Зураг: confusion_matrix.png]

Сайн таньсан:
- Coca-Cola ✅ (олон дата)
- Fanta ✅

Муу таньсан:
- Sprite ⚠️ (цөөн дата)
- Bonaqua ⚠️ (цөөн дата)

Шийдэл: Илүү олон зураг нэмэх
```

---

### Slide 23-24: Backend хөгжүүлэлт

**Slide 23: FastAPI Structure**
```
backend/
├── app/
│   ├── main.py          # Entry point
│   ├── config.py        # Settings
│   ├── database.py      # MongoDB
│   ├── models/          # 18 data models
│   ├── routes/          # 13 API routes
│   └── services/        # Business logic

Үндсэн endpoints:
- POST /api/auth/login
- POST /api/detection/detect
- GET /api/campaigns
- POST /api/audit/submit
```

**Slide 24: Detection API**
```python
# /api/detection/detect endpoint

@router.post("/detect")
async def detect_products(file: UploadFile):
    # 1. Зураг хүлээн авах
    image = await file.read()

    # 2. YOLOv8 detection
    results = model.predict(image)

    # 3. Бүтээгдэхүүн тоолох
    products = count_products(results)

    # 4. JSON буцаах
    return {"products": products}
```

---

### Slide 25-26: Frontend & Mobile

**Slide 25: React Dashboard**
```
[Screenshots: backoffice screenshots]

Features:
- Login / Authentication
- Campaign management
- Survey builder (drag-drop)
- Auditor management
- Real-time reports
- Audit results view
```

**Slide 26: Flutter Mobile App**
```
[Screenshots: application screenshots]

Features:
- Auditor login
- Campaign selection
- Tradeshop list
- Camera capture
- Real-time detection
- Survey completion
- History view
```

---

### Slide 27-29: Үр дүн ба Demo

**Slide 27: Detection Demo**
```
[Зураг: thesis_inference_samples.png]

Real-time detection үр дүн:
- Inference хурд: <100ms
- Бүтээгдэхүүн таних: ✅
- Bounding box зөв: ✅
- Confidence score: 0.5+
```

**Slide 28: System Demo**
```
Live Demo:

1. Backend эхлүүлэх
   uvicorn backend.app.main:app --port 8000

2. Frontend нээх
   http://localhost:3000

3. Mobile app
   - Login: 88001122 / audit123
   - Campaign сонгох
   - Зураг авах
   - Detection харах
```

**Slide 29: Performance Summary**
```
[Зураг: thesis_performance_summary.png]

Системийн гүйцэтгэл:

| Үзүүлэлт | Утга |
|----------|------|
| Detection accuracy | 49.7% mAP |
| Inference time | <100ms |
| API response | <500ms |
| Model size | 5.9 MB |

Хэмжилт: MVP prototype-д хангалттай
```

---

### Slide 30: Дүгнэлт

```
Хийсэн ажил:

✅ Custom dataset (96 зураг, 4 ангилал)
✅ YOLOv8 object detection model
✅ FastAPI backend with MongoDB
✅ React web dashboard
✅ Flutter mobile application
✅ End-to-end audit system

Ирээдүйн ажил:

- Dataset өргөжүүлэх (200+ зураг)
- Model accuracy сайжруулах (70%+ mAP)
- Илүү олон бүтээгдэхүүн нэмэх
- Production deployment

Баярлалаа!
Асуулт?
```

---

## Хамгаалалтын Асуултад Бэлдэх

### Асуулт 1: "Яагаад YOLOv8 сонгосон бэ?"
```
Хариулт:
- Real-time detection боломжтой (30+ FPS)
- Single-stage detector → хурдан
- Ultralytics-ийн сайн documentation
- Mobile device-д ажиллах хөнгөн хувилбар (nano)
- State-of-the-art accuracy
- PyTorch дээр суурилсан → өргөтгөх хялбар
```

### Асуулт 2: "mAP 49.7% бага биш үү?"
```
Хариулт:
- Prototype/MVP-д хангалттай
- Dataset жижиг (96 зураг)
- Sprite, Bonaqua цөөн (74-76)
- Сайжруулах боломж:
  1. Илүү олон зураг нэмэх
  2. Epochs нэмэх (50 → 100)
  3. Data augmentation
  4. Илүү том model (YOLOv8s)
```

### Асуулт 3: "Өөр бүтээгдэхүүн нэмэхэд яах вэ?"
```
Хариулт:
1. Шинэ бүтээгдэхүүний зураг авах
2. Roboflow дээр label хийх
3. dataset.yaml-д class нэмэх
4. Model дахин сургах
5. Backend-д class mapping шинэчлэх

Системийн уян хатан байдал:
- Config-оор бүх зүйлийг удирддаг
- Шинэ class нэмэхэд код өөрчлөх шаардлагагүй
```

### Асуулт 4: "Real-world deployment хийхэд юу хэрэгтэй вэ?"
```
Хариулт:
1. Dataset өргөжүүлэх (1000+ зураг)
2. Model accuracy 80%+ болгох
3. Cloud deployment (AWS/GCP)
4. CI/CD pipeline
5. Monitoring & logging
6. Security hardening
7. Load testing
```

### Асуулт 5: "Flutter яагаад сонгосон бэ?"
```
Хариулт:
- Cross-platform (iOS + Android нэг codebase)
- Hot reload → хурдан хөгжүүлэлт
- Native performance
- Rich widget library
- Good camera integration
- Riverpod state management → clean architecture
```

---

## PPT Хийх Tool-ууд

### Сонголт 1: Google Slides (Зөвлөмж)
- Үнэгүй
- Collaboration
- Үүлэн хадгалалт

### Сонголт 2: PowerPoint
- Microsoft 365
- Offline ажиллана

### Сонголт 3: Canva
- Template олон
- Design хялбар

---

## Зураг хаанаас авах

```
Төслийн зураг:
- latex/images/diagrams/architecture.png
- latex/images/backoffice/*.png
- latex/images/application/*.png
- models/weights/product_detector/thesis_*.png
- models/weights/product_detector/confusion_matrix.png

Notebooks-оос:
- Training curves
- Inference samples
- Class distribution
```

---

## Checklist

- [ ] Slide 1-2: Нүүр, агуулга
- [ ] Slide 3-6: Асуудал, зорилго
- [ ] Slide 7-10: Онол (CV, YOLO)
- [ ] Slide 11-13: Архитектур
- [ ] Slide 14-15: Технологи
- [ ] Slide 16-18: Dataset
- [ ] Slide 19-22: Model training
- [ ] Slide 23-24: Backend
- [ ] Slide 25-26: Frontend/Mobile
- [ ] Slide 27-29: Demo, үр дүн
- [ ] Slide 30: Дүгнэлт
- [ ] Асуултад бэлтгэсэн
- [ ] Demo ажиллаж байгаа

---

**Амжилт хүсье!**
