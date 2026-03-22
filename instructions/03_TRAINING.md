# Phase 3: YOLOv8 Model Сургах Заавар

## Зорилго

Label хийсэн өгөгдлөө ашиглан YOLOv8 model сургах.
Model сурсны дараа бүтээгдэхүүн автоматаар танина.

---

## Урьдчилсан Нөхцөл

1. ✅ Зураг цуглуулсан (`data/raw/`)
2. ✅ Label хийсэн (`data/labeled/images/` + `data/labeled/labels/`)
3. ✅ `classes.txt` файл зөв

---

## Алхам 1: Dataset Хуваах (Train/Val/Test)

```bash
# Virtual environment идэвхжүүлэх
source inventory_env/bin/activate

# Dataset-ийг train/val/test болгон хуваах
python -m src.data.split_dataset
```

**Үр дүн:**
```
data/splits/
├── train/
│   ├── images/     # 70% зураг
│   └── labels/     # 70% label
├── val/
│   ├── images/     # 20% зураг
│   └── labels/     # 20% label
└── test/
    ├── images/     # 10% зураг
    └── labels/     # 10% label
```

### Шалгах:

```bash
echo "Train: $(ls data/splits/train/images/ 2>/dev/null | wc -l) images"
echo "Val:   $(ls data/splits/val/images/ 2>/dev/null | wc -l) images"
echo "Test:  $(ls data/splits/test/images/ 2>/dev/null | wc -l) images"
```

---

## Алхам 2: Data Augmentation (Өгөгдөл нэмэгдүүлэх)

Augmentation нь зураг бүрээс олон хувилбар үүсгэж өгөгдлийг нэмэгдүүлнэ.

```bash
# Augmentation хийх
python -m src.data.augment
```

**Юу хийдэг вэ?**
- Зургийг эргүүлэх (rotate)
- Гэрэлтүүлэг өөрчлөх (brightness)
- Толинд туссан мэт (flip)
- Бага зэрэг бүдгэрүүлэх (blur)

### Augmented өгөгдлийг training set-рүү нэмэх:

```bash
cp data/augmented/images/*.jpg data/splits/train/images/
cp data/augmented/labels/*.txt data/splits/train/labels/
```

---

## Алхам 3: Dataset Config шалгах

`models/configs/dataset.yaml` файл зөв эсэхийг шалгах:

```bash
cat models/configs/dataset.yaml
```

**Зөв формат:**
```yaml
path: ../../data/splits
train: train/images
val: val/images
test: test/images

nc: 10  # Бүтээгдэхүүний тоо

names:
  0: coca_cola
  1: fanta
  2: sprite
  3: pepsi
  4: lays
  5: pringles
  6: snickers
  7: mars
  8: water_bottle
  9: milk
```

---

## Алхам 4: Model Сургах

### Энгийн сургалт:

```bash
python -m src.training.train
```

### Тохиргоотой сургалт:

```python
# Python дээр шууд ажиллуулах бол:
from src.training.train import train_model

train_model(
    model_name="yolov8n.pt",    # nano model (хурдан)
    epochs=50,                   # 50 epoch
    batch_size=16,              # GPU-аас хамаарна
    image_size=640,             # Зургийн хэмжээ
    device="mps"                # Apple Silicon: "mps", NVIDIA: "0", CPU: "cpu"
)
```

### Model хэмжээ сонгох:

| Model | Хэмжээ | Хурд | Нарийвчлал |
|-------|--------|------|------------|
| yolov8n.pt | 6MB | Маш хурдан | Бага |
| yolov8s.pt | 22MB | Хурдан | Дунд |
| yolov8m.pt | 50MB | Дунд | Сайн |
| yolov8l.pt | 84MB | Удаан | Маш сайн |

**Зөвлөгөө:** Эхлээд `yolov8n.pt` ашигла, дараа нь шаардлагатай бол `yolov8s.pt` руу шилж.

---

## Алхам 5: Сургалтын явцыг хянах

Сургалт эхлэхэд ийм мэдээлэл гарна:

