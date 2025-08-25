import requests
import json
import csv
import time

# Cities you want to scrape
cities = ["mumbai", "delhi", "pune"]

# Output files
restaurants_file = "restaurants.csv"
menus_file = "menus.csv"

# Write CSV headers
with open(restaurants_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["restaurant_id", "name", "city", "cuisines", "avg_cost_for_two", "rating", "delivery_time", "veg"])

with open(menus_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["menu_id", "restaurant_id", "item_name", "category", "price", "veg"])

# Swiggy API endpoint (hidden but accessible from network calls)
SWIGGY_API = "https://www.swiggy.com/dapi/restaurants/list/v5"

def scrape_city(city):
    offset = 0
    restaurant_count = 0

    while True:
        params = {
            "lat": "19.0760",  # default coords, change per city
            "lng": "72.8777",
            "offset": offset,
            "sortBy": "RELEVANCE",
            "page_type": "DESKTOP_WEB_LISTING"
        }
        headers = {"User-Agent": "Mozilla/5.0"}
        r = requests.get(SWIGGY_API, params=params, headers=headers)

        if r.status_code != 200:
            print(f"Failed for {city}, offset {offset}")
            break

        data = r.json()
        restaurants = data.get("data", {}).get("cards", [])
        if not restaurants:
            break

        for card in restaurants:
            info = card.get("data", {}).get("data", {})
            if not info:
                continue

            rest_id = info.get("id")
            name = info.get("name")
            cuisines = ", ".join(info.get("cuisines", []))
            avg_cost = info.get("costForTwoString")
            rating = info.get("avgRating")
            delivery = info.get("deliveryTime")
            veg = info.get("veg", False)

            with open(restaurants_file, "a", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow([rest_id, name, city, cuisines, avg_cost, rating, delivery, veg])

            restaurant_count += 1

        offset += 20
        time.sleep(1)  # be polite

    print(f"✅ Scraped {restaurant_count} restaurants for {city}")

# Run scraper
for city in cities:
    scrape_city(city)
