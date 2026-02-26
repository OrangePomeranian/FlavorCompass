import streamlit as st
import sqlite3
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.metrics.pairwise import cosine_similarity


# ==========================================
# LOAD DATA
# ==========================================

@st.cache_data
def load_data():
    conn = sqlite3.connect("recipes.db")
    df = pd.read_sql_query("""
        SELECT 
            afp.*, 
            a.title,
            a.og_image,
            a.url
        FROM article_flavor_profile afp
        JOIN articles a ON a.id = afp.article_id
    """, conn)
    conn.close()
    return df.dropna()


# ==========================================
# BUILD MODEL (zgodnie z Twoją strukturą)
# ==========================================

@st.cache_resource
def build_model(df):

    ids = df["article_id"].values

    # tylko cechy numeryczne
    X = df.drop(columns=["article_id", "title", "og_image", "url"])

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    similarity_matrix = cosine_similarity(X_scaled)

    return {
        "similarity_matrix": similarity_matrix,
        "ids": ids,
        "df": df
    }


# ==========================================
# TWOJA FUNKCJA RECOMMEND (niezmieniona logika)
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

    return results[
        ["article_id", "title", "og_image", "url", "similarity_score"]
    ]


# ==========================================
# STREAMLIT UI
# ==========================================

st.set_page_config(layout="wide")
st.title("🍽 Recipe Recommendation System")

df = load_data()
model = build_model(df)

recipe_options = df[["article_id", "title"]]

selected_titles = st.multiselect(
    "Select recipes you like:",
    recipe_options["title"]
)

top_n = st.slider("Number of recommendations:", 1, 10, 5)

if selected_titles:

    selected_ids = recipe_options[
        recipe_options["title"].isin(selected_titles)
    ]["article_id"].tolist()

    recommendations = recommend(selected_ids, model, top_n)

    st.subheader("Recommended Recipes")

    for _, row in recommendations.iterrows():

        col1, col2 = st.columns([1, 2])

        with col1:
            if row["og_image"]:
                st.image(row["og_image"], use_container_width=True)

        with col2:
            st.markdown(f"### {row['title']}")
            st.write(f"Similarity score: {row['similarity_score']:.2f}")

            if row["url"]:
                st.markdown(f"[View full recipe]({row['url']})")

        st.divider()