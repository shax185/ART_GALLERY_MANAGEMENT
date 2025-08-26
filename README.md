import praw
import csv
import os

# === Authenticate (replace with your own Reddit app credentials) ===
reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",
    client_secret="YOUR_CLIENT_SECRET",
    user_agent="reddit_scraper"
)

# === Setup folders ===
os.makedirs("reddit_data/posts", exist_ok=True)
os.makedirs("reddit_data/comments", exist_ok=True)

def scrape_subreddit(subreddit_name, post_limit=100):
    subreddit = reddit.subreddit(subreddit_name)

    # === Collect Posts ===
    post_file = f"reddit_data/posts/{subreddit_name}_posts.csv"
    with open(post_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["id", "title", "score", "author", "created_utc", "url", "num_comments"])
        for post in subreddit.hot(limit=post_limit):
            writer.writerow([post.id, post.title, post.score,
                             str(post.author), post.created_utc, post.url, post.num_comments])

    # === Collect Comments ===
    comment_file = f"reddit_data/comments/{subreddit_name}_comments.csv"
    with open(comment_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["post_id", "comment_id", "author", "score", "created_utc", "body"])
        
        for post in subreddit.hot(limit=post_limit):
            post.comments.replace_more(limit=0)  # flatten "MoreComments"
            for comment in post.comments.list():
                writer.writerow([post.id, comment.id, str(comment.author),
                                 comment.score, comment.created_utc, comment.body])

    print(f"✅ Finished scraping r/{subreddit_name} → {post_file}, {comment_file}")

# === Example Usage ===
subreddits_to_scrape = ["python", "learnprogramming", "datascience"]

for sub in subreddits_to_scrape:
    scrape_subreddit(sub, post_limit=200)  # collect 200 posts per subreddit
