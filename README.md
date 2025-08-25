import requests
import csv
import time
import datetime
import os
import urllib3

# Disable SSL warnings if verify=False
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# -----------------------------
# CONFIG
# -----------------------------
CITIES = {
    "mumbai": {"lat": "19.0760", "lng": "72.8777"},
    "delhi": {"lat": "28.7041", "lng": "77.1025"},
    "pune": {"lat": "18.5204", "lng": "73.8567"}
}

BASE_URL = "https://www.swiggy.com/dapi/restaurants/list/v5"
MENU_URL = "https://www.swiggy.com/dapi/menu/pl"

TODAY = datetime.date.today().strftime("%Y-%m-%d")

# CSV Files
RESTAURANTS_FILE = "restaurants.csv"
MENUS_FILE = "menus.csv"
REVIEWS_FILE = "reviews.csv"
SNAPSHOT_FILE = "daily_snapshot.csv"

# -----------------------------
# Safe GET wrapper (handles SSL + errors)
# -----------------------------
def safe_get(url, params=None, headers=None):
    try:
        r = requests.get(url, params=params, headers=headers, timeout=15, verify=False)
        if r.status_code == 200:
            return r
        else:
            print(f"⚠️ HTTP {r.status_code} for {url}")
            return None
    except requests.exceptions.SSLError:
        print("❌ SSL Error – try using certifi or different network")
        return None
    except Exception as e:
        print("❌ Request failed:", e)
        return None

# -----------------------------
# CSV Setup (create headers once)
# -----------------------------
def init_csv():
    if not os.path.exists(RESTAURANTS_FILE):
        with open(RESTAURANTS_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["restaurant_id", "name", "city", "area", "cuisines",
                             "avg_cost_for_two", "rating", "delivery_time",
                             "delivery_fee", "is_pure_veg"])

    if not os.path.exists(MENUS_FILE):
        with open(MENUS_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["menu_id", "restaurant_id", "item_name", "category", "price", "is_veg", "available"])

    if not os.path.exists(REVIEWS_FILE):
        with open(REVIEWS_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["review_id", "restaurant_id", "user_name", "rating", "comment", "date"])

    if not os.path.exists(SNAPSHOT_FILE):
        with open(SNAPSHOT_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["record_date", "restaurant_id", "rating", "delivery_time", "delivery_fee", "item_name", "price"])

# -----------------------------
# Scraper Functions
# -----------------------------
def scrape_city(city, lat, lng):
    offset = 0
    while True:
        params = {
            "lat": lat,
            "lng": lng,
            "offset": offset,
            "sortBy": "RELEVANCE",
            "page_type": "DESKTOP_WEB_LISTING"
        }
        headers = {"User-Agent": "Mozilla/5.0"}
        r = safe_get(BASE_URL, params=params, headers=headers)
        if not r:
            break

        data = r.json()
        cards = data.get("data", {}).get("cards", [])
        if not cards:
            break

        for card in cards:
            info = card.get("data", {}).get("data", {})
            if not info:
                continue

            rest_id = info.get("id")
            name = info.get("name")
            area = info.get("area")
            cuisines = "|".join(info.get("cuisines", []))
            avg_cost = info.get("costForTwoString")
            rating = info.get("avgRating")
            delivery_time = info.get("deliveryTime")
            delivery_fee = info.get("feeDetails", {}).get("totalFee", 0)
            veg = info.get("veg", False)

            # Save restaurant row
            with open(RESTAURANTS_FILE, "a", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow([rest_id, name, city, area, cuisines, avg_cost,
                                 rating, delivery_time, delivery_fee, veg])

            # Scrape menu for this restaurant
            scrape_menu(rest_id)

        offset += 20
        time.sleep(1)  # polite delay

def scrape_menu(rest_id):
    params = {
        "page-type": "REGULAR_MENU",
        "complete-menu": "true",
        "lat": "19.0760",
        "lng": "72.8777",
        "restaurantId": rest_id
    }
    headers = {"User-Agent": "Mozilla/5.0"}
    r = safe_get(MENU_URL, params=params, headers=headers)
    if not r:
        return

    data = r.json()
    menu_items = data.get("data", {}).get("menu", {}).get("items", {})
    if not menu_items:
        return

    for item_id, item in menu_items.items():
        name = item.get("name")
        category = item.get("category")
        price = item.get("price", 0) / 100  # prices in paise
        is_veg = item.get("isVeg", 0) == 1
        available = not item.get("inStock", 0) == 0

        # Save menus.csv
        with open(MENUS_FILE, "a", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([item_id, rest_id, name, category, price, is_veg, available])

        # Save daily_snapshot.csv
        with open(SNAPSHOT_FILE, "a", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([TODAY, rest_id, None, None, None, name, price])

    # 🔹 Reviews endpoint (optional, may not always be available)
    reviews = data.get("data", {}).get("reviews", [])
    for idx, rev in enumerate(reviews):
        with open(REVIEWS_FILE, "a", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                f"{rest_id}_{idx}", rest_id,
                rev.get("userName"), rev.get("rating"),
                rev.get("comment"), rev.get("time")
            ])

# -----------------------------
# MAIN
# -----------------------------
if __name__ == "__main__":
    init_csv()
    for city, coords in CITIES.items():
        print(f"📍 Scraping {city}...")
        scrape_city(city, coords["lat"], coords["lng"])
        print(f"✅ Done {city}")
