from typing import Dict, List, Tuple
from movie import Movie
from collections import Counter
import re

def jaccard_similarity(set1: set, set2: set) -> float:
    if not set1 or not set2:
        return 0.0
    return len(set1 & set2) / len(set1 | set2)

def is_possibly_same_series(title1: str, title2: str) -> bool:
    """
    Check if two titles likely belong to the same series.
    Looks for shared prefix + numeric or part-based suffix.
    """
    t1 = re.sub(r'[^a-zA-Z0-9 ]', '', title1.lower()).strip()
    t2 = re.sub(r'[^a-zA-Z0-9 ]', '', title2.lower()).strip()

    # Try to extract base name
    base1 = re.sub(r'(\d+|part\s*\d+|chapter\s*\d+)$', '', t1).strip()
    base2 = re.sub(r'(\d+|part\s*\d+|chapter\s*\d+)$', '', t2).strip()

    return base1 == base2 and base1 != ""

def compute_similarity(m1: Movie, m2: Movie) -> float:
    score = 0.0

    # Series boost
    if is_possibly_same_series(m1.title, m2.title):
        score += 2.0  # Strong bonus if likely same series

    # Genre overlap
    score += 1.5 * jaccard_similarity(set(m1.genres), set(m2.genres))

    # Keyword overlap
    score += 1.0 * jaccard_similarity(
        set(m1.hashtags.get("top_keywords", [])),
        set(m2.hashtags.get("top_keywords", []))
    )

    # Emotion overlap
    score += 0.5 * jaccard_similarity(
        set(m1.hashtags.get("top_emotions", [])),
        set(m2.hashtags.get("top_emotions", []))
    )

    # Same director
    if m1.director == m2.director:
        score += 1.0

    # Shared stars
    score += 0.2 * len(set(m1.stars) & set(m2.stars))

    # Year closeness
    year_diff = abs(m1.year - m2.year)
    if year_diff < 3:
        score += 0.5
    elif year_diff < 7:
        score += 0.2

    return score

def find_top_related_movies(target: Movie, movies: Dict[str, Movie], top_k=5) -> List[Tuple[str, float]]:
    similarities = []
    for key, other in movies.items():
        if other.title == target.title:
            continue
        sim = compute_similarity(target, other)
        similarities.append((key, sim))

    return sorted(similarities, key=lambda x: x[1], reverse=True)[:top_k]
