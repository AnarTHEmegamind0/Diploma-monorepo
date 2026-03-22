# Windows + RTX 3070 Суулгах Заавар

## Шаардлага

- Windows 10 эсвэл Windows 11
- NVIDIA RTX 3070 GPU
- 16GB+ RAM санал болгоно
- 50GB+ хоосон зай

---

## Алхам 1: Python суулгах

### 1.1 Python татах

1. https://python.org руу орно
2. "Downloads" → "Python 3.11.x" татах (3.10 эсвэл 3.11 санал болгоно)
3. Installer ажиллуулах

### 1.2 Чухал тохиргоо!

Installer дээр **заавал** шалгах:
- [x] "Add Python to PATH"
- [x] "Install pip"

### 1.3 Шалгах

Command Prompt нээж:
```cmd
python --version
pip --version
```

---

## Алхам 2: NVIDIA Driver суулгах

### 2.1 Шинэ driver татах

1. https://www.nvidia.com/drivers руу орно
2. RTX 3070 сонгоно
3. "Game Ready Driver" татах
4. Суулгах

### 2.2 Шалгах

```cmd
nvidia-smi
```

Ийм гарах ёстой:
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 535.xxx       Driver Version: 535.xxx       CUDA Version: 12.x   |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  WDDM | 00000000:01:00.0  On |                  N/A |
|  0%   35C    P8    15W / 220W |    500MiB /  8192MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
```

---

## Алхам 3: CUDA Toolkit суулгах (Заавал биш)

PyTorch өөрөө CUDA-тай ирдэг. Гэхдээ хүсвэл:

1. https://developer.nvidia.com/cuda-toolkit руу орно
2. CUDA 12.1 эсвэл 12.4 татах
3. Суулгах (Express Installation)

---

## Алхам 4: Project татах

### 4.1 Git суулгах (хэрэв байхгүй бол)

https://git-scm.com/download/win

### 4.2 Project clone хийх

```cmd
cd C:\Users\YourName\Projects
git clone https://github.com/YOUR_REPO/inventory_project.git
cd inventory_project
```

---

## Алхам 5: Environment бэлдэх

### Автомат (Санал болгоно):

```cmd
scripts\setup_windows.bat
```

### Гараар хийх бол:

```cmd
REM Virtual environment үүсгэх
python -m venv venv

REM Идэвхжүүлэх
venv\Scripts\activate.bat

REM Dependencies суулгах
pip install --upgrade pip
pip install -r requirements.txt
```

---

## Алхам 6: CUDA шалгах

```cmd
venv\Scripts\activate.bat
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'Device: {torch.cuda.get_device_name(0)}' if torch.cuda.is_available() else 'No GPU')"
```

**Хүлээгдэж буй үр дүн:**
```
CUDA available: True
Device: NVIDIA GeForce RTX 3070
```

---

## Алхам 7: .env файл тохируулах

```cmd
copy .env.example .env
notepad .env
```

Засах:
```env
TRAINING_DEVICE=0
TRAINING_BATCH_SIZE=16
TRAINING_EPOCHS=50
```

---

## Алхам 8: Model сургах

### Зураг бэлдсний дараа:

```cmd
REM Activate environment
venv\Scripts\activate.bat

REM Training эхлүүлэх
python scripts/train_rtx3070.py
```

### Эсвэл batch script:

```cmd
scripts\train_windows.bat
```

---

## Түгээмэл Асуудлууд

### 1. "CUDA out of memory"

**Шийдэл:** Batch size бууруулах
```cmd
python scripts/train_rtx3070.py --batch 8
```

### 2. "torch.cuda.is_available() returns False"

**Шийдэл:**
1. NVIDIA driver шинэчлэх
2. PyTorch дахин суулгах:
```cmd
pip uninstall torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
```

### 3. "DLL load failed"

**Шийдэл:** Visual C++ Redistributable суулгах
https://aka.ms/vs/17/release/vc_redist.x64.exe

### 4. Python PATH-д байхгүй

**Шийдэл:**
1. Windows Search → "Environment Variables"
2. "Path" → Edit
3. Python болон Scripts хавтасуудыг нэмэх:
   - `C:\Users\YourName\AppData\Local\Programs\Python\Python311`
   - `C:\Users\YourName\AppData\Local\Programs\Python\Python311\Scripts`

---

## Training Хугацаа (RTX 3070)

| Dataset | Epochs | Хугацаа |
|---------|--------|---------|
| 300 зураг | 50 | ~10-15 мин |
| 500 зураг | 50 | ~15-20 мин |
| 300 зураг | 100 | ~20-30 мин |
| 1000 зураг | 100 | ~1 цаг |

---

## Хураангуй Commands

```cmd
REM Environment идэвхжүүлэх
venv\Scripts\activate.bat

REM CUDA шалгах
python -c "import torch; print(torch.cuda.is_available())"

REM Dataset хуваах
python -m src.data.split_dataset

REM Training эхлүүлэх
python scripts/train_rtx3070.py

REM Validation хийх
python -m src.training.evaluate
```

---

## Дараагийн Алхам

1. Зураг цуглуулах: `instructions/01_DATA_COLLECTION.md`
2. Label хийх: `instructions/02_LABELING.md`
3. Training: `python scripts/train_rtx3070.py`
