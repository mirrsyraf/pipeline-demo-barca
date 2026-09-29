CREATE OR REPLACE VIEW marts.home_vs_away AS

SELECT
    venue,
    COUNT(*)                                                                        AS played,
    COUNT(*) FILTER (WHERE result = 'W')                                            AS wins,
    ROUND(100.0 * COUNT(*) FILTER (WHERE result = 'W') / NULLIF(COUNT(*), 0), 1)    AS win_rate_pct,
    ROUND(AVG(goals_for), 2)                                                        AS avg_goals_scored,
    ROUND(AVG(goals_against), 2)                                                    AS avg_goals_conceded
FROM staging.stg_barca_matches

WHERE status = 'FINISHED'
GROUP BY venue;