```
Epoch    GPU_mem   box_loss   cls_loss   dfl_loss  Instances       Size
  1/50      3.2G     1.432      2.156      1.234         45        640
  2/50      3.2G     1.321      1.987      1.198         52        640
  3/50      3.2G     1.245      1.876      1.156         48        640
  ...
```

**Чухал metrics:**
- `box_loss` - Bounding box алдаа (буурах ёстой)
- `cls_loss` - Classification алдаа (буурах ёстой)
- `mAP50` - Нарийвчлал (өсөх ёстой, 0.7+ сайн)

---

## Алхам 6: Сургалтын хугацаа

| Зургийн тоо | Epochs | Хугацаа (Apple M1/M2) | Хугацаа (NVIDIA GPU) |
|-------------|--------|----------------------|---------------------|
| 300 | 50 | ~30 минут | ~15 минут |
| 500 | 50 | ~45 минут | ~20 минут |
| 1000 | 50 | ~1.5 цаг | ~40 минут |
| 300 | 100 | ~1 цаг | ~30 минут |

---

## Алхам 7: Үр дүн шалгах

Сургалт дууссаны дараа:

```bash
# Model файлууд байгаа эсэх
ls -la models/weights/product_detector/weights/
```

**Гарах файлууд:**
```
best.pt   # Хамгийн сайн model (энийг ашиглана)
last.pt   # Сүүлийн epoch-ийн model
```

### Model үнэлэх:

```bash
python -m src.training.evaluate
```

**Хүлээгдэж буй үр дүн:**
```
mAP50: 0.75      # 75% нарийвчлал (0.7+ сайн)
mAP50-95: 0.52   # Илүү хатуу хэмжүүр
Precision: 0.82  # Зөв таних хувь
Recall: 0.78     # Олох хувь
```

---

## Алхам 8: Model туршиж үзэх

```python
# Python дээр туршах
from src.inference.detector import ProductDetector

# Model ачаалах
detector = ProductDetector("models/weights/product_detector/weights/best.pt")

# Нэг зураг дээр турших
result = detector.detect("data/splits/test/images/test_image.jpg")

# Үр дүн харах
print(f"Нийт олдсон: {result.total_products} бүтээгдэхүүн")
for det in result.detections:
    print(f"  {det.class_name}: {det.confidence:.2f}")
```

---

## Алхам 9: Annotated зураг хадгалах

```python
import cv2
from src.inference.detector import ProductDetector

detector = ProductDetector("models/weights/product_detector/weights/best.pt")

# Зураг унших
img = cv2.imread("data/splits/test/images/test_image.jpg")

# Detection хийх
result = detector.detect(img)

# Bounding box зурах
annotated = detector.draw_detections(img, result)

# Хадгалах
cv2.imwrite("data/test_result.jpg", annotated)
print("Saved: data/test_result.jpg")
```

---

## Түгээмэл Асуудлууд

### 1. "No images found in dataset"

**Шийдэл:** Dataset path шалгах
```bash
ls data/splits/train/images/
```

### 2. "CUDA out of memory"

**Шийдэл:** Batch size бууруулах
```python
train_model(batch_size=8)  # 16-аас 8 болгох
```

### 3. mAP маш бага (< 0.5)

**Шийдэл:**
1. Илүү олон зураг цуглуулах
2. Label чанараа шалгах
3. Epochs тоог нэмэгдүүлэх (50 → 100)

### 4. Сургалт удаан

**Шийдэл:**
1. Бага model ашиглах (`yolov8n.pt`)
2. Image size бууруулах (640 → 416)
3. GPU ашиглах

---

## Дараагийн Алхам

Model сургаж дууссаны дараа:

➡️ `04_INTEGRATION.md` - Backend-тай холбох

---

## Хураангуй Commands

```bash
# 1. Dataset хуваах
python -m src.data.split_dataset

# 2. Augmentation
python -m src.data.augment
cp data/augmented/images/*.jpg data/splits/train/images/
cp data/augmented/labels/*.txt data/splits/train/labels/

# 3. Сургах
python -m src.training.train

# 4. Үнэлэх
python -m src.training.evaluate

# 5. Model байршил
ls models/weights/product_detector/weights/best.pt
```
