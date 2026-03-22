# Phase 7: Docker Deployment Заавар

## Зорилго

Системийг Docker container-ууд дээр ажиллуулж, хялбар deploy хийх боломжтой болгох.

---

## Урьдчилсан Нөхцөл

1. ✅ Docker Desktop суусан
2. ✅ Docker Compose суусан
3. ✅ Бүх тест амжилттай

---

## Docker Compose Бүтэц

```yaml
# docker-compose.yml
services:
  mongodb:     # Database
  backend:     # FastAPI + YOLO
  frontend:    # React Dashboard
```

---

## Алхам 1: Docker Desktop эхлүүлэх

1. Docker Desktop app нээх
2. Ажиллаж байгаа эсэхийг шалгах:
```bash
docker --version
docker-compose --version
```

---

## Алхам 2: Бүгдийг нэг дор эхлүүлэх

```bash
# Бүх services-ийг build хийж эхлүүлэх
docker-compose up --build
```

**Үр дүн:**
```
Creating network "inventory_project_default"
Creating inventory_mongodb  ... done
Creating inventory_backend  ... done
Creating inventory_frontend ... done
Attaching to inventory_mongodb, inventory_backend, inventory_frontend
```

---

## Алхам 3: Services шалгах

### MongoDB:
```bash
# MongoDB ажиллаж байгаа эсэх
docker ps | grep mongo
```

### Backend:
```bash
# Health check
curl http://localhost:8000/health
```

### Frontend:
```bash
# Browser-аар нээх
open http://localhost:3000
```

---

## Алхам 4: Logs харах

```bash
# Бүх logs
docker-compose logs

# Зөвхөн backend
docker-compose logs backend

# Real-time logs
docker-compose logs -f backend
```

---

## Алхам 5: Container руу орох

```bash
# Backend container руу орох
docker-compose exec backend bash

# MongoDB руу орох
docker-compose exec mongodb mongosh inventory_audit
```

---

## Алхам 6: Зогсоох

```bash
# Бүгдийг зогсоох
docker-compose down

# Өгөгдөлтэй нь устгах
docker-compose down -v
```

---

## Docker Commands Хураангуй

| Command | Тайлбар |
|---------|---------|
| `docker-compose up` | Эхлүүлэх |
| `docker-compose up --build` | Build хийж эхлүүлэх |
| `docker-compose up -d` | Background-д эхлүүлэх |
| `docker-compose down` | Зогсоох |
| `docker-compose logs` | Logs харах |
| `docker-compose ps` | Status харах |
| `docker-compose exec <service> bash` | Container руу орох |

---

## Production Deployment

### 1. Environment variables тохируулах:

```bash
# Production .env файл
MONGODB_URI=mongodb://production-server:27017
API_DEBUG=false
MODEL_PATH=/app/models/weights/best.pt
```

### 2. Build хийх:

```bash
docker-compose -f docker-compose.prod.yml build
```

### 3. Server дээр ажиллуулах:

```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## Түгээмэл Асуудлууд

### 1. Port conflict

```bash
# Port 8000 ашиглагдаж байна
Error: port 8000 already in use
```

**Шийдэл:**
```bash
# Ашиглаж буй process олох
lsof -i :8000
# Process зогсоох
kill -9 <PID>
```

### 2. Build failed

```bash
# Dependencies error
```

**Шийдэл:**
```bash
# Cache устгаж дахин build
docker-compose build --no-cache
```

### 3. MongoDB connection failed

**Шийдэл:** MongoDB container эхлэхийг хүлээх
```yaml
# docker-compose.yml дээр depends_on нэмэх
backend:
  depends_on:
    - mongodb
```

---

## Дараагийн Алхам

Deploy хийж дууссаны дараа:

➡️ `07_DOCUMENTATION.md` - Thesis documentation бичих
