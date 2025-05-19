# main.py

from data_loader import load_movies, load_hashtag_data, merge_movie_and_hashtag

# Step 1: Load data
movies = load_movies('./Jsons/Movies.json')
hashtags = load_hashtag_data('./Hashtag_Reviews')

# Step 2: Merge hashtag info
movie_db = merge_movie_and_hashtag(movies, hashtags)

# Step 3: Print all movie info + hashtags
print(f"\n✅ Total movies loaded: {len(movie_db)}")

for movie in movie_db.values():
    print(movie)
    if movie.hashtags:
        print("🧠 Top Emotions:", ", ".join(movie.hashtags.get("top_emotions", [])))
        print("🔑 Top Keywords:", ", ".join(movie.hashtags.get("top_keywords", [])))
    else:
        print("⚠️ No hashtags found for this movie.")
    print("-" * 80)
