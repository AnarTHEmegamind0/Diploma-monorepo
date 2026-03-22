@echo off
REM ================================================
REM Windows Setup Script for Inventory Audit System
REM RTX 3070 + CUDA + Python Environment
REM ================================================

echo ================================================
echo Inventory Audit System - Windows Setup
echo ================================================
echo.

REM Check Python
echo [1/5] Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Please install Python 3.10+ from https://python.org
    pause
    exit /b 1
)
python --version

REM Check pip
echo.
echo [2/5] Checking pip...
pip --version

REM Create virtual environment
echo.
echo [3/5] Creating virtual environment...
if exist "venv" (
    echo Virtual environment already exists.
) else (
    python -m venv venv
    echo Virtual environment created.
)

REM Activate virtual environment
echo.
echo [4/5] Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo.
echo [5/5] Installing dependencies...
pip install --upgrade pip
pip install -r requirements.txt

REM Check CUDA
echo.
echo ================================================
echo Checking CUDA availability...
echo ================================================
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}' if torch.cuda.is_available() else 'No CUDA')"

echo.
echo ================================================
echo Setup complete!
echo ================================================
echo.
echo Next steps:
echo 1. Copy .env.example to .env
echo 2. Collect training images (see instructions/01_DATA_COLLECTION.md)
echo 3. Label images with LabelImg (see instructions/02_LABELING.md)
echo 4. Run training: python scripts/train_rtx3070.py
echo.
echo To activate environment later:
echo   venv\Scripts\activate.bat
echo.
pause
