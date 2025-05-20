# main.py
from data_loader import load_database
from search import filter_by_director          # make sure your search module provides this

# ------------------------------------------------------------------ #
movie_db = load_database("./Jsons")            # one-call load
print(f"✅ Total movies loaded: {len(movie_db)}\n" + "=" * 80)

for movie in movie_db.values():
    print(movie)
    if movie.hashtags:
        print("🧠 Top Emotions:", ", ".join(movie.hashtags["top_emotions"]))
        print("🔑 Top Keywords:", ", ".join(movie.hashtags["top_keywords"]))
    else:
        print("⚠️ No hashtags for this movie.")
    print("-" * 80)

# ------------------------------------------------------------------ #
print("\n🎬 Search by director")
name_input = input("Enter director name: ").strip()
results = filter_by_director(name_input, movie_db)

if results:
    print(f"\n🎥 Movies directed by '{name_input}':")
    for m in results:
        print(f"- {m.title} ({m.year})")
else:
    print(f"❌ No movies found directed by '{name_input}'")
