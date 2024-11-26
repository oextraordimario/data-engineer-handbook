WITH deduped AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY player_id, game_id) AS "row_num"
	FROM game_details
),
filtered AS (
	SELECT * FROM deduped WHERE row_num = 1
)
SELECT
	f1.player_name,
	f2.player_name,
	f1.team_abbreviation,
	f2.team_abbreviation
FROM filtered f1
JOIN filtered f2
	ON f1.game_id = f2.game_id
	AND f1.player_name != f2.player_name
	-- 31:25

SELECT
	v.properties->>'player_name',
	MAX(CAST(e.properties->>'pts' AS INT))
FROM vertices v 
JOIN edges e
	ON e.subject_identifier = v.identifier
	AND e.subject_type = v.type
GROUP BY 1