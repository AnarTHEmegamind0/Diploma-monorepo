# AGENTS.md — AI Agent Context File

> **Image-Based Product Recognition & Automated Audit Decision System**
>
> Bachelor's Thesis Project — National University of Mongolia (NUM)
>
> **Status:** Thesis defense ready (2026-03-23)

---

## Quick Facts

| Item | Value |
|------|-------|
| **Project Type** | Retail inventory audit automation |
| **ML Model** | YOLOv8n (trained, 5.9 MB) |
| **Dataset** | 96 images, 4 classes, 684 annotations |
| **Backend** | FastAPI + MongoDB |
| **Frontend** | React.js Dashboard |
| **Mobile** | Flutter (Riverpod + Go Router) |
| **Model mAP50** | 49.7% |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           MONOREPO STRUCTURE                            │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Flutter    │   │    React     │   │   FastAPI    │   │   YOLOv8     │
│  Mobile App  │   │  Dashboard   │   │   Backend    │   │   Model      │
│ application/ │   │  frontend/   │   │  backend/    │   │ src/ + models│
└──────┬───────┘   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
       │                  │                  │                  │
       └──────────────────┴────────┬─────────┴──────────────────┘
                                   │
                            ┌──────▼───────┐
                            │   MongoDB    │
                            │  :27017      │
                            └──────────────┘
```

---

## Directory Structure

```
inventory_project/
│
├── application/              # Flutter Mobile App
│   └── lib/
│       ├── core/             # Shared: theme, DI, navigation
│       └── features/         # Feature modules
│           ├── auth/         # Login
│           ├── audit/        # Main audit flow
│           ├── home/         # Dashboard
│           ├── history/      # Past audits
│           ├── profile/      # User profile
│           ├── settings/     # App settings
│           └── shell/        # Bottom nav shell
│
├── backend/                  # FastAPI Backend
│   └── app/
│       ├── main.py           # Entry point
│       ├── config.py         # Environment config
│       ├── database.py       # MongoDB connection
│       ├── models/           # 18 Pydantic schemas
│       ├── routes/           # 13 API route files
│       └── services/         # Business logic
│
├── frontend/                 # React Dashboard
│   └── src/
│       ├── pages/            # 13 page components
│       ├── components/       # Shared UI
│       ├── context/          # Auth context
│       └── services/api.js   # HTTP client
│
├── src/                      # ML Pipeline
│   ├── training/             # train.py, evaluate.py
│   ├── inference/            # detector.py, audit_engine.py
│   ├── data/                 # preprocess, augment, split
│   └── utils/                # logger, visualization
│
├── models/
│   ├── configs/
│   │   └── dataset.yaml      # 4 classes defined
│   └── weights/
│       └── product_detector/
│           ├── weights/
│           │   ├── best.pt   # ✅ Trained model (5.9 MB)
│           │   └── last.pt
│           ├── results.csv   # Training metrics
│           └── thesis_*.png  # 7 thesis graphics
│
├── data/
│   ├── splits/               # Train/Val/Test (200 files)
│   │   ├── train/            # 67 images
│   │   ├── val/              # 19 images
│   │   └── test/             # 10 images
│   └── raw/                  # Original 96 images
│
├── notebooks/
│   ├── 01_model_analysis.ipynb
│   └── 02_inference_demo.ipynb
│
├── latex/                    # Thesis LaTeX files
├── instructions/             # 10 guide documents
├── scripts/                  # Training & utility scripts
├── tests/                    # Pytest tests
├── docs/
│   └── ppt_making.md         # PPT prompts (30 slides)
│
├── AGENTS.md                 # ← You are here
├── STEPS.md                  # Implementation steps
├── PROGRESS.md               # Progress tracking
└── README.md                 # Project overview
```

---

## Tech Stack

| Component | Technology | Notes |
|-----------|------------|-------|
| **ML** | YOLOv8n (Ultralytics) | PyTorch 2.9, OpenCV 4.12 |
| **Backend** | FastAPI 0.115 | Motor (async MongoDB), JWT auth |
| **Database** | MongoDB 7.0 | Collections: auditors, campaigns, surveys, audits |
| **Frontend** | React 18.3 | Axios, Context API |
| **Mobile** | Flutter 3.x | Riverpod, Go Router, Dio, Freezed |
| **Container** | Docker Compose 3.8 | 3 services |

---

## Model Information

### Trained Model Location
```
models/weights/product_detector/weights/best.pt
```

### Dataset Classes (4)
| ID | Name | Annotations |
|----|------|-------------|
| 0 | bonaqua_500ml | 74 |
| 1 | coca_cola_500ml | 376 |
| 2 | fanta_500ml | 171 |
| 3 | sprite_500ml | 76 |

### Training Results
| Metric | Value |
|--------|-------|
| mAP50 | 49.7% |
| mAP50-95 | 28.0% |
| Precision | 45.3% |
| Recall | 52.9% |
| Epochs | 50 |
| Batch Size | 16 |
| Image Size | 640x640 |

---

## API Endpoints (Key)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Auditor login |
| POST | `/api/detection/detect` | Image → product detection |
| GET | `/api/campaigns` | List campaigns |
| GET | `/api/mobile/campaigns` | Mobile: assigned campaigns |
| POST | `/api/audit/submit` | Submit audit |
| GET | `/api/surveys/{id}` | Get survey questions |

**Full API docs:** `http://localhost:8000/docs`

