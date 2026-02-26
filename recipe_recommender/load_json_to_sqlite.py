import json
import sqlite3

# ------------------------------
# DATABASE CONNECTION
# ------------------------------
conn = sqlite3.connect("recipes.db")
cursor = conn.cursor()

cursor.execute("PRAGMA foreign_keys = ON;")

# ------------------------------
# CREATE TABLES (NORMALIZED)
# ------------------------------

# Main table
cursor.execute("""
CREATE TABLE IF NOT EXISTS articles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    url TEXT UNIQUE,
    keywords TEXT,
    og_description TEXT,
    og_image TEXT,
    step_count INTEGER,
    category TEXT
);
""")

# Ingredients table
cursor.execute("""
CREATE TABLE IF NOT EXISTS ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE
);
""")

# Article-Ingredients (many-to-many)
cursor.execute("""
CREATE TABLE IF NOT EXISTS article_ingredients (
    article_id INTEGER,
    ingredient_id INTEGER,
    FOREIGN KEY(article_id) REFERENCES articles(id),
    FOREIGN KEY(ingredient_id) REFERENCES ingredients(id),
    UNIQUE(article_id, ingredient_id)
);
""")

# Tags table
cursor.execute("""
CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE
);
""")

# Article-Tags (many-to-many)
cursor.execute("""
CREATE TABLE IF NOT EXISTS article_tags (
    article_id INTEGER,
    tag_id INTEGER,
    FOREIGN KEY(article_id) REFERENCES articles(id),
    FOREIGN KEY(tag_id) REFERENCES tags(id),
    UNIQUE(article_id, tag_id)
);
""")

# ------------------------------
# INDEXES (VERY IMPORTANT)
# ------------------------------

cursor.execute("CREATE INDEX IF NOT EXISTS idx_article_url ON articles(url);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_tag_name ON tags(name);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_ingredient_name ON ingredients(name);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_article_tags_article ON article_tags(article_id);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_article_tags_tag ON article_tags(tag_id);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_article_ing_article ON article_ingredients(article_id);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_article_ing_ing ON article_ingredients(ingredient_id);")

# ------------------------------
# LOAD JSON FILE
# ------------------------------
with open("/Users/daria/Desktop/DMP/article_scraper/article_scraper/dania.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# ------------------------------
# INSERT DATA
# ------------------------------
for item in data:

    steps_list = item.get("steps", [])
    step_count = len(steps_list)

    # Insert article
    try:
        cursor.execute("""
            INSERT INTO articles (
                title, url, keywords,
                og_description, og_image,
                step_count, category
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (
            item.get("title"),
            item.get("url"),
            item.get("keywords"),
            item.get("og_description"),
            item.get("og_image"),
            step_count,
            item.get("category")
        ))

        article_id = cursor.lastrowid

    except sqlite3.IntegrityError:
        cursor.execute("SELECT id FROM articles WHERE url = ?", (item.get("url"),))
        article_id = cursor.fetchone()[0]

    # --------------------------
    # INGREDIENTS
    # --------------------------
    for ing in item.get("ingredients", []):
        ing = ing.strip().lower()

        cursor.execute("INSERT OR IGNORE INTO ingredients (name) VALUES (?)", (ing,))
        cursor.execute("SELECT id FROM ingredients WHERE name = ?", (ing,))
        ingredient_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT OR IGNORE INTO article_ingredients (article_id, ingredient_id)
            VALUES (?, ?)
        """, (article_id, ingredient_id))

    # --------------------------
    # TAGS
    # --------------------------
    for tag in item.get("tags", []):
        tag = tag.strip().lower()

        cursor.execute("INSERT OR IGNORE INTO tags (name) VALUES (?)", (tag,))
        cursor.execute("SELECT id FROM tags WHERE name = ?", (tag,))
        tag_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT OR IGNORE INTO article_tags (article_id, tag_id)
            VALUES (?, ?)
        """, (article_id, tag_id))


# ------------------------------
# SAVE & CLOSE
# ------------------------------
conn.commit()
conn.close()

print("✅ Data normalized and inserted successfully!")