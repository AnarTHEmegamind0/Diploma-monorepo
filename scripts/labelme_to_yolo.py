"""
Convert labelme JSON annotations to YOLO format.
Run after labeling with labelme.
"""

import json
import os
from pathlib import Path

# Class mapping (same as classes.txt)
CLASSES = [
    "coca_cola_500ml",
    "pepsi_500ml", 
    "fanta_500ml",
    "sprite_500ml",
    "bonaqua_500ml",
    "vittel_500ml",
    "rich_orange_1l",
    "dobry_apple_1l"
]

def convert_labelme_to_yolo(json_path: Path, output_dir: Path):
    """Convert a single labelme JSON file to YOLO format."""
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    img_width = data['imageWidth']
    img_height = data['imageHeight']
    
    yolo_lines = []
    
    for shape in data['shapes']:
        if shape['shape_type'] != 'rectangle':
            continue
            
        label = shape['label']
        if label not in CLASSES:
            print(f"Warning: Unknown class '{label}' in {json_path}")
            continue
            
        class_id = CLASSES.index(label)
        
        # Get bounding box points
        points = shape['points']
        x1, y1 = points[0]
        x2, y2 = points[1]
        
        # Convert to YOLO format (center_x, center_y, width, height) normalized
        x_center = ((x1 + x2) / 2) / img_width
        y_center = ((y1 + y2) / 2) / img_height
        width = abs(x2 - x1) / img_width
        height = abs(y2 - y1) / img_height
        
        yolo_lines.append(f"{class_id} {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}")
    
    # Write YOLO format file
    output_path = output_dir / (json_path.stem + '.txt')
    with open(output_path, 'w') as f:
        f.write('\n'.join(yolo_lines))
    
    return len(yolo_lines)

def main():
    raw_dir = Path("data/raw")
    labels_dir = Path("data/labeled/labels")
    images_dir = Path("data/labeled/images")
    
    labels_dir.mkdir(parents=True, exist_ok=True)
    images_dir.mkdir(parents=True, exist_ok=True)
    
    json_files = list(raw_dir.glob("*.json"))
    
    if not json_files:
        print("No JSON files found in data/raw/")
        print("Please label images with labelme first:")
        print("  labelme data/raw --labels data/raw/labels.txt --output data/raw")
        return
    
    total_annotations = 0
    
    for json_path in json_files:
        count = convert_labelme_to_yolo(json_path, labels_dir)
        total_annotations += count
        
        # Copy corresponding image to labeled/images
        for ext in ['.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG']:
            img_path = raw_dir / (json_path.stem + ext)
            if img_path.exists():
                import shutil
                shutil.copy(img_path, images_dir / img_path.name)
                break
        
        print(f"Converted: {json_path.name} ({count} annotations)")
    
    print(f"\n✅ Done! Converted {len(json_files)} files with {total_annotations} total annotations")
    print(f"Labels saved to: {labels_dir}")
    print(f"Images copied to: {images_dir}")

if __name__ == "__main__":
    main()
