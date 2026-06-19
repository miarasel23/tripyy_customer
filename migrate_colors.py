import os
import re

TARGET_DIR = r"/Users/mdraselmia/Downloads/trippy-full/tripyy_customer/lib"

REPLACEMENTS = [
    (re.compile(r"AppColors\s*\.\s*\w+Background(?!\w)"), r"Theme.of(context).colorScheme.surface"),
    (re.compile(r"AppColors\s*\.\s*\w+Text(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\s*\.\s*\w+Icon(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\s*\.\s*\w+Container(?!\w)"), r"Theme.of(context).colorScheme.surfaceContainer"),
    (re.compile(r"AppColors\s*\.\s*\w+Border(?!\w)"), r"Theme.of(context).colorScheme.outline"),
    (re.compile(r"AppColors\s*\.\s*\w+Side(?!\w)"), r"Theme.of(context).colorScheme.outline"),
    (re.compile(r"AppColors\s*\.\s*\w+Foreground(?!\w)"), r"Theme.of(context).colorScheme.onPrimary"),
    (re.compile(r"AppColors\s*\.\s*\w+Title(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\s*\.\s*\w+Description(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\s*\.\s*\w+HintText(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\s*\.\s*\w+Details(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\s*\.\s*\w+Divider(?!\w)"), r"Theme.of(context).colorScheme.outlineVariant"),
    (re.compile(r"AppColors\s*\.\s*\w+Label(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\s*\.\s*dashboardStarPointsWidget(?!\w)"), r"Theme.of(context).colorScheme.surfaceContainer"),
    (re.compile(r"AppColors\s*\.\s*dashboardBottomSheetChooseCarNameColor(?!\w)"), r"Theme.of(context).colorScheme.onSurface"),
    (re.compile(r"AppColors\s*\.\s*dashboardBottomSheetChooseCarSeatsLogo(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\s*\.\s*dashboardBottomSheetChooseCarSeatsInfo(?!\w)"), r"Theme.of(context).colorScheme.onSurfaceVariant"),
    (re.compile(r"AppColors\s*\.\s*\w+Textfield(?!\w)"), r"Theme.of(context).colorScheme.surfaceContainerHighest"),
]

def migrate_file(filepath):
    if "colors_code.dart" in filepath or "app_theme.dart" in filepath:
        return
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
