import requests
import json

def extract_json_from_html(html):
    """Extract embedded JSON from Swiggy page"""
    start = html.find('<script id="__NEXT_DATA__" type="application/json">')
    end = html.find('</script>', start)
    json_text = html[start + len('<script id="__NEXT_DATA__" type="application/json">'): end]
    return json.loads(json_text)

def crawl_city(city_url, limit=None):
    """
    Crawl city page → return restaurant links
    :param city_url: Swiggy city page URL
    :param limit: number of links to return (None = all)
    """
    headers = {"user-agent": "Mozilla/5.0"}
    res = requests.get(city_url, headers=headers)
    if res.status_code != 200:
        print("Failed to fetch:", city_url)
        return []

    data = extract_json_from_html(res.text)
    cards = data["props"]["pageProps"]["initialState"]["cards"]["data"]["cards"]

    links = []
    for card in cards:
        if "data" in card and "cta" in card["data"]:
            link = "https://www.swiggy.com" + card["data"]["cta"]["link"]
            links.append(link)
            if limit and len(links) >= limit:
                break

    return links



from crawler import crawl_city

def main():
    city_url = "https://www.swiggy.com/city/mumbai"
    links = crawl_city(city_url, limit=5)  # get just 5 for test
    print("Extracted Links:")
    for link in links:
        print(link)

if __name__ == "__main__":
    main()
