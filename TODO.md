# TODO - Систем Дуусгах Шаардлагатай Ажлууд

> **Сүүлд шинэчлэгдсэн:** 2026-04-18
> **Төлөв:** Кодын үндсэн интеграци бараг дууссан, dataset/model болон шалгалтууд үлдсэн

---

## Яаралтай - Таны хийх ажил

### 1. Dataset өргөтгөх
- [ ] 200+ зурагтай болох
- [ ] Ялангуяа `bonaqua_500ml`, `sprite_500ml` class-д зураг нэмэх
- [ ] Roboflow дээр label шалгах, алдаатай annotation-уудыг засах
- [ ] Шинэ dataset-ийг YOLO format-аар export хийх

### 2. Model дахин сургах
- [ ] Windows RTX 3070 орчин дээр 100 epoch дахин сургах
- [ ] `mAP50 > 70%` зорилт тавих
- [ ] Шинэ `best.pt`-г backend орчинд сольж тест хийх

```bash
cd scripts
python train_rtx3070.py --epochs 100 --batch 16
```

---

## Кодын Ажил - Дууссан

### Backend
- [x] Campaign stats TODO-г бодит тооцоололтой болгосон
- [x] `audit_result` (`pass` / `warning` / `fail`) логик нэмсэн
- [x] Detection model status endpoint нэмсэн

### Flutter
- [x] Detection repository layer нэмсэн
- [x] Detection provider layer нэмсэн
- [x] `image_page.dart`-ийг шинэ detection provider руу шилжүүлсэн
- [x] App DI бүртгэл шинэчилсэн

---

## Одоо Шууд Шалгах

### Demo урсгал
- [ ] Backend + MongoDB ассан эсэх
- [ ] Flutter app backend-тай холбогдож буй эсэх
- [ ] `/api/detection/status` endpoint зөв хариу өгч буй эсэх
- [ ] Зураг оруулаад detection ажиллаж буй эсэх
- [ ] Audit submit хийсний дараа `audit_result` хадгалагдаж буй эсэх
- [ ] Campaign stats дээр pass/warning/fail тоо зөв гарч буй эсэх

### Түргэн шалгах команд
```bash
# Backend
cd backend && uvicorn app.main:app --reload --port 8000

# Flutter
cd application && flutter run

# Backend tests
pytest tests/ -v

# Flutter static checks
flutter analyze
flutter test
```

---

## Хамгаалалтын Checklist

### Техникийн
- [ ] Demo дата бэлэн
- [ ] Login ажиллаж байна
- [ ] Campaign сонголт ажиллаж байна
- [ ] Photo capture / gallery ажиллаж байна
- [ ] Detection widget үр дүнгээ харуулж байна
- [ ] Submit дарахад thank you flow ажиллаж байна

### Материал
- [ ] PPT final
- [ ] Thesis PDF final
- [ ] Demo script бэлэн
- [ ] Backup (`best.pt`, thesis PDF, PPT, source code)

---

## Хамгаалалтын Дараа

- [ ] CI/CD pipeline
- [ ] Production `.env`
- [ ] Monitoring / backup
- [ ] Backend integration tests
- [ ] Flutter widget/integration tests
