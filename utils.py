import re

def normalize_title(title):
    """
    Normalize movie titles for filenames and comparison.
    E.g., "Spider-Man: Homecoming" → "spider_man_homecoming"
    """
    title = title.lower()
    title = re.sub(r'[^a-z0-9]', '_', title)
    title = re.sub(r'_+', '_', title)
    return title.strip('_')
