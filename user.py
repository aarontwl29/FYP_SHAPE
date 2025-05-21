from dataclasses import dataclass
from typing import List, Dict, Optional

@dataclass
class User:
    id: str
    recent_clicked_titles: List[str]
    rated_movies: Dict[str, int]
    saved_titles: List[str]
    preferred_genres: List[str]
    preferred_keywords: List[str]
    last_active: Optional[str]
    similar_users: List[str]

    @staticmethod
    def from_dict(data: dict) -> "User":
        return User(
            id=data.get("user_id", ""),  # supports JSON key
            recent_clicked_titles=data.get("recent_clicked_titles", []),
            rated_movies=data.get("rated_movies", {}),
            saved_titles=data.get("saved_titles", []),
            preferred_genres=data.get("preferred_genres", []),
            preferred_keywords=data.get("preferred_keywords", []),
            last_active=data.get("last_active", None),
            similar_users=data.get("similar_users", [])
        )
