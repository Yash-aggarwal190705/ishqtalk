# Reference images

`tool/crop_references.py` extracts unscaled, lossless PNG regions from the
supplied montages. Bounds are `(left, top, right, bottom)` in original pixels.

| Output | Original montage | Bounds | Size |
|---|---|---|---|
| welcome_with_notif_crop.png | ChatGPT Image Nov 2, 2026, 09_38_31 PM.png | (1170, 24, 1465, 638) | 295 × 614 |
| notif_prompt_crop.png | ChatGPT Image Nov 2, 2026, 09_38_31 PM.png | (1703, 24, 1999, 638) | 296 × 614 |
| payment_sheet_crop.png | ChatGPT Image Nov 2, 2026, 09_40_54 PM.png | (101, 26, 393, 619) | 292 × 593 |

`montage-1.png` and `montage-2.png` are reduced overview images for inspection;
the three crops above were made directly from the full originals.

These are qualitative references, not golden baselines. They include rounded
phone corners, different aspect ratios, and colors/copy that differ from the
provided source (for example the payment montage's gift count).
Both "Welcome Offer" and "Notification Prompt" regions include the prompt.
There is no reliably identifiable standalone base-offer or tooltip reference.

The Flutter goldens in `../test/goldens/` use 390 × 844 logical pixels, DPR 1,
zero safe-area insets and text scale 1. Production reads real insets.
See `../docs/port_self_review.md` for source/spec comparison and limitations.
