<div align="center">

# 🎓 МУИС Дипломийн ажил

### Зурагт суурилсан бараа таних, аудитын шийдвэр автоматжуулах ухаалаг систем

<br>

<img src="latex/images/diagrams/architecture.png" alt="Системийн архитектур" width="640">

<br><br>

**Монгол Улсын Их Сургууль**
**Хэрэглээний шинжлэх ухаан, инженерчлэлийн сургууль**
**Мэдээллийн технологийн тэнхим**

<br>

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![React](https://img.shields.io/badge/React-18.3-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![YOLOv8](https://img.shields.io/badge/YOLOv8-Ultralytics-00FFFF?style=for-the-badge&logo=yolo&logoColor=black)](https://ultralytics.com/)

<br>

[Танилцуулга](#-танилцуулга) •
[Онцлогууд](#-онцлогууд) •
[Архитектур](#-архитектур) •
[Технологи](#-ашигласан-технологи) •
[Суулгах](#-суулгах-заавар) •
[Үр дүн](#-туршилтын-үр-дүн)

</div>

---

## 📖 Танилцуулга

Энэхүү бакалаврын дипломын ажил нь **жижиглэн худалдааны салбарт** бараа бүтээгдэхүүний тооллого болон лангуун дээрх аудитын үйл явцыг **компьютерийн хараа** ба **гүн сургалтын** аргаар автоматжуулсан **бүрэн төгсгөл-хоорондын ухаалаг систем** боловсруулсан судалгааны бүтээл юм.

Систем нь дэлгүүрийн лангуун дээрх барааны зургийг авч, **YOLOv8 объект илрүүлэлтийн загвар**-аар бараа бүтээгдэхүүнийг автомат таних, хүлээгдэж буй жагсаалттай харьцуулан **PASS / WARNING / FAIL** гэсэн аудитын шийдвэрийг бодит цаг хугацаанд гаргах боломжтой.

### 🎯 Шийдвэрлэж буй асуудал

Уламжлалт лангууны аудит нь дараах дутагдалтай:

- ❌ **Хүний хүчин зүйлийн алдаа** — тоолох, ялгахад
- ⏳ **Цаг хугацаа их шаардсан** — гар ажиллагаа удаан
- 📉 **Аудиторуудын чанарын ялгаатай байдал**
- 📊 **Тайлан, шийдвэрийн саатал**

### 💡 Бидний шийдэл

- ✅ YOLOv8-д суурилсан **автомат бараа илрүүлэлт**
- ✅ Бодит цаг хугацааны **аудитын шийдвэр** (PASS / WARNING / FAIL)
- ✅ Талбарт ажилладаг аудиторт зориулсан **mobile-first** хэрэглүүр
- ✅ Менежер, админуудад зориулсан **төвлөрсөн самбар**
- ✅ Түүхэн өгөгдлийн **аналитик ба тайлан**

---

## ✨ Онцлогууд

<table>
<tr>
<td width="50%" valign="top">

### 📱 Мобайл аппликэйшн (Flutter)
- Камераар лангууны зураг авах
- Бараа илрүүлэлтийн үр дүнг бодит хугацаанд харуулах
- Аудитын түүх ба статистик
- Офлайн ажиллагаатай дизайн
- GPS байршил тэмдэглэх

</td>
<td width="50%" valign="top">

### 🌐 Веб самбар (React)
- Аудитын явц бодит хугацаанд хяналт
- Кампанит ажлын менежмент
- Аудиторын хуваарилалт
- Drag & drop санал асуулга үүсгэгч
- Аналитик, тайлан

</td>
</tr>
<tr>
<td width="50%" valign="top">

### ⚡ Backend API (FastAPI)
- JWT-д суурилсан баталгаажуулалт
- Асинхрон MongoDB үйлдлүүд
- Зураг боловсруулах урсгал
- Аудитын шийдвэрийн хөдөлгүүр
- Кампанит ажил, санал асуулгын API

</td>
<td width="50%" valign="top">

### 🤖 ML Pipeline (YOLOv8)
- Тусгайлан сургасан илрүүлэлтийн загвар
- 4 төрлийн бараа (өргөтгөх боломжтой)
- Өгөгдөл өргөтгөх (augmentation) урсгал
- Загвар үнэлэх багаж хэрэгсэл

</td>
</tr>
</table>

---

## 🏗 Архитектур

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          СИСТЕМИЙН ЕРӨНХИЙ АРХИТЕКТУР                          │
└──────────────────────────────────────────────────────────────────────────────┘

   ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
   │   Flutter    │         │    React     │         │   YOLOv8     │
   │ Мобайл апп   │         │   Самбар     │         │   Загвар     │
   │              │         │              │         │              │
   │  • Камер     │         │  • Кампанит  │         │  • Сургалт   │
   │  • Асуулга   │         │  • Аудитор   │         │  • Inference │
   │  • Түүх      │         │  • Аналитик  │         │  • Export    │
   └──────┬───────┘         └──────┬───────┘         └──────┬───────┘
          │                        │                        │
          │         HTTP/REST      │                        │
          └────────────┬───────────┘                        │
                       │                                    │
                       ▼                                    │
          ┌────────────────────────┐                        │
          │     FastAPI Backend    │◄───────────────────────┘
          │                        │
          │  ┌──────────────────┐  │
          │  │ Authentication   │  │
          │  │      (JWT)       │  │
          │  └──────────────────┘  │
          │                        │
          │  ┌──────────────────┐  │
          │  │ Detection Service│  │──── ProductDetector (YOLO)
          │  └──────────────────┘  │
          │                        │
          │  ┌──────────────────┐  │
          │  │   Audit Engine   │  │──── PASS / WARNING / FAIL логик
          │  └──────────────────┘  │
          └───────────┬────────────┘
                      │
                      ▼
          ┌────────────────────────┐
          │       MongoDB          │
          │                        │
          │  • audits              │
          │  • detections          │
          │  • products            │
          │  • campaigns           │
          │  • auditors            │
          │  • tradeshops          │
          └────────────────────────┘
```

---

## 🛠 Ашигласан технологи

| Бүрэлдэхүүн хэсэг | Технологи | Хувилбар |
|---|---|---|
| 📱 **Мобайл аппликэйшн** | Flutter / Dart | 3.x |
| 🌐 **Веб самбар** | React.js | 18.3 |
| ⚡ **Backend API** | FastAPI | 0.115 |
| 🗄 **Өгөгдлийн сан** | MongoDB | 7.0 |
| 🧠 **ML Framework** | Ultralytics YOLOv8 | 8.3 |
| 🔥 **Гүн сургалт** | PyTorch | 2.9 |
| 👁 **Компьютерийн харах** | OpenCV | 4.12 |
| 🔐 **Баталгаажуулалт** | JWT (PyJWT) | — |
| 🐳 **Контейнержуулалт** | Docker Compose | 3.8 |

---

## 🚀 Суулгах заавар

### 📋 Шаардлагатай зүйлс

- Python **3.10+**
- Node.js **18+**
- Flutter SDK **3.x**
- MongoDB **7.0+**
- Docker & Docker Compose *(сонголтоор)*

### 🔧 Backend (Сервер) суулгах

```bash
# 1. Repo татах
git clone https://github.com/AnarTHEmegamind0/Diploma-monorepo.git
cd Diploma-monorepo

# 2. Виртуал орчин үүсгэх
python -m venv venv
source venv/bin/activate         # Windows дээр: venv\Scripts\activate

# 3. Хамаарлуудаа суулгах
pip install -r requirements.txt

# 4. Орчны хувьсагч тохируулах
cp .env.example .env             # дотроо тохиргоогоо засна уу

# 5. MongoDB асаах
docker-compose up mongodb -d

# 6. Backend асаах
uvicorn backend.app.main:app --reload --port 8000
```

### 💻 Frontend (Веб самбар) суулгах

```bash
cd frontend
npm install
npm start
```

### 📱 Mobile App (Flutter) суулгах

```bash
cd application
flutter pub get
flutter run
```

### 🐳 Бүрэн Docker ажиллуулах

```bash
docker-compose up --build
```

---

## 📲 Хэрэглээний урсгал

### 1️⃣ Админ нэвтрэх
`http://localhost:3000` дээр админ эрхээр нэвтэрнэ.

### 2️⃣ Кампанит ажил үүсгэх
Кампанит ажил → шинэ үүсгэх → аудитор болон дэлгүүрүүдийг сонгох.

### 3️⃣ Мобайл аудитын урсгал
1. Аудитор мобайл аппд нэвтрэх
2. Хуваарилагдсан кампанит ажлаа сонгох
3. Дэлгүүрт очих
4. Лангууны зургийг авах
5. Систем барааг автомат таних
6. Санал асуулгын асуултуудад хариулах
7. Аудитаа илгээх

### 4️⃣ Үр дүн харах
Самбар дээр **PASS / WARNING / FAIL** төлөвтэйгөөр бодит цаг хугацаанд харагдана.

---

## 📦 Өгөгдлийн сан (Dataset)

### Барааны ангилал

| ID | Нэр | Тайлбар |
|----|-----|---------|
| 0 | `bonaqua_500ml` | Бонаква рашаан 500мл |
| 1 | `coca_cola_500ml` | Кока-Кола 500мл |
| 2 | `fanta_500ml` | Фанта (бүх амт) 500мл |
| 3 | `sprite_500ml` | Спрайт 500мл |

### Статистик

| Үзүүлэлт | Утга |
|----------|------|
| Нийт зураг | **613** |
| Нийт annotations | **3,220** |
| Train set | 429 зураг (70%) |
| Validation set | 122 зураг (20%) |
| Test set | 62 зураг (10%) |
| Annotation арга | Roboflow SAM3 Auto-labeling |
| Label формат | YOLO Bounding Box |

---

## 📊 Туршилтын үр дүн

### Загварын гүйцэтгэл

| Метрик | Утга |
|--------|------|
| **mAP@50** | **0.940** |
| **mAP@50-95** | **0.704** |
| **Precision** | **0.920** |
| **Recall** | **0.878** |
| Inference хугацаа | ~3.2мс / зураг (RTX 3070) |

### Аудитын шийдвэрийн логик

| Нөхцөл | Шийдвэр |
|---------|---------|
| Зөрүү ≤ 10% | 🟢 **PASS** |
| 10% < Зөрүү ≤ 30% | 🟡 **WARNING** |
| Зөрүү > 30% | 🔴 **FAIL** |
| Хүлээгдэж буй бараа байхгүй | 🔴 **FAIL** |
| Илүү бараа илрүүлсэн | 🟡 **WARNING** |

---

## 🔌 API лавлагаа

### Нэвтрэлт
```http
POST /api/auth/login
Content-Type: application/json

{
  "phone": "88001122",
  "password": "audit123"
}
```

### Бараа илрүүлэлт
```http
POST /api/detection/detect
Content-Type: multipart/form-data

file: <image>
```

### Аудит ажиллуулах
```http
POST /api/audit/run
Content-Type: application/json

{
  "expected_inventory": {...},
  "detected_products": {...}
}
```

> 📚 **Бүрэн API баримт бичиг:** Backend асааж байгаад `http://localhost:8000/docs` руу зочлоорой.

---

## 📁 Төслийн бүтэц

```
Diploma-monorepo/
├── application/           # 📱 Flutter мобайл апп
│   ├── lib/
│   │   ├── features/      # Үндсэн feature-үүд
│   │   ├── core/          # Constants, utils
│   │   └── main.dart
│   └── pubspec.yaml
│
├── backend/               # ⚡ FastAPI сервер
│   └── app/
│       ├── main.py
│       ├── config.py
│       ├── models/        # Pydantic schemas
│       ├── routes/        # API endpoints
│       └── services/      # Бизнес логик
│
├── frontend/              # 🌐 React самбар
│   └── src/
│       ├── pages/
│       ├── components/
│       └── services/
│
├── src/                   # 🤖 ML pipeline
│   ├── data/              # Өгөгдөл боловсруулалт
│   ├── training/          # Загвар сургалт
│   ├── inference/         # Detection + Audit
│   └── utils/
│
├── data/                  # 📦 Dataset
│   ├── raw/
│   └── splits/            # Train / Val / Test
│
├── models/                # 🧠 Сургасан загварууд
│   ├── configs/
│   └── weights/
│
├── latex/                 # 📄 Дипломийн ажлын LaTeX эх
├── notebooks/             # 📓 Jupyter notebooks
├── scripts/               # 🔧 Туслах скриптүүд
├── tests/                 # 🧪 Unit тестүүд
│
├── docker-compose.yml
├── requirements.txt
└── README.md
```

---

## 🏋️ Загвар сургах

### Windows + RTX 3070 дээр

```bash
venv\Scripts\activate

python scripts/train_rtx3070.py --epochs 100 --batch 16

python scripts/test_model.py --evaluate
```

### Сургалтын тохиргоо

- **Үндсэн загвар:** YOLOv8n (nano)
- **Epochs:** 100
- **Зургийн хэмжээ:** 640 × 640
- **Batch size:** 16
- **Optimizer:** SGD

---

## 📜 Дипломийн ажлын баримт бичиг

- 📄 [`thesis.pdf`](./thesis.pdf) — Дипломийн ажлын бүрэн эх (LaTeX-р эмхэтгэсэн)
- 📁 [`latex/`](./latex/) — LaTeX эх файлууд
- 🎨 [`diagrams/`](./diagrams/) — Mermaid диаграммууд

---

## 👨‍🎓 Зохиогч

<table>
<tr>
<td valign="top">

**Анарын Түвшинжаргал**

🎓 **Сургууль:** Монгол Улсын Их Сургууль (МУИС)
🏛 **Сургууль:** Хэрэглээний шинжлэх ухаан, инженерчлэлийн сургууль
💻 **Тэнхим:** Мэдээллийн технологи
📅 **Хичээлийн жил:** 2025 – 2026

</td>
</tr>
</table>

---

## 🙏 Талархал

- 👨‍🏫 **Удирдагч багш:** Ж. Жавхлан
- 🏷 **Roboflow** — annotation хийх багаж хэрэгсэл
- 🚀 **Ultralytics** — YOLOv8 framework
- ⚡ **FastAPI** community — баримт бичиг
- 🎓 **МУИС, ХШУИС, МТТ** — судалгааны орчин олгосонд

---

## 📄 Лиценз

Энэхүү төсөл нь **Монгол Улсын Их Сургуулийн бакалаврын дипломын ажил**-ын зорилгоор боловсруулагдсан бөгөөд **боловсролын зориулалтаар** ашиглах боломжтой.

---

<div align="center">

### ⭐ Хэрэв та энэ төслийг ашиглан судалгаа хийсэн бол энд од дарна уу!

<br>

**Made with ❤️ at МУИС · 2026**

<sub>Built for the future of retail automation in Mongolia 🇲🇳</sub>

</div>
