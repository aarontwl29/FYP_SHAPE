def filter_by_genre(genre, movie_db):
    genre_lower = genre.lower()
    return [
        movie for movie in movie_db.values()
        if any(g.lower() == genre_lower for g in movie.genres)
    ]

# def filter_by_min_rating(min_rating, movie_db, source='imdb'):
#     return [
#         movie for movie in movie_db.values()
#         if movie.ratings.get(source, {}).get("score", 0) >= min_rating
#     ]





def filter_by_director(director_name, movie_db):
    """Returns a list of movies directed by the given person (case-insensitive)."""
    director_lower = director_name.lower()
    return [
        movie for movie in movie_db.values()
        if (
            isinstance(movie.director, str) and director_lower in movie.director.lower()
        ) or (
            isinstance(movie.director, list) and any(director_lower in d.lower() for d in movie.director)
        )
    ]
