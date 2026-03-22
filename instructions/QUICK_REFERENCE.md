# Quick Reference Card

## Түгээмэл Commands

### Backend

```bash
# Virtual env идэвхжүүлэх
source inventory_env/bin/activate

# Backend сервер эхлүүлэх
uvicorn backend.app.main:app --reload --port 8000

# Health check
curl http://localhost:8000/health
```

### Frontend (React)

```bash
cd frontend

# Dependencies суулгах
npm install

# Dev server эхлүүлэх
npm start

# Build хийх
npm run build
```

### Flutter App

```bash
cd application

# Dependencies суулгах
flutter pub get

# Analyze
flutter analyze

# iOS Simulator дээр ажиллуулах
flutter run -d <device_id>

# Devices харах
flutter devices
```

### MongoDB

```bash
# Docker-оор эхлүүлэх
docker-compose up mongodb -d

# Shell руу орох
mongosh inventory_audit

# Collections харах
db.getCollectionNames()
```

### YOLO Training

```bash
# Dataset хуваах
python -m src.data.split_dataset

# Augmentation
python -m src.data.augment

# Model сургах
python -m src.training.train

# Model үнэлэх
python -m src.training.evaluate
```

### Tests

```bash
# Бүх тест
pytest tests/ -v

# Тодорхой тест
pytest tests/test_audit_engine.py -v
```

### Docker

```bash
# Бүгдийг эхлүүлэх
docker-compose up --build

# Background-д
docker-compose up -d

# Зогсоох
docker-compose down

# Logs
docker-compose logs -f
```

---

## Чухал файлууд

| Файл | Зорилго |
|------|---------|
| `.env` | Environment variables |
| `models/configs/dataset.yaml` | YOLO dataset config |
| `backend/app/main.py` | FastAPI app entry |
| `frontend/src/App.js` | React entry |
| `application/lib/main.dart` | Flutter entry |

---

## URLs

| Service | URL |
|---------|-----|
| Backend API | http://localhost:8000 |
| Swagger Docs | http://localhost:8000/docs |
| React Frontend | http://localhost:3000 |
| MongoDB | mongodb://localhost:27017 |

---

## Demo Credentials

```
Phone: 88001122
Password: audit123
```

---

## Хавтас Бүтэц

```
inventory_project/
├── backend/           # FastAPI backend
├── frontend/          # React dashboard
├── application/       # Flutter mobile app
├── src/               # ML pipeline (YOLO)
├── data/              # Images, labels, splits
├── models/            # YOLO configs & weights
├── tests/             # Python tests
├── instructions/      # ЭНЭ ЗААВАР ФАЙЛУУД
└── docker-compose.yml # Docker config
```

---

## Яаралтай Тусламж

```bash
# Backend ажиллахгүй бол
ps aux | grep uvicorn
kill -9 <PID>
uvicorn backend.app.main:app --reload --port 8000

# MongoDB ажиллахгүй бол
docker-compose restart mongodb

# Flutter error бол
flutter clean
flutter pub get
flutter run

# Port ашиглагдаж байвал
lsof -i :8000
kill -9 <PID>
```
