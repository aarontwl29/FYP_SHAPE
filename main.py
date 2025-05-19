from data_loader import load_movies, load_hashtag_data, merge_movie_and_hashtag
from recommender import recommend_by_hashtags
from utils import normalize_title  # make sure you have this

from search import *

# Step 1: Load data
movies = load_movies('./Jsons/Movies.json')
hashtags = load_hashtag_data('./Hashtag_Reviews')
movie_db = merge_movie_and_hashtag(movies, hashtags)

# Step 2: Print total count
print(f"\n✅ Total movies loaded: {len(movie_db)}")

# Step 3: Show all available movie    
for movie in movie_db.values():
    print(movie)
    if movie.hashtags:
        print("🧠 Top Emotions:", ", ".join(movie.hashtags.get("top_emotions", [])))
        print("🔑 Top Keywords:", ", ".join(movie.hashtags.get("top_keywords", [])))
    else:
        print("⚠️ No hashtags found for this movie.")
    print("-" * 80)










name_input = input("🎬 Enter director name to search: ").strip()
results = filter_by_genre(name_input, movie_db)

if results:
    print(f"\n🎥 Movies directed by '{name_input}':")
    for m in results:
        print(f"- {m.title} ({m.year})")
else:
    print(f"❌ No movies found directed by '{name_input}'")

