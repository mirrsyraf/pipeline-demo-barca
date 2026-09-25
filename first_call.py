import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("FOOTBALL_DATA_API_KEY")

url = "https://api.football-data.org/v4/teams/81/matches"
headers = {"X-Auth-Token": api_key}
params = {"season": 2026}

response = requests.get(url, headers=headers, params=params, timeout=30)
print("Status code:", response.status_code)

data = response.json()
print("Number of matches:", len(data.get("matches", [])))

with open("sample_matches.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)