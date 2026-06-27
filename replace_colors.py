import re
import sys

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replacements that need 'context'
    replacements = {
        r"AppColors\.playfulPrimary\.withOpacity\((.*?)\)": r"Theme.of(context).colorScheme.primary.withValues(alpha: \1)",
        r"AppColors\.playfulPrimary": r"Theme.of(context).colorScheme.primary",
        r"AppColors\.playfulSecondary\.withOpacity\((.*?)\)": r"Theme.of(context).colorScheme.secondary.withValues(alpha: \1)",
        r"AppColors\.playfulSecondary": r"Theme.of(context).colorScheme.secondary",
        r"AppColors\.playfulTertiary\.withOpacity\((.*?)\)": r"Theme.of(context).colorScheme.tertiary.withValues(alpha: \1)",
        r"AppColors\.playfulTertiary": r"Theme.of(context).colorScheme.tertiary",
        r"AppColors\.playfulBackground": r"Theme.of(context).scaffoldBackgroundColor",
        r"AppColors\.playfulSurface": r"Theme.of(context).cardColor",
        r"AppColors\.playfulTextLight\.withOpacity\((.*?)\)": r"Theme.of(context).colorScheme.onSurface.withValues(alpha: \1)",
        r"AppColors\.playfulTextLight": r"Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)",
        r"AppColors\.playfulText\.withOpacity\((.*?)\)": r"Theme.of(context).colorScheme.onSurface.withValues(alpha: \1)",
        r"AppColors\.playfulText": r"Theme.of(context).colorScheme.onSurface",
        r"AppColors\.playfulAccentPeach\.withOpacity\((.*?)\)": r"Theme.of(context).colorScheme.primaryContainer.withValues(alpha: \1)",
        r"AppColors\.playfulAccentPeach": r"Theme.of(context).colorScheme.primaryContainer",
        r"AppColors\.playfulAccentBlue\.withOpacity\((.*?)\)": r"Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: \1)",
        r"AppColors\.playfulAccentBlue": r"Theme.of(context).colorScheme.secondaryContainer",
        r"PastelCard\(\s*backgroundColor:\s*Colors\.white,": r"PastelCard(",
    }

    new_content = content
    for pattern, replacement in replacements.items():
        new_content = re.sub(pattern, replacement, new_content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

if __name__ == "__main__":
    replace_in_file(sys.argv[1])
