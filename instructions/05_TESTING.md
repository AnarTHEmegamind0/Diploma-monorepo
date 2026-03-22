# Phase 6: Бүрэн Тест Хийх Заавар

## Зорилго

Системийн бүх хэсгийг бүрэн тестлэж, зөв ажиллаж байгаа эсэхийг баталгаажуулах.

---

## Тест Төрлүүд

1. **Unit Tests** - Код түвшний тест
2. **API Tests** - Backend endpoint тест
3. **Integration Tests** - Бүх системийн тест
4. **End-to-End Tests** - Хэрэглэгчийн flow тест

---

## 1. Unit Tests ажиллуулах

```bash
# Virtual environment идэвхжүүлэх
source inventory_env/bin/activate

# Бүх тест ажиллуулах
pytest tests/ -v
```

**Хүлээгдэж буй үр дүн:**
```
tests/test_api.py::test_health_check PASSED
tests/test_api.py::test_root_endpoint PASSED
tests/test_api.py::test_products_list PASSED
tests/test_audit_engine.py::test_audit_pass PASSED
tests/test_audit_engine.py::test_audit_warning PASSED
tests/test_audit_engine.py::test_audit_fail PASSED
tests/test_audit_engine.py::test_audit_extra_products PASSED
tests/test_audit_engine.py::test_audit_match_rate PASSED
tests/test_audit_engine.py::test_audit_report_generation PASSED
tests/test_detector.py::test_preprocess_resize PASSED
tests/test_detector.py::test_preprocess_normalize PASSED
tests/test_detector.py::test_detection_result_to_dict PASSED
...
========================= X passed =========================
```

---

## 2. API Tests

### Health check:
```bash
curl http://localhost:8000/health
# {"status": "healthy"}
```

### Auth test:
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "88001122", "password": "audit123"}'
```

### Campaigns test:
```bash
TOKEN="<token from login>"
curl http://localhost:8000/api/mobile/campaigns \
  -H "Authorization: Bearer $TOKEN"
```

### Detection test:
```bash
curl -X POST http://localhost:8000/api/detection/detect \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@test_image.jpg"
```

---

## 3. End-to-End Test Checklist

### Flutter App тест:

- [ ] Login хийх (88001122 / audit123)
- [ ] Campaign жагсаалт харагдах
- [ ] Campaign сонгох
- [ ] Tradeshop жагсаалт харагдах
- [ ] Tradeshop сонгох
- [ ] Survey асуултууд харагдах
- [ ] Асуултуудад хариулах
- [ ] Зураг авах
- [ ] Detection ажиллах (model байгаа бол)
- [ ] Submit хийх
- [ ] History-д харагдах

### React Frontend тест:

- [ ] Login хийх
- [ ] Dashboard статистик харагдах
- [ ] Campaigns жагсаалт
- [ ] Surveys жагсаалт
- [ ] Survey Builder ажиллах
- [ ] Tradeshops CRUD
- [ ] Auditors CRUD
- [ ] Audit Results харагдах

---

## 4. Detection Тест (Model байгаа бол)

### Python дээр шууд тест:

```python
from src.inference.detector import ProductDetector

# Model ачаалах
detector = ProductDetector("models/weights/product_detector/weights/best.pt")

# Test зураг
result = detector.detect("data/splits/test/images/test_image.jpg")

# Шалгах
assert result.total_products > 0, "Бүтээгдэхүүн олдсонгүй!"
print(f"✅ {result.total_products} бүтээгдэхүүн олдлоо")

for det in result.detections:
    print(f"  - {det.class_name}: {det.confidence:.2%}")
```

### Confidence threshold тест:

```python
# Өндөр threshold
detector_high = ProductDetector(
    "models/weights/product_detector/weights/best.pt",
    conf_threshold=0.7
)
result_high = detector_high.detect("test_image.jpg")
print(f"High threshold: {result_high.total_products} products")

# Бага threshold
detector_low = ProductDetector(
    "models/weights/product_detector/weights/best.pt",
    conf_threshold=0.2
)
result_low = detector_low.detect("test_image.jpg")
print(f"Low threshold: {result_low.total_products} products")
```

---

## 5. Audit Logic Тест

```python
from src.inference.audit_engine import AuditEngine

engine = AuditEngine()

# Тест 1: PASS
result = engine.run_audit(
    expected={"coca_cola": 10, "fanta": 5},
    detected={"coca_cola": 10, "fanta": 5}
)
assert result.status == "PASS"
print("✅ PASS тест амжилттай")

# Тест 2: WARNING  
result = engine.run_audit(
    expected={"coca_cola": 10, "fanta": 5},
    detected={"coca_cola": 8, "fanta": 4}  # 20% зөрүү
)
assert result.status == "WARNING"
print("✅ WARNING тест амжилттай")

# Тест 3: FAIL
result = engine.run_audit(
    expected={"coca_cola": 10, "fanta": 5},
    detected={"coca_cola": 5, "fanta": 2}  # 50%+ зөрүү
)
assert result.status == "FAIL"
print("✅ FAIL тест амжилттай")
```

---

## 6. Performance Тест

### Detection хурд:

```python
import time
from src.inference.detector import ProductDetector

detector = ProductDetector("models/weights/product_detector/weights/best.pt")

# 10 зураг дээр тест
times = []
for i in range(10):
    start = time.time()
    result = detector.detect("test_image.jpg")
    elapsed = (time.time() - start) * 1000
    times.append(elapsed)

avg_time = sum(times) / len(times)
print(f"Дундаж хугацаа: {avg_time:.1f}ms")

# 500ms-аас бага байх ёстой
assert avg_time < 500, f"Хэт удаан: {avg_time}ms"
print("✅ Performance тест амжилттай")
```

---

## 7. Алдааны Тест

### Хоосон зураг:
```bash
# Хоосон файл илгээх
curl -X POST http://localhost:8000/api/detection/detect \
  -F "file=@empty.txt"
# 400 Bad Request хүлээгдэнэ
```

### Хэт том файл:
```bash
# 15MB файл илгээх (limit 10MB)
curl -X POST http://localhost:8000/api/detection/detect \
  -F "file=@large_file.jpg"
# 400 Bad Request хүлээгдэнэ
```

### Буруу token:
```bash
curl http://localhost:8000/api/mobile/campaigns \
  -H "Authorization: Bearer invalid_token"
# 401 Unauthorized хүлээгдэнэ
```

---

## 8. Тестийн Хураангуй

```bash
# Бүгдийг нэг дор ажиллуулах
pytest tests/ -v --tb=short

# Coverage report
pytest tests/ --cov=backend --cov=src --cov-report=html
# htmlcov/index.html нээж харна
```

---

## Тестийн Checklist

| Тест | Статус |
|------|--------|
| Unit tests pass | ⬜ |
| Health endpoint | ⬜ |
| Auth login | ⬜ |
| Mobile campaigns API | ⬜ |
| Mobile tradeshops API | ⬜ |
| Detection API | ⬜ |
| Audit submission | ⬜ |
| Flutter app login | ⬜ |
| Flutter campaign select | ⬜ |
| Flutter photo capture | ⬜ |
| Flutter submit audit | ⬜ |
| React dashboard | ⬜ |
| React survey builder | ⬜ |

---

## Дараагийн Алхам

Бүх тест амжилттай болсны дараа:

➡️ `06_DEPLOYMENT.md` - Docker deploy хийх
