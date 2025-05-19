# movie.py

class Movie:
    def __init__(self, title, year, genres, description, director, stars, length, ratings, hashtags=None):
        self.title = title
        self.year = int(year)
        self.genres = genres
        self.description = description
        self.director = director
        self.stars = stars
        self.length = length  # in minutes
        self.ratings = ratings  # dict with imdb, rt_tomatometer, rt_popcorn
        self.hashtags = hashtags or {}

    def __repr__(self):
        return (
            f"\n🎬 Title: {self.title} ({self.year})\n"
            f"📚 Genres: {', '.join(self.genres)}\n"
            f"📝 Description: {self.description[:120]}...\n"
            f"🎬 Director: {self.director}\n"
            f"⭐ Stars: {', '.join(self.stars)}\n"
            f"⏱️ Duration: {self.length} minutes\n"
            f"🎯 Ratings:\n"
            f"   - IMDb: {self.ratings.get('imdb', {}).get('score', 'N/A')}/10 ({self.ratings.get('imdb', {}).get('votes', 0)} votes)\n"
            f"   - RT Tomatometer: {self.ratings.get('rt_tomatometer', {}).get('score', 'N/A')}% ({self.ratings.get('rt_tomatometer', {}).get('reviews', 0)} reviews)\n"
            f"   - RT Popcorn: {self.ratings.get('rt_popcorn', {}).get('score', 'N/A')}% ({self.ratings.get('rt_popcorn', {}).get('votes', 0)} votes)\n"
        )
