CREATE OR REPLACE VIEW marts.points_progression AS

WITH league_matches AS (
    SELECT
        matchday,
        kickoff_madrid :: DATE AS match_date,
        opponent,
        venue,
        result,
        CASE result WHEN 'W' THEN 3 WHEN 'D' THEN 1 ELSE 0 END AS points

    FROM staging.stg_barca_matches
    
    WHERE competition = 'Primera Division'
      AND status = 'FINISHED'
)

SELECT *,
    SUM(points) OVER (ORDER BY matchday) AS cumulative_points
FROM league_matches;