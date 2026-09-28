CREATE OR REPLACE VIEW marts.form_guide AS

SELECT STRING_AGG (result, '' ORDER BY kickoff_madrid)  AS last_5_results
FROM(
    SELECT result, kickoff_madrid
    FROM staging.stg_barca_matches
    WHERE status = 'FINISHED'
    ORDER BY kickoff_madrid DESC
    LIMIT 5
)                                                       AS recent;