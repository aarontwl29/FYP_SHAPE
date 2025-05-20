from typing import List, Dict, Optional, Union


class Movie:
    """
    Immutable data-class-style container for a single movie record.
    """

    def __init__(  # pylint: disable=too-many-arguments
        self,
        title: str,
        year: Union[int, str],
        genres: List[str],
        description: str,
        director: Union[str, List[str]],
        stars: List[str],
        length: int,
        ratings: Dict,
        hashtags: Optional[Dict] = None,
        poster_path: Optional[str] = None,
    ):
        self.title = title
        self.year = int(year)
        self.genres = genres
        self.description = description
        self.director = (
            ", ".join(director) if isinstance(director, list) else director
        )
        self.stars = stars
        self.length = length                    # minutes
        self.ratings = ratings                  # imdb / rt_tomatometer / rt_popcorn
        self.hashtags = hashtags or {}
        self.poster_path = poster_path

    # ------------------------------------------------------------------ #
    def __repr__(self) -> str:
        """Pretty, multi-line print-out for dev inspection."""
        lines = [
            f"\n🎬 Title: {self.title} ({self.year})",
            f"📚 Genres: {', '.join(self.genres)}",
            f"📝 Description: {self.description[:120]}...",
            f"🎬 Director: {self.director}",
            f"⭐ Stars: {', '.join(self.stars)}",
            f"⏱️ Duration: {self.length} min",
            "🎯 Ratings:",
            f"   • IMDb: {self.ratings.get('imdb', {}).get('score', 'N/A')}/10 "
            f"({self.ratings.get('imdb', {}).get('votes', 0)} votes)",
            f"   • RT Tomatometer: {self.ratings.get('rt_tomatometer', {}).get('score', 'N/A')}% "
            f"({self.ratings.get('rt_tomatometer', {}).get('reviews', 0)} reviews)",
            f"   • RT Popcorn: {self.ratings.get('rt_popcorn', {}).get('score', 'N/A')}% "
            f"({self.ratings.get('rt_popcorn', {}).get('votes', 0)} votes)",
        ]
        if self.poster_path:
            lines.append(f"🖼️ Poster: {self.poster_path}")
        return "\n".join(lines)
