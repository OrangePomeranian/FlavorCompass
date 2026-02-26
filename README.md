🍽 FlavorCompass

FlavorCompass is a data-driven recipe recommendation system that transforms structured culinary data into interpretable, similarity-based food recommendations.

The system scrapes recipes, engineers multi-dimensional flavor profiles, and builds a content-based recommendation engine powered by cosine similarity.

🚀 Overview

FlavorCompass integrates:

Web scraping

Relational database modeling

Feature engineering

Machine learning

Interactive UI

Instead of relying on opaque text embeddings, the system models explicit culinary attributes such as:

Taste (sweet, salty, sour, umami, spicy)

Texture (creamy, crispy, fatty)

Protein type (meat, fish, dairy, plant-based)

Cuisine (Italian, Polish, Asian, Mexican)

Cooking technique (fried, baked, grilled, boiled)

Dish category (dessert, soup, salad, main dish)

Caloric profile

Dietary properties (vegan, vegetarian, gluten-free)

Each recipe becomes a structured feature vector used for similarity computation.

🧠 Architecture
1️⃣ Data Collection

Recipes are scraped using Scrapy and stored in structured JSON format.

2️⃣ Database Layer

Data is normalized into SQLite:

articles

ingredients

tags

article_flavor_profile (engineered feature table)

3️⃣ Feature Engineering

The article_flavor_profile table generates 30+ engineered attributes including:

Flavor dimensions

Protein categorization

Cooking method

Cuisine type

Nutritional heuristics

These attributes create a structured vector space representation.

4️⃣ Recommendation Engine

The recommendation model:

Loads structured feature vectors

Scales features

Computes cosine similarity matrix

Builds a user preference vector from selected recipes

Returns top-N similar dishes

This is a deterministic, interpretable content-based recommender system.

5️⃣ Frontend

An interactive interface is built using Streamlit, allowing users to:

Select recipes they like

Instantly receive personalized recommendations

View titles and associated images

📦 Tech Stack

Python

Scrapy

SQLite

Pandas

NumPy

Scikit-learn

Streamlit

Joblib
<img width="1437" height="787" alt="Screenshot 2026-02-26 at 21 16 42" src="https://github.com/user-attachments/assets/aadb8a8c-d1e7-4f33-a39f-fa1ddfb839cb" />
