import os
import re

TARGET_DIR = r"d:\trippy-full\trippy_customer\lib\utils\choose_car_bottom_sheet"

REPLACEMENTS = [
    (re.compile(r"AppColors\.\w+Background(?!\w)"), r"Theme.of(context).colorScheme.surface"),
    (re.compile(r"AppColors\.\w+Text(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\.\w+Icon(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\.\w+Container(?!\w)"), r"Theme.of(context).colorScheme.surfaceContainer"),
    (re.compile(r"AppColors\.\w+Border(?!\w)"), r"Theme.of(context).colorScheme.outline"),
    (re.compile(r"AppColors\.\w+Side(?!\w)"), r"Theme.of(context).colorScheme.outline"),
    (re.compile(r"AppColors\.\w+Foreground(?!\w)"), r"Theme.of(context).colorScheme.onPrimary"),
    (re.compile(r"AppColors\.\w+Title(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\.\w+Description(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\.\w+HintText(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\.\w+Details(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\.\w+Divider(?!\w)"), r"Theme.of(context).colorScheme.outlineVariant"),
    (re.compile(r"AppColors\.\w+Label(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\.dashboardStarPointsWidget(?!\w)"), r"Theme.of(context).colorScheme.surfaceContainer"),
    (re.compile(r"AppColors\.dashboardBottomSheetChooseCarNameColor(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\.dashboardBottomSheetChooseCarSeatsLogo(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\.dashboardBottomSheetChooseCarSeatsInfo(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
]

def migrate_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content
    for pattern, replacement in REPLACEMENTS:
        new_content = pattern.sub(replacement, new_content)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

def main():
    for root, dirs, files in os.walk(TARGET_DIR):
        for file in files:
            if file.endswith(".dart"):
                migrate_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
