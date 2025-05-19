from flask import Flask, request, jsonify
from data_loader import load_movies, load_hashtag_data, merge_movie_and_hashtag
from search import filter_by_genre, filter_by_director
from utils import normalize_title

app = Flask(__name__)

# Load data once at startup
movies = merge_movie_and_hashtag(
    load_movies('./Jsons/Movies.json'),
    load_hashtag_data('./Hashtag_Reviews')
)

@app.route("/search/genre", methods=["GET"])
def search_by_genre():
    genre = request.args.get("genre")
    if not genre:
        return jsonify({"error": "Missing genre"}), 400

    results = filter_by_genre(genre, movies)
    return jsonify([{"title": m.title, "year": m.year} for m in results])

@app.route("/search/director", methods=["GET"])
def search_by_director():
    director = request.args.get("director")
    if not director:
        return jsonify({"error": "Missing director"}), 400

    results = filter_by_director(director, movies)
    return jsonify([{"title": m.title, "year": m.year} for m in results])

if __name__ == "__main__":
    app.run(debug=True, port=5000)
