# 09. Хамгаалалтын Presentation Бэлдэх

## Тойм

Энэ заавар нь дипломын ажлын хамгаалалтын PPT-г хэрхэн бэлдэхийг тайлбарлана.

---

## PPT Бүтэц (30 хуудас)

| Хэсэг | Хуудас | Агуулга |
|-------|--------|---------|
| Нүүр | 1 | Гарчиг, нэр, удирдагч |
| Агуулга | 1 | Slide-ын бүтэц |
| Асуудал | 2 | Яагаад энэ төсөл хэрэгтэй |
| Зорилго | 2 | Юу хийхийг зорьсон |
| Онол | 4 | CV, Object Detection, YOLO |
| Архитектур | 3 | Системийн бүтэц |
| Технологи | 2 | Tech stack |
| Dataset | 3 | Дата цуглуулалт |
| Model | 4 | Training, үр дүн |
| Backend | 2 | FastAPI, MongoDB |
| Frontend | 2 | React, Flutter |
| Demo | 3 | Screenshots, results |
| Дүгнэлт | 1 | Conclusion |

---

## Зураг авах газрууд

### Training graphics
```
models/weights/product_detector/
├── thesis_loss_curves.png       # Loss муруй
├── thesis_metrics_curves.png    # mAP, Precision, Recall
├── thesis_class_distribution.png # Ангилал тархалт
├── thesis_dataset_distribution.png # Dataset split
├── thesis_performance_summary.png # Үр дүнгийн хүснэгт
├── thesis_inference_samples.png # Detection жишээ
├── confusion_matrix.png         # Confusion matrix
└── results.png                  # Training results
```

### Screenshots
```
latex/images/
├── diagrams/architecture.png    # System architecture
├── backoffice/*.png             # React dashboard
└── application/*.png            # Flutter app
```

---

## PPT Хийх Алхмууд

### 1. Template сонгох
- Google Slides эсвэл PowerPoint
- Энгийн, professional template
- NUM/МУИС лого нэмэх

### 2. Slide-ууд үүсгэх
- `docs/ppt_making.md` файлын prompt-уудыг дагах
- Зураг, диаграмм нэмэх
- Bullet point товч байлгах

### 3. Demo бэлдэх
```bash
# Backend эхлүүлэх
uvicorn backend.app.main:app --reload --port 8000

# Frontend
cd frontend && npm start

# Mobile
cd application && flutter run
```

### 4. Дасгал хийх
- 10-15 минут presentation
- Асуултад бэлдэх
- Timing шалгах

---

## Хамгаалалтын Асуултууд

### Техникийн асуултууд
1. "Яагаад YOLOv8 сонгосон бэ?"
2. "mAP 49.7% бага биш үү?"
3. "Өөр бүтээгдэхүүн нэмэхэд яах вэ?"
4. "Real-time inference хурд хэд вэ?"

### Методологийн асуултууд
1. "Dataset хэрхэн цуглуулсан бэ?"
2. "Labeling хэрхэн хийсэн бэ?"
3. "Train/Val/Test яагаад 70/20/10 хуваасан бэ?"

### Ирээдүйн асуултууд
1. "Production-д deploy хийхэд юу хэрэгтэй вэ?"
2. "Scaling хэрхэн хийх вэ?"
3. "Edge device дээр ажиллуулж болох уу?"

---

## Checklist

- [ ] PPT 30 хуудас бэлэн
- [ ] Бүх зураг оруулсан
- [ ] Demo ажиллаж байгаа
- [ ] Асуултад бэлтгэсэн
- [ ] Хугацаа шалгасан (10-15 мин)
- [ ] Backup PDF хийсэн

---

## Дэлгэрэнгүй

Бүрэн prompt-ууд болон slide бүрийн агуулгыг:
```
docs/ppt_making.md
```
файлаас харна уу.