---

## Mobile App Architecture (Flutter)

### State Management: Riverpod

```dart
// Provider example
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(service: ref.read(authServiceProvider));
});
```

### Navigation: Go Router

```dart
// Routes defined in app_providers.dart
GoRouter(routes: [
  GoRoute(path: '/login', builder: (_, __) => LoginPage()),
  ShellRoute(builder: (_, __, child) => AppShellPage(child: child)),
]);
```

### Feature Structure
```
features/<name>/
├── models/          # Data classes (Freezed)
├── repositories/    # API calls (abstract + impl)
├── services/        # Business logic
├── providers/       # Riverpod providers
├── pages/           # UI screens
└── widgets/         # Reusable UI
```

### Key Files
| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry |
| `lib/core/di/app_providers.dart` | DI setup |
| `lib/core/dio_client.dart` | HTTP client |
| `lib/features/auth/providers/auth_provider.dart` | Auth state |
| `lib/features/audit/pages/image_page.dart` | Camera capture |

---

## Commands

### Backend
```bash
cd backend
uvicorn app.main:app --reload --port 8000
```

### Frontend
```bash
cd frontend
npm install && npm start
```

### Mobile
```bash
cd application
flutter pub get
flutter run
```

### Model Training (Windows RTX)
```bash
python scripts/train_rtx3070.py
```

### Tests
```bash
pytest tests/ -v
```

### Docker (Full Stack)
```bash
docker-compose up --build
```

---

## Key Configuration Files

| File | Purpose |
|------|---------|
| `.env` | Environment variables |
| `models/configs/dataset.yaml` | YOLO dataset config |
| `backend/app/config.py` | Backend settings |
| `application/pubspec.yaml` | Flutter dependencies |
| `frontend/package.json` | React dependencies |

---

## Environment Variables

```env
# Backend
MONGODB_URI=mongodb://localhost:27017
MONGODB_DB_NAME=inventory_audit
API_PORT=8000

# ML
MODEL_PATH=models/weights/product_detector/weights/best.pt
CONFIDENCE_THRESHOLD=0.25
IOU_THRESHOLD=0.45

# Frontend
REACT_APP_API_URL=http://localhost:8000/api
```

---

## What's Done ✅

- [x] Dataset: 96 images, 4 classes, labeled
- [x] Model: YOLOv8n trained (50 epochs)
- [x] Backend: FastAPI with JWT, MongoDB
- [x] Frontend: React dashboard with CRUD
- [x] Mobile: Flutter app with camera
- [x] Notebooks: Analysis + inference demo
- [x] Thesis: LaTeX structure complete
- [x] Instructions: 10 guide files

## What's Pending 🔄

- [ ] Improve model accuracy (mAP 49.7% → 70%+)
- [ ] End-to-end integration test
- [ ] Production deployment

---

## Agent Guidelines

### Before Making Changes
1. Read this file completely
2. Check `STEPS.md` for current status
3. Run existing code to understand behavior

### Code Style
| Language | Style |
|----------|-------|
| Python | PEP 8, type hints, async/await |
| Dart/Flutter | Effective Dart, Riverpod patterns |
| JavaScript | ESLint defaults |

### Architecture Rules
1. **Backend:** Routes → Services → Database (no business logic in routes)
2. **Mobile:** Pages → Providers → Services → Repositories
3. **ML:** All inference through `ProductDetector` class

### Testing
- Backend: `pytest tests/`
- Mobile: `flutter test`
- Frontend: `npm test`

### Git Commits
```
feat: add new feature
fix: bug fix
refactor: code restructure
docs: documentation
```

---

## Useful Skills

When working on specific domains, consult these skills:

| Domain | Skill |
|--------|-------|
| YOLOv8 | `yolo` |
| Flutter | `flutter`, `flutter-riverpod-expert` |
| FastAPI | `fastapi-expert` |
| MongoDB | `mongodb` |
| Computer Vision | `senior-computer-vision`, `opencv` |
| Testing | `python-testing`, `flutter-testing` |

---

## Quick Reference

### Login Credentials (Demo)
```
Phone: 88001122
Password: audit123
```

### Model Inference
```python
from src.inference.detector import ProductDetector

detector = ProductDetector("models/weights/product_detector/weights/best.pt")
results = detector.detect("image.jpg")
```

### Audit Decision Logic
```
Difference ≤ 10%  → PASS
10% < Diff ≤ 30%  → WARNING
Difference > 30%  → FAIL
Missing product   → FAIL
Extra product     → WARNING
```

---

## Project Links

- **Roboflow Dataset:** (private)
- **LaTeX Thesis:** `latex/main.tex`
- **API Docs:** `http://localhost:8000/docs`

---

*Last updated: 2026-03-22*
