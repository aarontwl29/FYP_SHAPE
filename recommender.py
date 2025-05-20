# recommender.py

from data_loader import load_database
from movie import Movie
from similarity import find_top_related_movies
from utils import normalize_title
from user import User  
from collections import Counter
from typing import List

# ---------------------------------------------------------- #
def get_unified_rating(movie: Movie) -> float:
    imdb_score = movie.ratings.get("imdb", {}).get("score", 0)
    imdb_votes = movie.ratings.get("imdb", {}).get("votes", 0)

    tomato_score = movie.ratings.get("rt_tomatometer", {}).get("score", 0) / 10.0
    tomato_reviews = movie.ratings.get("rt_tomatometer", {}).get("reviews", 0)

    popcorn_score = movie.ratings.get("rt_popcorn", {}).get("score", 0) / 10.0
    popcorn_votes = movie.ratings.get("rt_popcorn", {}).get("votes", 0)

    total_votes = imdb_votes + tomato_reviews + popcorn_votes
    if total_votes == 0:
        return 0.0

    total_score = (imdb_score * imdb_votes +
                   tomato_score * tomato_reviews +
                   popcorn_score * popcorn_votes)

    return round(total_score / total_votes, 1)

# ---------------------------------------------------------- #
def recommend_next_movies(user: User, movies: dict, top_k: int = 5) -> List[dict]:
    clicked = set(user.recent_clicked_titles)
    rated = set(user.rated_movies.keys())
    saved = set(user.saved_titles)
    all_history = clicked | rated | saved

    if not user.recent_clicked_titles and not user.rated_movies:
        # Cold start: Top-rated
        scored = [(key, get_unified_rating(m)) for key, m in movies.items()]
        top = sorted(scored, key=lambda x: x[1], reverse=True)
        top = [movies[k].__dict__ for k, _ in top if movies[k].title not in all_history][:top_k]
        return top

    # --- Build user preference profile ---
    genre_counter = Counter()
    keyword_counter = Counter()
    director_counter = Counter()
    star_counter = Counter()

    for title in all_history:
        norm = normalize_title(title)
        movie = movies.get(norm)
        if not movie:
            continue
        genre_counter.update(movie.genres)
        keyword_counter.update(movie.hashtags.get("top_keywords", []))
        director_counter.update([movie.director])
        star_counter.update(movie.stars)

    scored_movies = []
    for key, movie in movies.items():
        if movie.title in all_history:
            continue

        genre_score = sum(genre_counter[g] for g in movie.genres)
        keyword_score = sum(keyword_counter[k] for k in movie.hashtags.get("top_keywords", []))
        director_score = director_counter[movie.director]
        star_score = sum(star_counter[s] for s in movie.stars)

        profile_score = (
            2.0 * genre_score +
            1.5 * keyword_score +
            1.0 * director_score +
            0.5 * star_score
        )

        unified = get_unified_rating(movie)
        final_score = profile_score + 0.3 * unified

        scored_movies.append((key, final_score))

    top = sorted(scored_movies, key=lambda x: x[1], reverse=True)[:top_k]
    return [movies[k].__dict__ for k, _ in top]

# ---------------------------------------------------------- #
if __name__ == "__main__":
    movies = load_database()

    # ✅ Create user from dict
    user_data = {
        "user_id": "user42",
        "recent_clicked_titles": ["A Complete Unknown"],
        "rated_movies": {"Dune": 9},
        "saved_titles": ["Oppenheimer"],
        "preferred_genres": [],
        "preferred_keywords": [],
        "last_active": None,
        "similar_users": []
    }

    user = User.from_dict(user_data)

    print("🔹 Recommendations based on user profile:")
    for m in recommend_next_movies(user, movies):
        print(" -", m["title"])
