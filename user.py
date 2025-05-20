from typing import List, Dict
from datetime import datetime

class User:
    def __init__(self,
                 user_id: str,
                 recent_clicked_titles: List[str] = [],
                 rated_movies: Dict[str, int] = {},
                 saved_titles: List[str] = [],
                 preferred_genres: List[str] = [],
                 preferred_keywords: List[str] = [],
                 last_active: str = None,
                 similar_users: List[str] = []):
        self.user_id = user_id
        self.recent_clicked_titles = recent_clicked_titles  # ["A Complete Unknown", "Interstellar"]
        self.rated_movies = rated_movies                    # {"A Complete Unknown": 8}
        self.saved_titles = saved_titles
        self.preferred_genres = preferred_genres
        self.preferred_keywords = preferred_keywords
        self.last_active = last_active or datetime.now().isoformat()
        self.similar_users = similar_users

    def to_dict(self):
        return self.__dict__

    @staticmethod
    def from_dict(data: Dict):
        return User(**data)
