import json
import os
from movie import Movie

def load_movies(json_path):
    with open(json_path, 'r') as f:
        movie_data = json.load(f)

    movies = {}
    for item in movie_data:
        title_clean = item["title"].replace("*", "").strip()
        movie = Movie(
            title=title_clean,
            year=item["year"],
            genres=item["genre"],
            description=item["description"],
            director=item["director"],
            stars=item["stars"],
            length=item["length_minutes"],
            ratings={
                "imdb": item.get("rating_imdb", {}),
                "rt_tomatometer": item.get("rating_rt_tomatometer", {}),
                "rt_popcorn": item.get("rating_rt_popcorn", {})
            }
        )
        movies[title_clean.lower()] = movie
    return movies


def load_hashtag_data(folder_path):
    hashtag_data = {}
    for filename in os.listdir(folder_path):
        if filename.endswith(".json"):
            path = os.path.join(folder_path, filename)
            with open(path, 'r') as f:
                data = json.load(f)
                title = data["movie_name"].strip().lower()
                hashtag_data[title] = {
                    "top_emotions": data.get("top_emotions", []),
                    "top_keywords": data.get("top_keywords", [])
                }
    return hashtag_data


def merge_movie_and_hashtag(movies, hashtags):
    for title, tags in hashtags.items():
        if title in movies:
            movies[title].hashtags = tags
    return movies
