#!/usr/bin/env python3
"""Derive transparent runtime crops from the supplied Dragon Tales sheets.

The uploaded art is presentation-sheet artwork: it includes labels, grid lines,
and a light paper background. This script preserves the source sheets and
creates runtime crops by using the colored art as the foreground mask.
"""
from __future__ import annotations

import json
import math
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "dragon_tales" / "source" / "dragon_game_assets_v2"
RUNTIME = ROOT / "assets" / "dragon_tales" / "runtime"

DRAGONS = [
    ("blaze", "fire"), ("tide", "water"), ("pebble", "earth"),
    ("breeze", "air"), ("spark", "lightning"), ("fern", "plant"),
    ("frost", "ice"), ("gleam", "light"), ("rivet", "metal"),
    ("twinkle", "star"),
]


def foreground_mask(image: Image.Image) -> Image.Image:
    """Keep saturated illustrated pixels and nearby dark outlines, not labels/grid."""
    rgb = np.asarray(image.convert("RGB"), dtype=np.float32) / 255.0
    mx = rgb.max(axis=2)
    mn = rgb.min(axis=2)
    saturation = np.divide(mx - mn, np.maximum(mx, 1e-6))
    # Colored illustration pixels are saturated. Dark outlines next to them are
    # restored after a small dilation so sprites retain their inked edges.
    # The paper background has a small warm JPEG tint (roughly 0.05–0.09
    # saturation). Illustrated pixels are materially more saturated.
    colored = (saturation > 0.13) & (mx < 0.995)
    color_img = Image.fromarray((colored.astype(np.uint8) * 255), mode="L")
    expanded = color_img.filter(ImageFilter.MaxFilter(3))
    expanded_np = np.asarray(expanded) > 0
    dark = (mx < 0.58) & (mn < 0.48)
    mask = colored | (expanded_np & dark)
    return _keep_major_components(mask)


