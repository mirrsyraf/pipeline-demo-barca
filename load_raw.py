import os
import requests
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

load_dotenv()

# ---------- EXTRACT: get data from the API ----------
url = "https://api.football-data.org/v4/teams/81/matches"
params = {"season": 2026}
headers = {"X-Auth-Token": os.getenv("FOOTBALL_DATA_API_KEY")}

response = requests.get(url, headers=headers, params=params, timeout=30)
response.raise_for_status()  # stop here if the API returned an error
data = response.json()
print("Fetched", len(data.get("matches", [])), "matches from the API")

# ---------- LOAD: save the raw JSON into PostgreSQL ----------
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT"),
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
)

with conn:  # automatically saves (commits) the insert
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO raw.api_responses (endpoint, source_url, params, payload)
            VALUES (%s, %s, %s, %s)
            """,
            ("team_matches", url, Json(params), Json(data)),
        )

conn.close()
print("Saved raw data into raw.api_responses")