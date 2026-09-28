CREATE SCHEMA IF NOT EXISTS marts;

CREATE OR REPLACE VIEW marts.season_summary AS

SELECT
    COALESCE(competition, 'All competitions')                                       AS competition,
    COUNT(*)                                                                        AS played,
    COUNT(*) FILTER (WHERE result = 'W')                                            AS wins,
    COUNT(*) FILTER (WHERE result = 'D')                                            AS draws,
    COUNT(*) FILTER (WHERE result = 'L')                                            AS losses,
    ROUND(100.0 * COUNT(*) FILTER (WHERE result = 'W') / NULLIF (COUNT(*), 0), 1)   AS win_rate_pct,

    SUM(goals_for)                                                                  AS goals_for,
    SUM(goals_against)                                                              AS goals_against,
    SUM(goals_for - goals_against)                                                  AS goals_difference,
    COUNT(*) FILTER (WHERE goals_against = 0)                                       AS clean_sheets
FROM staging.stg_barca_matches

WHERE status = 'FINISHED'
GROUP BY ROLLUP (competition);