def _keep_major_components(mask: np.ndarray) -> Image.Image:
    """Keep illustration-sized connected components and discard text fragments."""
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    components: list[list[tuple[int, int]]] = []
    for y, x in np.argwhere(mask):
        if visited[y, x]:
            continue
        queue = deque([(int(y), int(x))])
        visited[y, x] = True
        component: list[tuple[int, int]] = []
        while queue:
            cy, cx = queue.popleft()
            component.append((cy, cx))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if dy == 0 and dx == 0:
                        continue
                    ny, nx = cy + dy, cx + dx
                    if 0 <= ny < height and 0 <= nx < width and mask[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        queue.append((ny, nx))
        components.append(component)
    if not components:
        return Image.new("L", (width, height), 0)
    largest = max(len(component) for component in components)
    keep_threshold = max(40, int(largest * 0.045))
    result = np.zeros_like(mask, dtype=np.uint8)
    for component in components:
        ys, xs = zip(*component)
        bbox_width = max(xs) - min(xs) + 1
        bbox_height = max(ys) - min(ys) + 1
        is_thin_rule = (bbox_width >= bbox_height * 4 and bbox_height <= 18) or (bbox_height >= bbox_width * 4 and bbox_width <= 18)
        if len(component) >= keep_threshold and not is_thin_rule:
            result[list(ys), list(xs)] = 255
    return Image.fromarray(result, mode="L").filter(ImageFilter.GaussianBlur(0.35))


def crop_runtime(image: Image.Image, box: tuple[int, int, int, int], padding: int = 10) -> Image.Image:
    crop = image.crop(box).convert("RGB")
    mask = foreground_mask(crop)
    bbox = mask.getbbox()
    if bbox is None:
        bbox = (0, 0, crop.width, crop.height)
    left = max(0, bbox[0] - padding)
    top = max(0, bbox[1] - padding)
    right = min(crop.width, bbox[2] + padding)
    bottom = min(crop.height, bbox[3] + padding)
    crop = crop.crop((left, top, right, bottom))
    mask = mask.crop((left, top, right, bottom))
    crop.putalpha(mask)
    return crop


def save_crop(image: Image.Image, path: Path, box: tuple[int, int, int, int], padding: int = 10) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    crop_runtime(image, box, padding).save(path, "PNG", optimize=True)


def grid_box(width: int, height: int, cols: int, rows: int, col: int, row: int) -> tuple[int, int, int, int]:
    return (
        round(width * col / cols), round(height * row / rows),
        round(width * (col + 1) / cols), round(height * (row + 1) / rows),
    )


def process_dragons() -> dict:
    manifest = {"dragons": {}, "world": {"island": [], "habitats": {}, "eggs": {}, "buildings": {}}}
    for dragon_id, element in DRAGONS:
        source_path = SOURCE / "dragons" / f"{dragon_id}_sheet.png"
        image = Image.open(source_path).convert("RGB")
        frames = []
        for row, animation in enumerate(("idle", "walk", "fly", "action")):
            for col in range(6):
                out = RUNTIME / "dragons" / dragon_id / f"{animation}_{col:02d}.png"
                save_crop(image, out, grid_box(image.width, image.height, 6, 4, col, row), 8)
                frames.append(str(out.relative_to(ROOT)))
        manifest["dragons"][dragon_id] = {"element": element, "animations": {name: [str((RUNTIME / "dragons" / dragon_id / f"{name}_{i:02d}.png").relative_to(ROOT)) for i in range(6)] for name in ("idle", "walk", "fly", "action")}}
    return manifest


def process_world(manifest: dict) -> None:
    island_source = Image.open(SOURCE / "world" / "starter_island_sheet.png").convert("RGB")
    for row in range(2):
        for col in range(3):
            out = RUNTIME / "island" / f"frame_{row * 3 + col:02d}.png"
            save_crop(island_source, out, grid_box(island_source.width, island_source.height, 3, 2, col, row), 10)
            manifest["world"]["island"].append(str(out.relative_to(ROOT)))

    habitat_sources = [
        ("habitats_sheet_1.png", ("lightning", "light", "metal", "star"), 2, 2),
        ("habitats_sheet_2.png", ("fire", "water", "earth", "air", "plant", "ice"), 3, 2),
    ]
    for filename, names, cols, rows in habitat_sources:
        image = Image.open(SOURCE / "world" / filename).convert("RGB")
        for idx, name in enumerate(names):
            col, row = idx % cols, idx // cols
            out = RUNTIME / "habitats" / f"{name}.png"
            save_crop(image, out, grid_box(image.width, image.height, cols, rows, col, row), 12)
            manifest["world"]["habitats"][name] = str(out.relative_to(ROOT))

    egg_source = Image.open(SOURCE / "world" / "buildings_and_eggs_sheet.png").convert("RGB")
    elements = [name for _, name in DRAGONS]
    for idx, element in enumerate(elements):
        out = RUNTIME / "eggs" / f"{element}.png"
        save_crop(egg_source, out, grid_box(egg_source.width, egg_source.height, 5, 2, idx % 5, idx // 5), 10)
        manifest["world"]["eggs"][element] = str(out.relative_to(ROOT))

    # Building art occupies the lower third of the combined sheet; use broad
    # explicit regions so the lower labels are removed by the foreground mask.
    building_boxes = {
        "hatchery": (0, 520, 400, 896),
        "food_farm": (400, 520, 800, 896),
        "breeding_corral": (800, 520, 1200, 896),
    }
    for name, box in building_boxes.items():
        out = RUNTIME / "buildings" / f"{name}.png"
        save_crop(egg_source, out, box, 12)
        manifest["world"]["buildings"][name] = str(out.relative_to(ROOT))


def main() -> None:
    RUNTIME.mkdir(parents=True, exist_ok=True)
    manifest = process_dragons()
    process_world(manifest)
    (RUNTIME / "runtime_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Generated runtime crops in {RUNTIME}")


if __name__ == "__main__":
    main()
