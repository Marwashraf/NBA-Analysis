SELECT game_id, COUNT(*) AS count
FROM game
GROUP BY game_id
HAVING COUNT(*) > 1;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   game_id,
                   game_date,
                   team_id_home,
                   team_id_away,
                   pts_home,
                   pts_away
               ORDER BY game_id
           ) AS rn
    FROM game
)
DELETE FROM CTE
WHERE rn > 1;

SELECT game_id, COUNT(*)
FROM game
GROUP BY game_id
HAVING COUNT(*) > 1;



SELECT game_id, COUNT(*) AS count
FROM game_info
GROUP BY game_id
HAVING COUNT(*) > 1;

SELECT *
FROM game_info
WHERE game_id = 35800001;


WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY game_id
               ORDER BY game_id
           ) AS rn
    FROM game_info
)
DELETE FROM CTE
WHERE rn > 1;

SELECT game_id, COUNT(*)
FROM game_info
GROUP BY game_id
HAVING COUNT(*) > 1;



SELECT game_id, COUNT(*) AS count
FROM other_stats
GROUP BY game_id
HAVING COUNT(*) > 1;


SELECT *
FROM other_stats
WHERE game_id = 39600001;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY game_id
               ORDER BY game_id
           ) AS rn
    FROM other_stats
)
DELETE FROM CTE
WHERE rn > 1;



SELECT game_id, COUNT(*) AS count
FROM [dbo].[game_summary]
GROUP BY game_id
HAVING COUNT(*) > 1;


SELECT *
FROM [dbo].[game_summary]
WHERE game_id = 35800001;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY game_id
               ORDER BY game_id
           ) AS rn
    FROM [dbo].[game_summary]
)
DELETE FROM CTE
WHERE rn > 1;



WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY game_id, official_id
               ORDER BY game_id
           ) AS rn
    FROM officials
)
DELETE FROM CTE
WHERE rn > 1;


WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY game_id, [player_id]
               ORDER BY game_id
           ) AS rn
    FROM [dbo].[inactive_players]
)
DELETE FROM CTE
WHERE rn > 1;



SELECT DISTINCT team_id_home
FROM game
WHERE team_id_home NOT IN (SELECT id FROM team);


SELECT COUNT(*)
FROM game
WHERE team_id_home NOT IN (SELECT id FROM team);


INSERT INTO team (id, full_name)
SELECT DISTINCT team_id_home, 'Unknown Team'
FROM game
WHERE team_id_home NOT IN (SELECT id FROM team);


SELECT DISTINCT player_id
FROM inactive_players
WHERE player_id NOT IN (SELECT id FROM player);


ALTER TABLE team
ADD CONSTRAINT DF_team_year_founded
DEFAULT 2000 FOR year_founded;

ALTER TABLE team
ADD CONSTRAINT DF_team_nickname DEFAULT 'Unknown' FOR nickname;

ALTER TABLE team
ADD CONSTRAINT DF_team_city DEFAULT 'Unknown' FOR city;

ALTER TABLE team
ADD CONSTRAINT DF_team_state DEFAULT 'Unknown' FOR state;


INSERT INTO team (id, full_name, abbreviation)
SELECT 
    g.team_id_home,
    MAX(g.team_name_home),
    MAX(g.team_abbreviation_home)
FROM game g
WHERE g.team_id_home NOT IN (SELECT id FROM team)
GROUP BY g.team_id_home;


INSERT INTO team (id, full_name, abbreviation)
SELECT 
    t.team_id,
    MAX(t.team_name),
    MAX(t.team_abbreviation)
FROM (
    SELECT team_id_home AS team_id, team_name_home AS team_name, team_abbreviation_home AS team_abbreviation FROM game
    UNION
    SELECT team_id_away, team_name_away, team_abbreviation_away FROM game
) t
WHERE t.team_id NOT IN (SELECT id FROM team)
GROUP BY t.team_id;

UPDATE t
SET t.nickname = c.team_name
FROM team t
JOIN common_player_info c
    ON t.id = c.team_id
WHERE t.nickname = 'Unknown';


UPDATE t
SET t.city = c.team_city
FROM team t
JOIN (
    SELECT team_id, MAX(team_city) AS team_city
    FROM common_player_info
    GROUP BY team_id
) c
ON t.id = c.team_id
WHERE t.city = 'Unknown';



INSERT INTO team (id, full_name, nickname, abbreviation, city)
SELECT 
    c.team_id,
    ISNULL(MAX(c.team_name), 'Unknown'),
    ISNULL(MAX(c.team_name), 'Unknown'),
    ISNULL(MAX(c.team_abbreviation), 'UNK'),
    ISNULL(MAX(c.team_city), 'Unknown')
FROM common_player_info c
WHERE c.team_id NOT IN (SELECT id FROM team)
GROUP BY c.team_id;


SELECT DISTINCT player_id
FROM inactive_players
WHERE player_id NOT IN (SELECT id FROM player);


INSERT INTO player (id, full_name, first_name, last_name, is_active)
SELECT 
    c.player_id,
    MAX(ISNULL(c.first_name, '') + ' ' + ISNULL(c.last_name, '')),
    MAX(ISNULL(c.first_name, 'Unknown')),
    MAX(ISNULL(c.last_name, 'Unknown')),
    0
FROM inactive_players c
WHERE c.player_id IN (
    SELECT player_id
    FROM inactive_players
    WHERE player_id NOT IN (SELECT id FROM player)
)
GROUP BY c.player_id;


SELECT DISTINCT [person_id]
FROM [dbo].[draft_history]
WHERE  [person_id]NOT IN (SELECT id FROM player);


SELECT *
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('inactive_players');


SELECT DISTINCT [player_id]
FROM  [dbo].[draft_combine_stats]
WHERE [player_id] NOT IN (SELECT id FROM player);