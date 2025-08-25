import requests
import json

def crawl_city(city_api_url, limit=5):
    """
    Crawl restaurants from Swiggy's city API
    :param city_api_url: Swiggy API endpoint (with lat/lng or seen in Network tab)
    :param limit: Number of restaurants to fetch (for testing)
    """
    headers = {"user-agent": "Mozilla/5.0"}
    res = requests.get(city_api_url, headers=headers)
    
    if res.status_code != 200:
        print("Failed to fetch:", city_api_url)
        return []

    data = res.json()
    cards = data["data"]["cards"]

    links = []
    for card in cards:
        if "data" in card and "cta" in card["data"]:
            link = "https://www.swiggy.com" + card["data"]["cta"]["link"]
            links.append(link)
            if len(links) >= limit:
                break

    return links



from crawler import crawl_city

def main():
    # Example: Mumbai restaurants API (you can grab this URL from your Network tab)
    city_api_url = "https://www.swiggy.com/dapi/restaurants/list/v5?lat=19.0760&lng=72.8777&page_type=DESKTOP_WEB_LISTING"
    
    links = crawl_city(city_api_url, limit=5)
    
    print("Extracted Links:")
    for link in links:
        print(link)

if __name__ == "__main__":
    main()
    
