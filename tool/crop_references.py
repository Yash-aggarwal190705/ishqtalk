"""Lossless reference-region extraction; never resize the montage source."""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
source = root.parent / "app_screens" / "actuall_screens_folder"
target = root / "reference_images"
target.mkdir(exist_ok=True)

# Bounds are visually identified inner phone regions in the supplied montages.
# They are not 390x844 viewport measurements and retain rounded screen corners.
crops = [
    ("ChatGPT Image Nov 2, 2026, 09_38_31 PM.png", (1170, 24, 1465, 638), "welcome_with_notif_crop.png"),
    ("ChatGPT Image Nov 2, 2026, 09_38_31 PM.png", (1703, 24, 1999, 638), "notif_prompt_crop.png"),
    ("ChatGPT Image Nov 2, 2026, 09_40_54 PM.png", (101, 26, 393, 619), "payment_sheet_crop.png"),
]
for filename, bounds, output in crops:
    with Image.open(source / filename) as image:
        crop = image.crop(bounds)
        crop.save(target / output)
        print(f"{output}: source crop {bounds}, {crop.width}x{crop.height}, no resampling")
