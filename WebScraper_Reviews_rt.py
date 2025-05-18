from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import json
import time
import os

# === MODIFY THESE 2 VALUES FOR OTHER MOVIES ===
movie_url = "https://www.rottentomatoes.com/m/sinners_2025/reviews?type=user"
movie_name = "Sinners"
# =============================================

# Setup Chrome
options = Options()
options.add_argument('--headless')
options.add_argument('--disable-gpu')
options.add_argument('--no-sandbox')
driver = webdriver.Chrome(options=options)

try:
    driver.get(movie_url)
    time.sleep(4)

    # Click "Load More" 4 times
    for i in range(4):
        try:
            load_more = driver.find_element(By.CSS_SELECTOR, 'rt-button[data-qa="load-more-btn"]')
            driver.execute_script("arguments[0].scrollIntoView(true);", load_more)
            time.sleep(1)
            load_more.click()
            time.sleep(4)
        except:
            print(f"Stopped early: Load More not found on click {i+1}")
            break

    # Scrape reviews
    review_elements = driver.find_elements(By.CSS_SELECTOR, 'div.audience-review-row[data-qa="review-item"]')

    reviews = []
    for review in review_elements[:100]:
        try:
            rating = review.find_element(By.TAG_NAME, 'rating-stars-group').get_attribute('score')
        except:
            rating = None
        try:
            text = review.find_element(By.CSS_SELECTOR, 'p.audience-reviews__review.js-review-text').text.strip()
        except:
            text = ""
        reviews.append({
            "rating": f"{rating}/5" if rating else None,
            "review": text
        })

    # Output file path
    output_path = f"Reviews/Reviews_rt_{movie_name}.json"

    # Save JSON
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(reviews, f, indent=2, ensure_ascii=False)

    print(f"✅ Saved {len(reviews)} reviews to {output_path}")

finally:
    driver.quit()
