CREATE SCHEMA IF NOT EXISTS staging;

CREATE OR REPLACE VIEW staging.stg_barca_matches AS
WITH latest AS (
	SELECT payload
	FROM raw.api_responses
	WHERE endpoint = 'team_matches'
	ORDER BY extracted_at DESC
	LIMIT 1
),

matches AS (
	SELECT jsonb_array_elements(payload -> 'matches') AS m
	FROM latest
)

SELECT 
	(m ->> 'id'):: INT												AS match_id,
	m -> 'competition' ->> 'name'									AS competition,
	(m ->> 'matchday') :: INT										AS matchday,
	((m ->> 'utcDate') :: TIMESTAMPTZ AT TIME ZONE 'Europe/Madrid')	AS kickoff_madrid,
	m ->> 'status'													AS status,

	CASE WHEN (m -> 'homeTeam' ->> 'id') :: INT = 81
		 THEN 'Home' ELSE 'Away' END								AS venue,

	 CASE WHEN (m -> 'homeTeam' ->> 'id')::INT = 81
         THEN m -> 'awayTeam' ->> 'shortName'
         ELSE m -> 'homeTeam' ->> 'shortName' END                  AS opponent,

    CASE WHEN (m -> 'homeTeam' ->> 'id')::INT = 81
         THEN (m -> 'score' -> 'fullTime' ->> 'home')::INT
         ELSE (m -> 'score' -> 'fullTime' ->> 'away')::INT END     AS goals_for,

    CASE WHEN (m -> 'homeTeam' ->> 'id')::INT = 81
         THEN (m -> 'score' -> 'fullTime' ->> 'away')::INT
         ELSE (m -> 'score' -> 'fullTime' ->> 'home')::INT END     AS goals_against,

	CASE WHEN m ->> 'status' <> 'FINISHED' 				THEN NULL
		 WHEN m -> 'score' ->> 'winner' = 'DRAW' 		THEN 'D'
		 WHEN (m -> 'score' ->> 'winner' = 'HOME_TEAM')
		 	= ((m -> 'homeTeam' ->> 'id') :: INT = 81) 	THEN 'W'
		 ELSE 'L'
	END															   AS result
FROM matches;
