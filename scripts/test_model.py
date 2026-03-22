#!/usr/bin/env python3
"""
Test trained YOLO model on images.

Usage:
    python scripts/test_model.py                           # Test on test set
    python scripts/test_model.py --image path/to/image.jpg # Test single image
    python scripts/test_model.py --visualize               # Show detection results
"""

import argparse
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))


def find_best_model() -> Path:
    """Find the best trained model."""
    weights_dir = project_root / "models" / "weights" / "product_detector" / "weights"
    best_pt = weights_dir / "best.pt"
    
    if best_pt.exists():
        return best_pt
    
    # Look for any .pt file
    for pt_file in weights_dir.glob("*.pt"):
        return pt_file
    
    # Check alternative locations
    alt_paths = [
        project_root / "models" / "weights" / "best.pt",
        project_root / "runs" / "detect" / "train" / "weights" / "best.pt",
    ]
    
    for path in alt_paths:
        if path.exists():
            return path
    
    return None


def test_on_image(model, image_path: Path, visualize: bool = False, save_dir: Path = None):
    """Run detection on a single image."""
    results = model(str(image_path), verbose=False)
    
    for r in results:
        boxes = r.boxes
        print(f"\n📷 {image_path.name}")
        print(f"   Detected: {len(boxes)} objects")
        
        if len(boxes) > 0:
            for box in boxes:
                cls = int(box.cls[0])
                conf = float(box.conf[0])
                name = model.names[cls]
                print(f"   • {name}: {conf:.2%}")
        
        if visualize or save_dir:
            import cv2
            img = r.plot()
            
            if save_dir:
                save_dir.mkdir(parents=True, exist_ok=True)
                save_path = save_dir / f"result_{image_path.name}"
                cv2.imwrite(str(save_path), img)
                print(f"   Saved: {save_path}")
            
            if visualize:
                cv2.imshow("Detection Result", img)
                cv2.waitKey(0)
                cv2.destroyAllWindows()
    
    return results


def test_on_folder(model, folder: Path, limit: int = 10, save_dir: Path = None):
    """Run detection on all images in a folder."""
    image_files = list(folder.glob("*.jpg")) + list(folder.glob("*.png"))
    image_files = image_files[:limit]
    
    print(f"\n🔍 Testing on {len(image_files)} images from {folder}")
    print("=" * 50)
    
    total_detections = 0
    class_counts = {}
    
    for img_path in image_files:
        results = test_on_image(model, img_path, save_dir=save_dir)
        
        for r in results:
            for box in r.boxes:
                total_detections += 1
                cls_name = model.names[int(box.cls[0])]
                class_counts[cls_name] = class_counts.get(cls_name, 0) + 1
    
    print("\n" + "=" * 50)
    print("📊 Summary:")
    print(f"   Total images: {len(image_files)}")
    print(f"   Total detections: {total_detections}")
    print(f"   Average per image: {total_detections / len(image_files):.1f}")
    print("\n   By class:")
    for cls, count in sorted(class_counts.items(), key=lambda x: -x[1]):
        print(f"   • {cls}: {count}")


def evaluate_model(model, data_yaml: str):
    """Evaluate model on validation set."""
    print("\n📈 Evaluating on validation set...")
    print("=" * 50)
    
    results = model.val(data=data_yaml, verbose=True)
    
    print("\n📊 Metrics:")
    print(f"   mAP@50:    {results.box.map50:.4f}")
    print(f"   mAP@50-95: {results.box.map:.4f}")
    print(f"   Precision: {results.box.mp:.4f}")
    print(f"   Recall:    {results.box.mr:.4f}")
    
    return results


def main():
    parser = argparse.ArgumentParser(description="Test trained YOLO model")
    parser.add_argument("--model", type=str, help="Path to model weights (.pt)")
    parser.add_argument("--image", type=str, help="Test single image")
    parser.add_argument("--folder", type=str, help="Test folder of images")
    parser.add_argument("--evaluate", action="store_true", help="Run full evaluation")
    parser.add_argument("--visualize", action="store_true", help="Show detection results")
    parser.add_argument("--save", type=str, help="Save results to folder")
    parser.add_argument("--limit", type=int, default=10, help="Max images to test")
    
    args = parser.parse_args()
    
    # Find model
    if args.model:
        model_path = Path(args.model)
    else:
        model_path = find_best_model()
    
    if model_path is None or not model_path.exists():
        print("❌ No trained model found!")
        print("   Please train a model first:")
        print("   python scripts/train_rtx3070.py")
        sys.exit(1)
    
    print(f"✅ Loading model: {model_path}")
    
    # Load model
    from ultralytics import YOLO
    model = YOLO(str(model_path))
    
    print(f"   Classes: {list(model.names.values())}")
    
    # Save directory
    save_dir = Path(args.save) if args.save else None
    
    # Run tests
    if args.image:
        test_on_image(model, Path(args.image), visualize=args.visualize, save_dir=save_dir)
    
    elif args.folder:
        test_on_folder(model, Path(args.folder), limit=args.limit, save_dir=save_dir)
    
    elif args.evaluate:
        evaluate_model(model, "models/configs/dataset.yaml")
    
    else:
        # Default: test on test set
        test_folder = project_root / "data" / "splits" / "test" / "images"
        if test_folder.exists():
            test_on_folder(model, test_folder, limit=args.limit, save_dir=save_dir)
            
            if args.evaluate:
                evaluate_model(model, "models/configs/dataset.yaml")
        else:
            print(f"❌ Test folder not found: {test_folder}")


if __name__ == "__main__":
    main()
