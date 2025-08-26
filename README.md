import praw
import ssl
import certifi
import prawcore

def create_reddit_instance(use_certifi=False):
    if use_certifi:
        print("⚡ Retrying with certifi certificates...")
        ssl_context = ssl.create_default_context(cafile=certifi.where())
        # Force prawcore/requests to use certifi
        prawcore.session.HTTPSession._default_kwargs["verify"] = certifi.where()
    
    return praw.Reddit(
        client_id="YOUR_CLIENT_ID",
        client_secret="YOUR_CLIENT_SECRET",
        user_agent="reddit_scraper_test"
    )

def test_reddit_connection():
    try:
        reddit = create_reddit_instance()
        # Try fetching 5 posts from r/python
        for post in reddit.subreddit("python").hot(limit=5):
            print(f"✅ {post.title} (score: {post.score})")
        print("🎉 Connection successful without certifi fix.")
    except Exception as e:
        print("❌ First attempt failed:", e)
        # Retry with certifi
        try:
            reddit = create_reddit_instance(use_certifi=True)
            for post in reddit.subreddit("python").hot(limit=5):
                print(f"✅ {post.title} (score: {post.score})")
            print("🎉 Connection successful with certifi fix.")
        except Exception as e2:
            print("🚨 Still failed:", e2)

if __name__ == "__main__":
    test_reddit_connection()
