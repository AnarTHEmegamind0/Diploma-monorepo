# Windows RTX 3070 дээр Model Сургах Бүрэн Заавар

> **Dataset бэлэн болсон, одоо Windows руу шилжүүлж model сургана.**

---

## ✅ Бэлэн болсон зүйлс (Mac дээр хийгдсэн)

| Зүйл | Тоо |
|------|-----|
| Нийт зураг | 96 |
| Train images | 67 |
| Val images | 19 |
| Test images | 10 |
| Ангилал | 4 (bonaqua, coca_cola, fanta, sprite) |
| Annotations | 780 |

---

## Алхам 1: Project-ийг Windows руу хуулах

### Сонголт A: USB/External Drive
```
Mac дээр:
1. inventory_project folder-ийг USB руу хуулах
2. Windows дээр C:\Projects\ руу хуулах
```

### Сонголт B: Git (Хэрэв repo байвал)
```cmd
cd C:\Projects
git clone YOUR_REPO_URL
cd inventory_project
git pull
```

### Сонголт C: Cloud (Google Drive, OneDrive)
1. Mac дээр folder-ийг Cloud руу upload
2. Windows дээр татах

---

## Алхам 2: Windows Environment бэлдэх

### 2.1 Python 3.11 суулгах (хэрэв байхгүй бол)
1. https://python.org → Downloads → Python 3.11.x
2. **"Add Python to PATH"** заавал сонгох!

### 2.2 Virtual environment үүсгэх
```cmd
cd C:\Projects\inventory_project

REM Virtual environment үүсгэх
python -m venv venv

REM Идэвхжүүлэх
venv\Scripts\activate.bat

REM Dependencies суулгах
pip install --upgrade pip
pip install ultralytics torch torchvision --index-url https://download.pytorch.org/whl/cu121
pip install opencv-python pyyaml
```

### 2.3 CUDA шалгах
```cmd
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0)}' if torch.cuda.is_available() else 'No GPU')"
```

**Хүлээгдэж буй үр дүн:**
```
CUDA: True
GPU: NVIDIA GeForce RTX 3070
```

---

## Алхам 3: Dataset шалгах

```cmd
REM Dataset folder-ууд байгаа эсэх
dir data\splits\train\images
dir data\splits\val\images
dir data\splits\test\images
```

**Хүлээгдэж буй:**
- train\images: 67 файл
- val\images: 19 файл
- test\images: 10 файл

---

## Алхам 4: Model сургах

### 4.1 Training эхлүүлэх
```cmd
venv\Scripts\activate.bat
python scripts/train_rtx3070.py
```

### 4.2 Дэлгэрэнгүй тохиргоотой
```cmd
REM Epochs тохируулах (default: 50)
python scripts/train_rtx3070.py --epochs 100

REM Batch size тохируулах (GPU санах ойноос хамаарна)
python scripts/train_rtx3070.py --batch 16

REM Preset ашиглах
python scripts/train_rtx3070.py --preset rtx3070_accurate
```

### 4.3 Хүлээгдэж буй хугацаа
| Preset | Epochs | Хугацаа |
|--------|--------|---------|
| rtx3070_fast | 30 | ~5 минут |
| rtx3070 | 50 | ~8-10 минут |
| rtx3070_accurate | 100 | ~15-20 минут |

---

## Алхам 5: Training явц харах

Training явж байх үед terminal дээр:
```
Epoch 1/50:
  train/box_loss: 1.234
  train/cls_loss: 2.345
  val/mAP50: 0.456
  ...

Epoch 50/50:
  train/box_loss: 0.234
  train/cls_loss: 0.345
  val/mAP50: 0.789  ← Энэ тоог ажигла!
```

**Сайн үр дүн:**
- mAP50 > 0.70 (70%)
- box_loss < 0.5
- cls_loss < 0.5

---

## Алхам 6: Сургасан model шалгах

### 6.1 Test set дээр шалгах
```cmd
python scripts/test_model.py
```

### 6.2 Нэг зураг дээр шалгах
```cmd
python scripts/test_model.py --image data/splits/test/images/IMG_6293_jpg.rf.2YohnQlU7797Z9G3eGCo.jpg
```

### 6.3 Үр дүн харуулах (visual)
```cmd
python scripts/test_model.py --visualize
```

### 6.4 Үр дүн хадгалах
```cmd
python scripts/test_model.py --save results/
```

### 6.5 Бүрэн evaluation
```cmd
python scripts/test_model.py --evaluate
```

**Хүлээгдэж буй үр дүн:**
```
📊 Metrics:
   mAP@50:    0.7500+
   mAP@50-95: 0.5000+
   Precision: 0.8000+
   Recall:    0.7500+
```

---

## Алхам 7: Model-ийг Backend-д холбох

### 7.1 .env файл тохируулах
```cmd
copy .env.example .env
notepad .env
```

`.env` файлд:
```env
MODEL_PATH=models/weights/product_detector/weights/best.pt
CONFIDENCE_THRESHOLD=0.25
IOU_THRESHOLD=0.45
```

### 7.2 Backend эхлүүлэх
```cmd
venv\Scripts\activate.bat
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
```

### 7.3 API туршиж үзэх
```cmd
curl -X POST http://localhost:8000/api/detection/detect -F "file=@data/splits/test/images/test_image.jpg"
```

---

## Түгээмэл Асуудлууд

### ❌ "CUDA out of memory"
```cmd
REM Batch size бууруулах
python scripts/train_rtx3070.py --batch 8
```

### ❌ "torch.cuda.is_available() returns False"
```cmd
REM PyTorch дахин суулгах CUDA-тай
pip uninstall torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
```

### ❌ "No module named 'ultralytics'"
```cmd
pip install ultralytics
```

### ❌ "FileNotFoundError: dataset.yaml"
```cmd
REM dataset.yaml файл байгаа эсэх шалгах
type models\configs\dataset.yaml
```

---

## Файлын Байршил

Сургасан model:
```
models/weights/product_detector/weights/
├── best.pt      ← Хамгийн сайн model (ҮҮНИЙГ АШИГЛАНА)
└── last.pt      ← Сүүлийн checkpoint
```

Training logs:
```
models/weights/product_detector/
├── results.csv       ← Training metrics
├── confusion_matrix.png
├── results.png       ← Loss/mAP graphs
└── ...
```

---

## Quick Commands

```cmd
REM 1. Environment идэвхжүүлэх
venv\Scripts\activate.bat

REM 2. CUDA шалгах
python -c "import torch; print(torch.cuda.is_available())"

REM 3. Training эхлүүлэх
python scripts/train_rtx3070.py

REM 4. Model шалгах
python scripts/test_model.py

REM 5. Backend эхлүүлэх
uvicorn backend.app.main:app --reload --port 8000
```

---

## Дараагийн алхмууд

1. ✅ Model сургах (энэ заавар)
2. ⬜ Backend-д холбох
3. ⬜ Frontend тест хийх
4. ⬜ Flutter app тест хийх
5. ⬜ Thesis screenshot авах
