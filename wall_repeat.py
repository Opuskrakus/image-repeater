#!/usr/bin/env python3
"""
wall_repeat.py - tile an image in X to fill a target canvas size.

Usage:
    python wall_repeat.py IMAGE WIDTH_CM HEIGHT_CM [--dpi DPI]

The image is scaled so its height matches HEIGHT_CM, maintaining the original
aspect ratio. It is then tiled horizontally until it covers WIDTH_CM, and the
result is cropped to exactly WIDTH_CM x HEIGHT_CM.

Output is saved next to the source file as:
    <name>_<WIDTH>x<HEIGHT>cm.<ext>
"""

import argparse
import math
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is not installed. Run:  pip install Pillow")

# Disable the decompression bomb limit - large wall prints routinely exceed it.
Image.MAX_IMAGE_PIXELS = None

# 1 inch = 2.54 cm
CM_PER_INCH = 2.54


def cm_to_px(cm: float, dpi: float) -> int:
    return round(cm * dpi / CM_PER_INCH)


def process(image_path: Path, width_cm: float, height_cm: float, dpi: float = 100.0) -> Path:
    target_w_px = cm_to_px(width_cm, dpi)
    target_h_px = cm_to_px(height_cm, dpi)

    src = Image.open(image_path)
    orig_w, orig_h = src.size

    # Scale image so its height matches target height (aspect-ratio preserved)
    scale = target_h_px / orig_h
    tile_w = round(orig_w * scale)
    tile_h = target_h_px

    tile = src.resize((tile_w, tile_h), Image.LANCZOS)

    # How many tiles are needed to cover the target width?
    num_tiles = math.ceil(target_w_px / tile_w)

    canvas = Image.new(src.mode, (tile_w * num_tiles, tile_h))
    for i in range(num_tiles):
        canvas.paste(tile, (i * tile_w, 0))

    # Crop to exact target width
    result = canvas.crop((0, 0, target_w_px, tile_h))

    # Set DPI metadata in the saved file
    out_name = f"{image_path.stem}_{width_cm:g}x{height_cm:g}cm{image_path.suffix}"
    out_path = image_path.parent / out_name

    save_kwargs = {}
    if image_path.suffix.lower() in (".jpg", ".jpeg"):
        save_kwargs["quality"] = 95
        save_kwargs["subsampling"] = 0
    # Store DPI in image metadata so Photoshop/print tools read it correctly
    save_kwargs["dpi"] = (dpi, dpi)

    result.save(out_path, **save_kwargs)

    print(f"Saved -> {out_path}")
    print(f"  Canvas : {target_w_px} x {target_h_px} px  ({width_cm} x {height_cm} cm @ {dpi} PPI)")
    print(f"  Tiles  : {num_tiles}  (tile width after scaling: {tile_w} px)")

    return out_path


def main():
    parser = argparse.ArgumentParser(description="Tile a wall image to a target canvas size.")
    parser.add_argument("image",      type=Path,  help="Path to the source image")
    parser.add_argument("width_cm",   type=float, help="Target canvas width in cm")
    parser.add_argument("height_cm",  type=float, help="Target canvas height in cm")
    parser.add_argument("--dpi",      type=float, default=100.0,
                        help="Resolution in pixels per inch (default: 100)")
    args = parser.parse_args()

    if not args.image.is_file():
        sys.exit(f"File not found: {args.image}")
    if args.width_cm <= 0 or args.height_cm <= 0:
        sys.exit("Width and height must be positive values.")
    if args.dpi <= 0:
        sys.exit("DPI must be a positive value.")

    process(args.image, args.width_cm, args.height_cm, args.dpi)


if __name__ == "__main__":
    main()
