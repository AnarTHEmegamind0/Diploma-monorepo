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
for /f %%A in ('dir /b /a-d data\splits\train\images\*.jpg data\splits\train\images\*.jpeg data\splits\train\images\*.png 2^>nul ^| find /c /v ""') do set IMAGE_COUNT=%%A

if %IMAGE_COUNT%==0 (
    echo.
    echo ERROR: No training images found!
    echo Please check data\splits\train\images and dataset import first.
    echo.
    pause
    exit /b 1
)

echo Found %IMAGE_COUNT% training images.
if exist "data\splits\val\images" (
    for /f %%A in ('dir /b /a-d data\splits\val\images\*.jpg data\splits\val\images\*.jpeg data\splits\val\images\*.png 2^>nul ^| find /c /v ""') do set VAL_COUNT=%%A
    echo Validation images: %VAL_COUNT%
)
if exist "data\splits\test\images" (
    for /f %%A in ('dir /b /a-d data\splits\test\images\*.jpg data\splits\test\images\*.jpeg data\splits\test\images\*.png 2^>nul ^| find /c /v ""') do set TEST_COUNT=%%A
    echo Test images: %TEST_COUNT%
)
echo.

REM Run training
echo Starting training...
echo.
python scripts/train_rtx3070.py %*

echo.
pause
