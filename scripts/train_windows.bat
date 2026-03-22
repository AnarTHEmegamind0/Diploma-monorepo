@echo off
REM ================================================
REM Windows Training Script - RTX 3070
REM ================================================

echo ================================================
echo YOLO Training - RTX 3070
echo ================================================
echo.

REM Activate virtual environment
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo ERROR: Virtual environment not found!
    echo Run setup_windows.bat first.
    pause
    exit /b 1
)

REM Check for training images
echo Checking dataset...
dir /b data\splits\train\images\*.jpg 2>nul | find /c /v "" > temp_count.txt
set /p IMAGE_COUNT=<temp_count.txt
del temp_count.txt

if %IMAGE_COUNT%==0 (
    echo.
    echo ERROR: No training images found!
    echo Please follow instructions/01_DATA_COLLECTION.md first.
    echo.
    pause
    exit /b 1
)

echo Found %IMAGE_COUNT% training images.
echo.

REM Run training
echo Starting training...
echo.
python scripts/train_rtx3070.py %*

echo.
pause
