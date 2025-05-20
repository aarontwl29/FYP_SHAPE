# local_service.py
"""
Very small Flask API
GET /movies  →  returns a JSON list with every Movie in the DB
"""

from flask import Flask, jsonify
from data_loader import load_database

# ------------------------------------------------------------------ #
app = Flask(__name__)

# Load everything once when the server starts
MOVIES = load_database("./Jsons")      # {normalized_title: Movie}


def movie_to_dict(movie):
    """Convert Movie object → plain dict for JSON response."""
    return {
        "title":        movie.title,
        "year":         movie.year,
        "genres":       movie.genres,
        "description":  movie.description,
        "director":     movie.director,
        "stars":        movie.stars,
        "length":       movie.length,
        "ratings":      movie.ratings,
        "hashtags":     movie.hashtags,
        "poster_path":  movie.poster_path,
    }


# ------------------------------------------------------------------ #
@app.route("/movies", methods=["GET"])
def get_movies():
    """Return the entire catalogue."""
    return jsonify([movie_to_dict(m) for m in MOVIES.values()])


# ------------------------------------------------------------------ #
if __name__ == "__main__":
    # Start development server on http://127.0.0.1:5000
    app.run(debug=True, port=5000)
