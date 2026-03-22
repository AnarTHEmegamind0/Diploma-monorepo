"""
Split Roboflow dataset into train/val/test sets.
70% train, 20% val, 10% test
"""

import os
import shutil
import random
from pathlib import Path

# Paths
ROBOFLOW_DIR = Path("ProductDetection.yolov8/train")
OUTPUT_DIR = Path("data/splits")

# Split ratios
TRAIN_RATIO = 0.70
VAL_RATIO = 0.20
TEST_RATIO = 0.10

def main():
    random.seed(42)  # For reproducibility
    
    # Get all image files
    images_dir = ROBOFLOW_DIR / "images"
    labels_dir = ROBOFLOW_DIR / "labels"
    
    image_files = list(images_dir.glob("*.jpg"))
    print(f"Found {len(image_files)} images")
    
    # Shuffle
    random.shuffle(image_files)
    
    # Calculate split sizes
    total = len(image_files)
    train_size = int(total * TRAIN_RATIO)
    val_size = int(total * VAL_RATIO)
    test_size = total - train_size - val_size
    
    print(f"Split: train={train_size}, val={val_size}, test={test_size}")
    
    # Split files
    train_files = image_files[:train_size]
    val_files = image_files[train_size:train_size + val_size]
    test_files = image_files[train_size + val_size:]
    
    # Copy files to respective folders
    splits = [
        ("train", train_files),
        ("val", val_files),
        ("test", test_files)
    ]
    
    for split_name, files in splits:
        img_out = OUTPUT_DIR / split_name / "images"
        lbl_out = OUTPUT_DIR / split_name / "labels"
        
        img_out.mkdir(parents=True, exist_ok=True)
        lbl_out.mkdir(parents=True, exist_ok=True)
        
        for img_path in files:
            # Copy image
            shutil.copy(img_path, img_out / img_path.name)
            
            # Copy label (same name but .txt)
            label_name = img_path.stem + ".txt"
            label_path = labels_dir / label_name
            if label_path.exists():
                shutil.copy(label_path, lbl_out / label_name)
            else:
                print(f"Warning: No label for {img_path.name}")
        
        print(f"✓ {split_name}: {len(files)} images copied")
    
    print("\n✅ Dataset split complete!")
    print(f"Output directory: {OUTPUT_DIR}")

if __name__ == "__main__":
    main()
