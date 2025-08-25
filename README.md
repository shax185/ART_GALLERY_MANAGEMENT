import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

BASE_URL = "https://www.swiggy.com"

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) "
                  "Chrome/115.0 Safari/537.36"
}

def scrape_city(city="mumbai", max_restaurants=10):
    url = f"{BASE_URL}/city/{city}"
    print(f"🔎 Scraping city: {city} → {url}")

    response = requests.get(url, headers=headers, timeout=15, verify=False)
    if response.status_code != 200:
        print(f"❌ Failed to load {url}, status: {response.status_code}")
        return

    soup = BeautifulSoup(response.text, "html.parser")
    cards = soup.find_all("div", {"class": "_1HEuF"})

    restaurants, menus = [], []
    count = 0

    for card in cards:
        try:
            name = card.find("div", {"class": "nA6kb"}).text.strip()
            cuisines = card.find("div", {"class": "_1gURR"}).text.strip()
            rating = card.find("div", {"class": "_9uwBC"}).text.strip() if card.find("div", {"class": "_9uwBC"}) else "NA"
            rest_id = card.find("a")["href"].split("/")[-1]

            restaurants.append({
                "rest_id": rest_id,
                "name": name,
                "cuisines": cuisines,
                "rating": rating,
                "city": city
            })

            print(f"✅ Restaurant: {name} ({rest_id})")

            # scrape menu for this restaurant
            menu_url = f"{BASE_URL}{card.find('a')['href']}"
            menus.extend(scrape_menu(rest_id, menu_url))

            count += 1
            if count >= max_restaurants:
                break

            time.sleep(1)  # politeness delay
        except Exception as e:
            print(f"⚠️ Error parsing restaurant: {e}")

    pd.DataFrame(restaurants).to_csv("restaurants.csv", index=False)
    pd.DataFrame(menus).to_csv("menus.csv", index=False)

    print(f"\n🎉 Done! Saved {len(restaurants)} restaurants and {len(menus)} menu items.")

def scrape_menu(rest_id, url):
    try:
        resp = requests.get(url, headers=headers, timeout=15, verify=False)
        if resp.status_code != 200:
            print(f"   ❌ Failed menu for {rest_id}")
            return []

        soup = BeautifulSoup(resp.text, "html.parser")
        items = soup.find_all("div", {"class": "styles_itemName__hLfgz"})
        prices = soup.find_all("span", {"class": "rupee"})

        menu_data = []
        for item, price in zip(items, prices):
            menu_data.append({
                "rest_id": rest_id,
                "item_name": item.text.strip(),
                "price": price.text.strip().replace("₹", "")
            })

        print(f"   → Scraped {len(menu_data)} items for {rest_id}")
        return menu_data
    except Exception as e:
        print(f"   ⚠️ Error scraping menu for {rest_id}: {e}")
        return []


if __name__ == "__main__":
    scrape_city("mumbai", max_restaurants=10)
