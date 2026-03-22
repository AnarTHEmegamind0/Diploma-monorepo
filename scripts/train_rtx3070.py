#!/usr/bin/env python3
"""
RTX 3070 дээр YOLO model сургах script.

Usage:
    python scripts/train_rtx3070.py
    python scripts/train_rtx3070.py --preset rtx3070_accurate
    python scripts/train_rtx3070.py --epochs 100 --batch 16
"""

import argparse
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.training.train import train_model, validate_model
from src.training.hyperparams import get_config, PRESETS


def check_cuda():
    """Check if CUDA is available."""
    try:
        import torch
        if torch.cuda.is_available():
            device_name = torch.cuda.get_device_name(0)
            print(f"CUDA available: {device_name}")
            print(f"CUDA version: {torch.version.cuda}")
            return True
        else:
            print("CUDA not available. Training will use CPU (slower).")
            return False
    except Exception as e:
        print(f"Error checking CUDA: {e}")
        return False


def check_dataset():
    """Check if dataset exists."""
    train_path = project_root / "data" / "splits" / "train" / "images"
    val_path = project_root / "data" / "splits" / "val" / "images"
    
    train_count = len(list(train_path.glob("*.jpg"))) + len(list(train_path.glob("*.png")))
    val_count = len(list(val_path.glob("*.jpg"))) + len(list(val_path.glob("*.png")))
    
    print(f"Dataset check:")
    print(f"  Training images: {train_count}")
    print(f"  Validation images: {val_count}")
    
    if train_count == 0:
        print("\nERROR: No training images found!")
        print("Please follow instructions/01_DATA_COLLECTION.md first.")
        return False
    
    return True


def main():
    parser = argparse.ArgumentParser(description="Train YOLO model on RTX 3070")
    parser.add_argument("--preset", type=str, default="rtx3070",
                       choices=list(PRESETS.keys()),
                       help="Training preset (default: rtx3070)")
    parser.add_argument("--epochs", type=int, help="Override epochs")
    parser.add_argument("--batch", type=int, help="Override batch size")
    parser.add_argument("--model", type=str, help="Override model (yolov8n/s/m/l.pt)")
    parser.add_argument("--resume", action="store_true", help="Resume from last checkpoint")
    parser.add_argument("--skip-checks", action="store_true", help="Skip pre-training checks")
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("RTX 3070 YOLO Training Script")
    print("=" * 50)
    
    # Pre-training checks
    if not args.skip_checks:
        print("\n[1/3] Checking CUDA...")
        cuda_ok = check_cuda()
        
        print("\n[2/3] Checking dataset...")
        dataset_ok = check_dataset()
        
        if not dataset_ok:
            print("\nAborting. Please prepare dataset first.")
            sys.exit(1)
        
        print("\n[3/3] Loading configuration...")
    
    # Get config
    config = get_config(args.preset)
    
    # Override with command line args
    if args.epochs:
        config["epochs"] = args.epochs
    if args.batch:
        config["batch"] = args.batch
    if args.model:
        config["model_name"] = args.model
    
    print(f"\nTraining configuration:")
    print(f"  Preset: {args.preset}")
    print(f"  Model: {config.get('model_name', 'yolov8n.pt')}")
    print(f"  Epochs: {config.get('epochs', 50)}")
    print(f"  Batch size: {config.get('batch', 16)}")
    print(f"  Image size: {config.get('imgsz', 640)}")
    print(f"  Device: {config.get('device', 'auto')}")
    
    print("\n" + "=" * 50)
    print("Starting training...")
    print("=" * 50 + "\n")
    
    # Train
    try:
        best_path = train_model(
            data_yaml="models/configs/dataset.yaml",
            model_name=config.get("model_name", "yolov8n.pt"),
            epochs=config.get("epochs", 50),
            imgsz=config.get("imgsz", 640),
            batch=config.get("batch", 16),
            device=config.get("device", "0"),
            patience=config.get("patience", 15),
            resume=args.resume,
        )
        
        print("\n" + "=" * 50)
        print("Training complete!")
        print("=" * 50)
        print(f"\nBest model saved: {best_path}")
        
        # Validate
        print("\nRunning validation...")
        metrics = validate_model(best_path)
        
        print("\n" + "=" * 50)
        print("DONE!")
        print("=" * 50)
        print(f"\nNext steps:")
        print(f"1. Copy .env.example to .env")
        print(f"2. Set MODEL_PATH={best_path}")
        print(f"3. Start backend: uvicorn backend.app.main:app --reload")
        
    except KeyboardInterrupt:
        print("\n\nTraining interrupted by user.")
        sys.exit(0)
    except Exception as e:
        print(f"\nERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
