import praw
import ssl

# Disable SSL verification globally
ssl._create_default_https_context = ssl._create_unverified_context

# Initialize PRAW
reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",
    client_secret="YOUR_CLIENT_SECRET",
    user_agent="datacrawl"
)

# Example: scrape top posts from r/Python
subreddit = reddit.subreddit("Python")

for post in subreddit.top(limit=10):
    print(f"Title: {post.title}")
    print(f"Score: {post.score}")
    print(f"URL: {post.url}")
    print("-" * 50)
