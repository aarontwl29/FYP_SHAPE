import os
import json

def load_reviews(poster_path: str, folder: str = "Reviews") -> dict | None:
    """
    Convert 'Images/posters/a_complete_unknown.jpg' to 'reviews_a_complete_unknown.json'
    and load the corresponding file from the specified folder.
    """
    try:
        base_name = os.path.splitext(os.path.basename(poster_path))[0]
        filename = f"reviews_{base_name}.json"
        path = os.path.join(folder, filename)

        if not os.path.exists(path):
            return None

        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading review for {poster_path}: {e}")
        return None
