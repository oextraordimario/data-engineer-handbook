/**
SELECT * FROM player_seasons LIMIT 10

CREATE TYPE season_stats AS (
	season INT,
	gp INT,
	pts REAL,
	reb REAL,
	ast REAL
)

CREATE TYPE scoring_class AS ENUM('star', 'good', 'average', 'bad')

CREATE TABLE players(
	player_name TEXT,
	height TEXT,
	college TEXT,
	country TEXT,
	draft_year TEXT,
	draft_round TEXT,
	draft_number TEXT,
	season_stats season_stats[],
	scoring_class scoring_class,
	years_since_last_season INT,
	current_season INT,
	PRIMARY KEY(player_name, current_season)
)
**/

INSERT INTO players
WITH yesterday AS (
	SELECT *
	FROM players
	WHERE current_season = 1995
),
today AS (
	SELECT *
	FROM player_seasons
	WHERE season = 1996
)
SELECT
	COALESCE(today.player_name, yesterday.player_name) AS "player_name",
	COALESCE(today.height, yesterday.height) AS "height",
	COALESCE(today.college, yesterday.college) AS "college",
	COALESCE(today.country, yesterday.country) AS "country",
	COALESCE(today.draft_year, yesterday.draft_year) AS "draft_year",
	COALESCE(today.draft_round, yesterday.draft_round) AS "draft_round",
	COALESCE(today.draft_number, yesterday.draft_number) AS "draft_number",
	CASE
		WHEN yesterday.season_stats IS NULL THEN ARRAY[ROW(
			today.season,
			today.gp,
			today.pts,
			today.reb,
			today.ast
			)::season_stats]
		WHEN today.season IS NOT NULL THEN yesterday.season_stats || ARRAY[ROW(
			today.season,
			today.gp,
			today.pts,
			today.reb,
			today.ast
			)::season_stats]
		ELSE yesterday.season_stats
		END AS "season_stats",
	CASE
		WHEN today.season IS NOT NULL THEN
		CASE
			WHEN today.pts > 20 THEN 'star'
			WHEN today.pts > 15 THEN 'good'
			WHEN today.pts > 10 THEN 'average'
			ELSE 'bad'
			END::scoring_class
		ELSE yesterday.scoring_class
		END AS "scoring_class",
	CASE
		WHEN today.season IS NOT NULL THEN 0
		ELSE yesterday.years_since_last_season + 1
		END AS "years_since_last_season",
	COALESCE(today.season, yesterday.current_season + 1) AS "current_season"
FROM today 
FULL OUTER JOIN yesterday
ON today.player_name = yesterday.player_name


