import sqlite3
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.metrics.pairwise import cosine_similarity
import joblib
import os


# ==========================================
# 1. LOAD DATA
# ==========================================

def load_data(db_path="recipes.db"):

    conn = sqlite3.connect(db_path)

    df = pd.read_sql_query("""
        SELECT afp.*, a.title
        FROM article_flavor_profile afp
        JOIN articles a ON a.id = afp.article_id
    """, conn)

    conn.close()

    df = df.dropna()
    return df


# ==========================================
# 2. BUILD MODEL (ONLY ONCE)
# ==========================================

def build_model(df):

    ids = df["article_id"].values
    titles = df["title"].values

    X = df.drop(columns=["article_id", "title"])

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    similarity_matrix = cosine_similarity(X_scaled)

    return {
        "similarity_matrix": similarity_matrix,
        "ids": ids,
        "titles": titles,
        "df": df,
        "scaler": scaler
    }


# ==========================================
# 3. RECOMMENDATION
# ==========================================

def recommend(selected_ids, model, top_n=5):

    similarity_matrix = model["similarity_matrix"]
    ids = model["ids"]
    df = model["df"]

    # walidacja ID
    selected_ids = [i for i in selected_ids if i in ids]

    if len(selected_ids) == 0:
        raise ValueError("No valid recipe IDs provided.")

    # indeksy w macierzy
    selected_idx = [np.where(ids == i)[0][0] for i in selected_ids]

    # profil użytkownika = średni wektor podobieństwa
    mean_similarity = similarity_matrix[selected_idx].mean(axis=0)

    # wyklucz już wybrane
    mean_similarity[selected_idx] = -1

    # ranking
    recommended_idx = np.argsort(mean_similarity)[::-1][:top_n]

    results = df.iloc[recommended_idx].copy()
    results["similarity_score"] = mean_similarity[recommended_idx]

    return results[["article_id", "title", "similarity_score"]]


# ==========================================
# 4. OPTIONAL: SAVE / LOAD MODEL
# ==========================================

def save_model(model, path="recommender_model.pkl"):
    joblib.dump(model, path)


def load_model(path="recommender_model.pkl"):
    return joblib.load(path)


# ==========================================
# 5. MAIN
# ==========================================

if __name__ == "__main__":

    # jeśli model istnieje → wczytaj
    if os.path.exists("recommender_model.pkl"):
        model = load_model()
        print("Model loaded from file.")
    else:
        df = load_data("recipes.db")
        model = build_model(df)
        save_model(model)
        print("Model built and saved.")

    # symulacja użytkownika
    user_selected = [10]

    recommendations = recommend(user_selected, model, top_n=5)

    print("\nRecommendations:")
    print(recommendations)