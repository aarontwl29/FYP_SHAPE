from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def recommend_by_hashtags(movie, movie_db, top_n=5):
    corpus = []
    titles = []
    
    for m in movie_db.values():
        tags = " ".join(m.hashtags.get("top_emotions", []) + m.hashtags.get("top_keywords", []))
        corpus.append(tags)
        titles.append(m.title)

    vectorizer = TfidfVectorizer()
    tfidf_matrix = vectorizer.fit_transform(corpus)

    target_index = titles.index(movie.title)
    scores = cosine_similarity(tfidf_matrix[target_index], tfidf_matrix).flatten()
    
    ranked_indices = scores.argsort()[::-1][1:top_n+1]
    return [titles[i] for i in ranked_indices]
