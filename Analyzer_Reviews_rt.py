import json
import nltk
import re
import os
import pandas as pd
from collections import Counter
from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.corpus import stopwords
from utils import normalize_title  # Use same normalization across all modules

# === NLTK Setup ===
nltk.download("punkt")
nltk.download("averaged_perceptron_tagger")
nltk.download("stopwords")

# === Load JSON Files to Analyze ===

# Option 1 (Default): Load all .json review files in the "Reviews" folder
json_files = [
    os.path.join("Reviews", fname)
    for fname in os.listdir("Reviews")
    if fname.endswith(".json") and fname != "input_files.json"
]

# Option 2 : Only load specific files listed in Reviews/input_files.json
# with open("Reviews/input_files.json", "r") as f:
#     filenames = json.load(f)  # List of filenames like ["reviews_spider_man_homecoming.json", ...]
# json_files = [os.path.join("Reviews", fname) for fname in filenames if fname.endswith(".json")]

# === Output folders ===
output_folder = "Reviews_Csvs"
json_output_folder = "Hashtag_Reviews"
os.makedirs(output_folder, exist_ok=True)
os.makedirs(json_output_folder, exist_ok=True)

# === Filters ===
EXCLUDE_ADJECTIVES = {
    "great", "good", "excellent", "new", "many", "final", "fantastic", "bad", "little",
    "brilliant", "stellar", "much", "overall", "first", "last", "solid", "next", "powerful", "superb",
    "awesome", "super", "enough", "red", "second", "sure", "decent", "nice", "perfect", "high",
    "different", "right", "raw", "true", "accurate", "entire", "sound", "cinematic", "full", "whole",
    "social", "favorite", "accountant", "main", "cant", "third", "anna", "unicorn", "unicorns", "jurassic",
    "a24", "rich", "able", "narrative", "una", "jack", "chicken", "video", "que", "impossible", "absolute",
    "mejor", "due", "dead", "previous", "usual", "weak", "live", "wish", "sci-fi", "interstellar"
}

EXCLUDE_KEYWORDS = {
    "movie", "movies", "film", "films", "filme", "story", "acting", "end", "cast",
    "cinematography", "performances", "drama", "time", "que", "way", "world",
    "actors", "performance", "process", "characters", "character", "bit", "script", "power", "people",
    "everything", "score", "action", "fun", "scenes", "scene", "watch", "everyone", "message", "lot", "lots",
    "moments", "thing", "things", "anything", "sound", "design", "seat", "theater", "theaters", "ray", "nothing",
    "experience", "times", "year", "years", "part", "parts", "credits", "stars", "layers", "one", "line", "wait",
    "attention", "amount", "favor", "turns", "role", "roles", "kind", "audience", "minutes", "genre", "tone",
    "something", "director", "feature", "a24", "screen", "con", "para", "references", "place", "ledger",
    "ledgers", "cinema", "face", "point", "key", "feels", "voice", "reviews", "viewer", "level"
}

stop_words = set(stopwords.words("english"))

# === Process Each File ===
for filepath in json_files:
    with open(filepath, "r") as f:
        data = json.load(f)

    movie_title = data.get("movie_name", "unknown")
    movie_name = normalize_title(movie_title)  # ✅ consistent normalized name
    reviews = [d["review"] for d in data.get("reviews", [])]  

    emotion_adjs = []
    theme_keywords = []

    for review in reviews:
        for sentence in sent_tokenize(review.lower()):
            words = word_tokenize(sentence)
            tagged = nltk.pos_tag(words)

            for word, pos in tagged:
                if pos == "JJ" and word not in EXCLUDE_ADJECTIVES and word not in stop_words and len(word) > 2:
                    emotion_adjs.append(word)
                if pos.startswith("NN") and word not in EXCLUDE_KEYWORDS and word not in stop_words and len(word) > 2:
                    theme_keywords.append(word)

    # Create counters
    top_adjs = Counter(emotion_adjs).most_common(30)
    top_keywords = Counter(theme_keywords).most_common(30)

    # === Terminal Output ===
    print(f"\n🎭 Emotional Adjectives (Top 30) for {movie_title}:")
    print("Top 10:")
    for word, freq in top_adjs[:10]:
        print(f"- {word} ({freq})")
    print("\nRemaining 20:")
    for word, freq in top_adjs[10:30]:
        print(f"- {word} ({freq})")

    print(f"\n🔍 Thematic Keywords (Top 30) for {movie_title}:")
    print("Top 10:")
    for word, freq in top_keywords[:10]:
        print(f"- {word} ({freq})")
    print("\nRemaining 20:")
    for word, freq in top_keywords[10:30]:
        print(f"- {word} ({freq})")

    # === Save Top 30 to CSV (using normalized name) ===
    df = pd.DataFrame({
        "Emotional Adjective": [w for w, _ in top_adjs],
        "Adjective Count": [c for _, c in top_adjs],
        "Theme Keyword": [w for w, _ in top_keywords],
        "Keyword Count": [c for _, c in top_keywords],
    })
    output_csv = os.path.join(output_folder, f"{movie_name}.csv")
    df.to_csv(output_csv, index=False)

    # === Save Top 10 to JSON (using normalized name) ===
    summary_data = {
        "movie_name": movie_title,
        "top_emotions": [w for w, _ in top_adjs[:10]],
        "top_keywords": [w for w, _ in top_keywords[:10]]
    }
    output_json = os.path.join(json_output_folder, f"{movie_name}.json")
    with open(output_json, "w") as json_out:
        json.dump(summary_data, json_out, indent=2)
