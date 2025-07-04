# local_service.py
"""
Very small Flask API
GET /movies  →  returns a JSON list with every Movie in the DB
"""

from flask import Flask, jsonify, request
from data_loader import load_database
from similarity import find_top_related_movies
from utils import normalize_title
from recommender import recommend_next_movies
from user import User
import os
import json


# ------------------------------------------------------------------ #
app = Flask(__name__)

# Load everything once when the server starts
MOVIES = load_database("./Jsons")      # {normalized_title: Movie}
REVIEWS_FOLDER = "./Reviews"

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


@app.route("/all_users", methods=["GET"])
def all_users():
    try:
        file_path = "Jsons/Users.json"
        with open(file_path, "r", encoding="utf-8") as f:
            raw_users = json.load(f)
        print(f"✅ Loaded {len(raw_users)} users from {file_path}")
        return jsonify(raw_users)
    except Exception as e:
        print(f"❌ Failed to load users: {e}")
        return jsonify({"error": str(e)}), 500




@app.route("/reviews", methods=["GET"])
def get_reviews():
    """
    Expects: full poster path via query param ?poster_path=Images/posters/a_complete_unknown.jpg
    Returns: review JSON from Reviews/reviews_a_complete_unknown.json
    """
    poster_path = request.args.get("poster_path")
    if not poster_path:
        return jsonify({"error": "Missing poster_path parameter"}), 400

    # Extract base filename (e.g., a_complete_unknown)
    base_name = os.path.splitext(os.path.basename(poster_path))[0]
    review_file = f"reviews_{base_name}.json"
    review_path = os.path.join(REVIEWS_FOLDER, review_file)

    if not os.path.exists(review_path):
        return jsonify({"error": f"No review file found for {base_name}"}), 404

    with open(review_path, "r", encoding="utf-8") as f:
        review_data = json.load(f)

    return jsonify(review_data)





@app.route("/related_films", methods=["GET"])
def get_recommendations():
    """
    Query Param: ?title=A%20Complete%20Unknown
    Returns top 5 related movies.
    """
    title = request.args.get("title")
    if not title:
        return jsonify({"error": "Missing title parameter"}), 400

    normalized = normalize_title(title)
    target_movie = MOVIES.get(normalized)
    if not target_movie:
        return jsonify({"error": f"Movie '{title}' not found"}), 404

    related = find_top_related_movies(target_movie, MOVIES, top_k=5)
    result = [movie_to_dict(MOVIES[key]) for key, _ in related]
    return jsonify(result)




@app.route("/profile_recommendation", methods=["POST"])
def profile_recommendation():
    """
    Expects JSON:
    {
        "user": { ... }
    }

    Returns: Top 10 recommended movie titles based on user profile (no filtering of watched)
    """
    try:
        data = request.get_json()
        user_data = data.get("user")
        if not user_data:
            return jsonify({"error": "Missing user object"}), 400

        user = User.from_dict(user_data)

        # Load all known users
        with open("Jsons/Users.json", "r", encoding="utf-8") as f:
            all_profiles = json.load(f)

        followed_profiles = [
            User.from_dict(u)
            for u in all_profiles
            if u["user_id"] in user.similar_users
        ]

        print(f"🧠 Parsed user ID: {user.id}")
        print(f"   Following: {user.similar_users}")
        print(f"   Followed profiles: {len(followed_profiles)}")

        from recommender import recommend_user_profile_full
        titles = recommend_user_profile_full(user, MOVIES, followed_profiles, top_k=10)
        print("🎯 Final Top 10 Titles:", titles)
        return jsonify(titles)

    except Exception as e:
        print("❌ Profile recommendation error:", str(e))
        return jsonify({"error": str(e)}), 500

























@app.route("/next_suggestion", methods=["POST"])
def next_suggestion():
    """
    Expects JSON:
    {
        "user": { ... },
        "movie_title": "A Complete Unknown"
    }

    Returns: List of top 5 recommended movie titles.
    """
    try:
        data = request.get_json()
        user_data = data.get("user")
        clicked_title = data.get("movie_title")

        if not user_data or not clicked_title:
            return jsonify({"error": "Missing user or movie_title"}), 400

        print("Incoming user keys:", list(user_data.keys()))
        print("Raw user JSON:", user_data)


        # Convert user dict → User object
        user = User.from_dict(user_data)

        # Normalize the clicked title
        normalized = normalize_title(clicked_title)
        
        print("Clicked title received:", clicked_title)
        print("Normalized title:", normalize_title(clicked_title))
        print("Available keys (first 10):", list(MOVIES.keys())[:10])

        if normalized not in MOVIES:
            return jsonify({"error": f"Movie '{clicked_title}' not found"}), 404

        # Update user's click history
        if clicked_title not in user.recent_clicked_titles:
            user.recent_clicked_titles.append(clicked_title)

        # Get recommendations (list of Movie objects)
        recommendations = recommend_next_movies(user, MOVIES)

        # Return only the movie titles
        titles = [movie["title"] for movie in recommendations]
        


        return jsonify(titles)

    except Exception as e:
        print("❌ Recommendation error:", str(e))
        return jsonify({"error": str(e)}), 500












# ------------------------------------------------------------------ #
if __name__ == "__main__":
    # Start development server on http://127.0.0.1:5000
    app.run(debug=True, port=5000)
