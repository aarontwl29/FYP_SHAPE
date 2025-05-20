# data_loader.py
"""
Build fully populated Movie objects from the Jsons/ directory.

Expected layout
└─ Jsons/
   ├─ Movies.json
   ├─ posters.json
   └─ Hashtag_Reviews/
        ├─ <movie-1>.json
        ├─ <movie-2>.json
        └─ ...
"""

import json
import os
from typing import Dict

from movie import Movie
from utils import normalize_title

# --------------------------------------------------------------------------- #
def _load_poster_map(poster_path: str) -> Dict[str, str]:
    """Return {normalized_title: poster_file} from posters.json."""
    with open(poster_path, "r", encoding="utf-8") as f:
        posters = json.load(f)
    return {normalize_title(rec["name"]): rec["poster_file"] for rec in posters}


# --------------------------------------------------------------------------- #
def load_movies(movies_json: str, posters_json: str) -> Dict[str, Movie]:
    """Create Movie objects and attach poster paths (if any)."""
    with open(movies_json, "r", encoding="utf-8") as f:
        raw_movies = json.load(f)

    poster_map = _load_poster_map(posters_json)

    movies: Dict[str, Movie] = {}
    for item in raw_movies:
        title_clean = item["title"].replace("*", "").strip()
        key = normalize_title(title_clean)

        movies[key] = Movie(
            title=title_clean,
            year=item["year"],
            genres=item["genre"],
            description=item["description"],
            director=item["director"],
            stars=item["stars"],
            length=item["length_minutes"],
            ratings={
                "imdb":           item.get("rating_imdb", {}),
                "rt_tomatometer": item.get("rating_rt_tomatometer", {}),
                "rt_popcorn":     item.get("rating_rt_popcorn", {}),
            },
            poster_path=poster_map.get(key),
        )
    return movies


# --------------------------------------------------------------------------- #
def load_hashtag_data(hashtag_dir: str) -> Dict[str, dict]:
    """
    Read every *.json in Jsons/Hashtag_Reviews/ and return
    {normalized_title: {...}}.
    """
    hashtag_data: Dict[str, dict] = {}
    for fname in os.listdir(hashtag_dir):
        if fname.endswith(".json"):
            with open(os.path.join(hashtag_dir, fname), "r", encoding="utf-8") as f:
                data = json.load(f)
            key = normalize_title(data["movie_name"])
            hashtag_data[key] = {
                "top_emotions": data.get("top_emotions", []),
                "top_keywords": data.get("top_keywords", []),
            }
    return hashtag_data


# --------------------------------------------------------------------------- #
def merge_movie_and_hashtag(movies: Dict[str, Movie],
                            hashtags: Dict[str, dict]) -> Dict[str, Movie]:
    """Attach hashtag info to any Movie that has it."""
    for key, tag_info in hashtags.items():
        if key in movies:
            movies[key].hashtags = tag_info
    return movies


# --------------------------------------------------------------------------- #
def load_database(json_root: str = "./Jsons") -> Dict[str, Movie]:
    """
    Convenience wrapper:
    • Movies.json
    • posters.json
    • Hashtag_Reviews/
    """
    movies_path  = os.path.join(json_root, "Movies.json")
    posters_path = os.path.join(json_root, "posters.json")
    hashtag_dir  = os.path.join(json_root, "Hashtag_Reviews")

    movies   = load_movies(movies_path, posters_path)
    hashtags = load_hashtag_data(hashtag_dir)
    return merge_movie_and_hashtag(movies, hashtags)
