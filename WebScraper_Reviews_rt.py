from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import json
import time
import os

from movie_list import movies

CHUNK_SIZE = 100
MAX_REVIEWS = 500
output_dir = "Reviews"
os.makedirs(output_dir, exist_ok=True)

options = Options()
options.add_argument('--headless')
options.add_argument('--disable-gpu')
options.add_argument('--no-sandbox')

for movie in movies:
    movie_url = movie["url"]
    movie_name = movie["name"]
    output_path = os.path.join(output_dir, f"Reviews_rt_{movie_name}.json")

    print(f"\n🔍 Scraping reviews for: {movie_name}")

    driver = webdriver.Chrome(options=options)

    try:
        driver.get(movie_url)
        time.sleep(5)

        processed_count = 0
        total_saved_reviews = 0

        if not os.path.exists(output_path):
            with open(output_path, "w", encoding="utf-8") as f:
                json.dump([], f)

        while total_saved_reviews < MAX_REVIEWS:
            review_elements = driver.find_elements(By.CSS_SELECTOR, 'div.audience-review-row[data-qa="review-item"]')
            new_reviews = review_elements[processed_count:]

            if not new_reviews:
                print("⚠️ No new reviews loaded.")
                break

            chunk = []

            for idx, review in enumerate(new_reviews, start=processed_count + 1):
                try:
                    rating = review.find_element(By.TAG_NAME, 'rating-stars-group').get_attribute('score')
                except:
                    rating = None

                try:
                    text = review.find_element(By.CSS_SELECTOR, 'p.audience-reviews__review.js-review-text').text.strip()
                except:
                    text = ""

                chunk.append({
                    "rating": f"{rating}/5" if rating else None,
                    "review": text
                })

                preview = " ".join(text.split()[:5])
                print(f"{idx:>3}. {preview}...")

                if idx >= MAX_REVIEWS:
                    break

            with open(output_path, "r", encoding="utf-8") as f:
                existing_data = json.load(f)

            existing_data.extend(chunk[:MAX_REVIEWS - total_saved_reviews])

            with open(output_path, "w", encoding="utf-8") as f:
                json.dump(existing_data, f, indent=2, ensure_ascii=False)

            total_saved_reviews = len(existing_data)
            processed_count += len(new_reviews)

            print(f"💾 Saved chunk: {len(chunk)} reviews. Total saved: {total_saved_reviews}\n")

            if total_saved_reviews >= MAX_REVIEWS:
                break

            try:
                load_more = driver.find_element(By.CSS_SELECTOR, 'rt-button[data-qa="load-more-btn"]')
                driver.execute_script("arguments[0].scrollIntoView(true);", load_more)
                time.sleep(1)
                load_more.click()
                time.sleep(3)
            except:
                print("⚠️ Load More button not found or finished.")
                break

        print(f"✅ Done! Total reviews saved: {total_saved_reviews} → {output_path}")

    finally:
        driver.quit()
