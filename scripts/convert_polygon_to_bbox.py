"""
Convert polygon labels to YOLO bounding box format.
Roboflow exported segmentation (polygon) format - need to convert to bbox.
"""

import os
from pathlib import Path

def polygon_to_bbox(polygon_line: str) -> str:
    """Convert polygon line to bounding box format."""
    parts = polygon_line.strip().split()
    if len(parts) < 5:
        return None
    
    class_id = parts[0]
    coords = [float(x) for x in parts[1:]]
    
    # Extract x and y coordinates
    x_coords = coords[0::2]  # Every other starting from 0
    y_coords = coords[1::2]  # Every other starting from 1
    
    if len(x_coords) < 2 or len(y_coords) < 2:
        return None
    
    # Calculate bounding box
    x_min = min(x_coords)
    x_max = max(x_coords)
    y_min = min(y_coords)
    y_max = max(y_coords)
    
    # Convert to YOLO format (center_x, center_y, width, height)
    x_center = (x_min + x_max) / 2
    y_center = (y_min + y_max) / 2
    width = x_max - x_min
    height = y_max - y_min
    
    # Clamp values to [0, 1]
    x_center = max(0, min(1, x_center))
    y_center = max(0, min(1, y_center))
    width = max(0, min(1, width))
    height = max(0, min(1, height))
    
    return f"{class_id} {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}"

def convert_labels_in_folder(labels_dir: Path):
    """Convert all label files in a folder."""
    txt_files = list(labels_dir.glob("*.txt"))
    total_converted = 0
    
    for txt_path in txt_files:
        with open(txt_path, 'r') as f:
            lines = f.readlines()
        
        new_lines = []
        for line in lines:
            if line.strip():
                bbox_line = polygon_to_bbox(line)
                if bbox_line:
                    new_lines.append(bbox_line)
        
        # Write back
        with open(txt_path, 'w') as f:
            f.write('\n'.join(new_lines))
        
        total_converted += len(new_lines)
    
    return len(txt_files), total_converted

def main():
    splits_dir = Path("data/splits")
    
    print("Converting polygon labels to YOLO bounding box format...\n")
    
    total_files = 0
    total_boxes = 0
    
    for split in ["train", "val", "test"]:
        labels_dir = splits_dir / split / "labels"
        if labels_dir.exists():
            files, boxes = convert_labels_in_folder(labels_dir)
            total_files += files
            total_boxes += boxes
            print(f"✓ {split}: {files} files, {boxes} bounding boxes")
    
    print(f"\n✅ Done! Converted {total_files} files with {total_boxes} total bounding boxes")

if __name__ == "__main__":
    main()
