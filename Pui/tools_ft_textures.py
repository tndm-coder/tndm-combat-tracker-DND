from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

try:
    import numpy as np
    from PIL import Image
except Exception as exc:  # pragma: no cover - import failure is handled in CLI
    raise SystemExit(
        "Dependencies are required. Install with: pip install pillow numpy\n"
        f"Import error: {exc}"
    )


@dataclass
class FitParams:
    scale: float
    offset_x: int
    offset_y: int
    score: float


def clamp(val: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, val))


def load_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def compose_on_canvas(src: Image.Image, canvas_size: tuple[int, int], scale: float, dx: int, dy: int) -> Image.Image:
    src_w, src_h = src.size
    new_w = max(1, int(round(src_w * scale)))
    new_h = max(1, int(round(src_h * scale)))
    resized = src.resize((new_w, new_h), resample=Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    cx = (canvas_size[0] - new_w) // 2 + dx
    cy = (canvas_size[1] - new_h) // 2 + dy
    canvas.alpha_composite(resized, (cx, cy))
    return canvas


def score_fit(reference: Image.Image, candidate: Image.Image, alpha_threshold: int, color_tolerance: int) -> float:
    ref = np.asarray(reference, dtype=np.uint8)
    cand = np.asarray(candidate, dtype=np.uint8)

    ref_alpha = ref[:, :, 3] >= alpha_threshold
    cand_alpha = cand[:, :, 3] >= alpha_threshold

    union_mask = ref_alpha | cand_alpha
    intersect_mask = ref_alpha & cand_alpha

    union = int(np.count_nonzero(union_mask))
    if union == 0:
        return 0.0

    intersect = int(np.count_nonzero(intersect_mask))
    iou = intersect / union

    if intersect == 0:
        color_ratio = 0.0
    else:
        rgb_diff = np.abs(ref[:, :, :3].astype(np.int16) - cand[:, :, :3].astype(np.int16))
        within_tol = np.all(rgb_diff <= color_tolerance, axis=2)
        color_matches = int(np.count_nonzero(within_tol & intersect_mask))
        color_ratio = color_matches / intersect

    return 0.75 * iou + 0.25 * color_ratio


def frange(start: float, stop: float, step: float) -> Iterable[float]:
    steps = int(math.floor((stop - start) / step))
    for idx in range(steps + 1):
        yield start + idx * step


def fit_texture(
    reference: Image.Image,
    src: Image.Image,
    scale_min: float,
    scale_max: float,
    scale_step: float,
    offset_px: int,
    offset_step: int,
    alpha_threshold: int,
    color_tolerance: int,
) -> FitParams:
    best = FitParams(scale=1.0, offset_x=0, offset_y=0, score=-1.0)

    for scale in frange(scale_min, scale_max, scale_step):
        for dx in range(-offset_px, offset_px + 1, offset_step):
            for dy in range(-offset_px, offset_px + 1, offset_step):
                candidate = compose_on_canvas(src, reference.size, scale, dx, dy)
                sc = score_fit(reference, candidate, alpha_threshold, color_tolerance)
                if sc > best.score:
                    best = FitParams(scale=scale, offset_x=dx, offset_y=dy, score=sc)

    return best


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Fit textures to reference by maximizing pixel overlap")
    parser.add_argument("--reference", type=Path, required=True, help="Reference image path")
    parser.add_argument("--inputs", type=Path, nargs="+", required=True, help="Input textures to fit")
    parser.add_argument("--output-dir", type=Path, required=True, help="Directory for fitted outputs")

    parser.add_argument("--scale-min", type=float, default=0.70)
    parser.add_argument("--scale-max", type=float, default=1.60)
    parser.add_argument("--scale-step", type=float, default=0.01)

    parser.add_argument("--offset-px", type=int, default=40, help="Max absolute offset in pixels")
    parser.add_argument("--offset-step", type=int, default=2)

    parser.add_argument("--alpha-threshold", type=int, default=16, help="Alpha >= threshold treated as opaque")
    parser.add_argument("--color-tolerance", type=int, default=28, help="Per-channel RGB tolerance for color match")

    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)

    if not args.reference.exists():
        raise SystemExit(f"Reference image not found: {args.reference}")

    missing = [p for p in args.inputs if not p.exists()]
    if missing:
        missing_list = "\n".join(str(p) for p in missing)
        raise SystemExit(f"Input image(s) not found:\n{missing_list}")

    args.output_dir.mkdir(parents=True, exist_ok=True)

    ref = load_rgba(args.reference)

    print(f"Reference: {args.reference} ({ref.size[0]}x{ref.size[1]})")
    for inp in args.inputs:
        src = load_rgba(inp)
        best = fit_texture(
            reference=ref,
            src=src,
            scale_min=args.scale_min,
            scale_max=args.scale_max,
            scale_step=args.scale_step,
            offset_px=args.offset_px,
            offset_step=args.offset_step,
            alpha_threshold=int(clamp(args.alpha_threshold, 0, 255)),
            color_tolerance=max(0, args.color_tolerance),
        )

        out = compose_on_canvas(src, ref.size, best.scale, best.offset_x, best.offset_y)
        out_path = args.output_dir / inp.name
        out.save(out_path)

        print(
            f"- {inp.name}: score={best.score:.4f}, scale={best.scale:.3f}, "
            f"dx={best.offset_x}, dy={best.offset_y} -> {out_path}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
