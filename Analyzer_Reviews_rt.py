import json
import nltk
import re
from collections import Counter
from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.corpus import stopwords

# STEP 0: Run this ONCE in Terminal before using this script:
# python3 -m nltk.downloader punkt averaged_perceptron_tagger stopwords

# STEP 1: Load JSON reviews
with open("Adventure/Reviews_rt_Interstellar.json", "r") as f:
    data = json.load(f)
reviews = [d["review"] for d in data]

# STEP 2: Prepare token filters
EXCLUDE_ADJECTIVES = {
    "great", "good", "excellent", "new",
    "many", "final", "fantastic", "bad", "little",
    "brilliant", "stellar", "much", "overall", "first",
    "last", "solid", "next", "powerful", "superb",
    "awesome", "super", "enough", "red", "second",
    "sure", "decent", "nice", "perfect", "high",
    "different", "right", "raw", "true", "accurate",
    "entire", "sound", "cinematic", "full", "whole",
    "social", "favorite", "accountant", "main", "cant", "third",
    "anna", "unicorn", "unicorns", "jurassic", "a24", "rich",
    "able", "narrative", "una", "jack", "chicken", "video", "que",
    "impossible", "absolute", "mejor", "due", "dead", "previous",
    "usual", "weak", "live", "wish", "sci-fi", "interstellar"
}

EXCLUDE_KEYWORDS = {
    "movie", "movies", "film", "films", "filme", "story", "acting", "end", "cast",
    "cinematography", "performances", "drama", "time", "que", "way", "world",
    "actors", "performance", "process", "characters", "character", "bit",
    "script", "power", "people", "everything", "score",
    "action", "fun", "scenes", "scene", "watch", "everyone",
    "message", "lot", "lots", "moments", "thing", "things", "anything",
    "sound", "design", "seat", "theater", "theaters", "ray", "nothing",
    "experience", "times", "year", "years", "part", "parts",
    "credits", "stars", "layers", "one", "line", "wait", "attention", "amount",
    "favor", "turns", "role", "roles", "kind", "audience", "minutes",
    "genre", "tone", "something", "director", "feature", "a24",
    "screen", "con", "para", "references", "place",
    "ledger", "ledgers", "cinema", "face", "point", "key", "feels",
    "voice", "reviews", "viewer", "level"
}



stop_words = set(stopwords.words("english"))

emotion_adjs = []
theme_keywords = []

# STEP 3: Analyze each review
for review in reviews:
    for sentence in sent_tokenize(review.lower()):
        words = word_tokenize(sentence)
        tagged = nltk.pos_tag(words)

        for word, pos in tagged:
            if pos == "JJ" and word not in EXCLUDE_ADJECTIVES and word not in stop_words and len(word) > 2:
                emotion_adjs.append(word)
            if pos.startswith("NN") and word not in EXCLUDE_KEYWORDS and word not in stop_words and len(word) > 2:
                theme_keywords.append(word)

# STEP 4: Show results
print("\n🎭 Top 30 Emotional Adjectives:")
for word, freq in Counter(emotion_adjs).most_common(30):
    print(f"- {word} ({freq})")

print("\n🔍 Top 30 Thematic/Keyword Nouns:")
for word, freq in Counter(theme_keywords).most_common(30):
    print(f"- {word} ({freq})")

# Optionally write to CSV
import pandas as pd
df = pd.DataFrame({
    "Emotional Adjective": [w for w, _ in Counter(emotion_adjs).most_common(30)],
    "Adjective Count": [c for _, c in Counter(emotion_adjs).most_common(30)],
    "Theme Keyword": [w for w, _ in Counter(theme_keywords).most_common(30)],
    "Keyword Count": [c for _, c in Counter(theme_keywords).most_common(30)],
})
df.to_csv("review_analysis_summary.csv", index=False)
