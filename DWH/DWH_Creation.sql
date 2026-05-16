CREATE DATABASE NBA_DW;
GO
USE NBA_DW;
GO


CREATE TABLE Dim_Date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_name NVARCHAR(20)
);


INSERT INTO Dim_Date
SELECT DISTINCT 
    game_date,
    YEAR(game_date),
    DATEPART(QUARTER, game_date),
    MONTH(game_date),
    DAY(game_date),
    DATENAME(WEEKDAY, game_date)
FROM NBA_DB.dbo.game;



CREATE TABLE Dim_Player (
    player_id INT PRIMARY KEY,
    full_name NVARCHAR(100),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    is_active BIT
);


INSERT INTO Dim_Player
SELECT id, full_name, first_name, last_name, is_active
FROM NBA_DB.dbo.player;


CREATE TABLE Dim_Team (
    team_id INT PRIMARY KEY,
    team_name NVARCHAR(100),
    city NVARCHAR(100),
    abbreviation NVARCHAR(10),
    arena NVARCHAR(100),
    capacity INT,
    year_founded INT
);



INSERT INTO Dim_Team
SELECT 
    t.id,
    t.full_name,
    t.city,
    t.abbreviation,
    td.arena,
    td.arenacapacity,
    t.year_founded
FROM NBA_DB.dbo.team t
LEFT JOIN NBA_DB.dbo.team_details td
ON t.id = td.team_id;


CREATE TABLE Dim_Game_Info (
    game_id BIGINT PRIMARY KEY,
    game_date DATE,
    attendance INT,
    game_time NVARCHAR(50)
);


INSERT INTO Dim_Game_Info
SELECT game_id, game_date, attendance, game_time
FROM NBA_DB.dbo.game_info;


CREATE TABLE Fact_Game (
    game_id BIGINT PRIMARY KEY,
    date_id INT,
    home_team_id INT,
    away_team_id INT,

    pts_home INT,
    pts_away INT,

    fg_pct_home FLOAT,
    fg_pct_away FLOAT,

    ast_home INT,
    ast_away INT,

    reb_home INT,
    reb_away INT,

    stl_home INT,
    stl_away INT,

    blk_home INT,
    blk_away INT,

    tov_home INT,
    tov_away INT,

    FOREIGN KEY (date_id) REFERENCES Dim_Date(date_id)
);




CREATE TABLE Fact_Draft (
    draft_id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT,
    season INT,
    overall_pick INT,
    team_id INT
);



CREATE TABLE Fact_Combine (
    player_id INT,
    season INT,
    height FLOAT,
    weight FLOAT,
    wingspan FLOAT,
    vertical_leap FLOAT,
    sprint FLOAT
);



INSERT INTO Fact_Game
SELECT 
    g.game_id,
    d.date_id,
    g.team_id_home,
    g.team_id_away,

    g.pts_home,
    g.pts_away,

    g.fg_pct_home,
    g.fg_pct_away,

    g.ast_home,
    g.ast_away,

    g.reb_home,
    g.reb_away,

    g.stl_home,
    g.stl_away,

    g.blk_home,
    g.blk_away,

    g.tov_home,
    g.tov_away

FROM NBA_DB.dbo.game g
JOIN Dim_Date d ON g.game_date = d.full_date;




INSERT INTO Fact_Draft
SELECT 
    person_id,
    season,
    overall_pick,
    team_id
FROM NBA_DB.dbo.draft_history;




INSERT INTO Fact_Combine
SELECT 
    player_id,
    season,
    height_w_shoes,
    weight,
    wingspan,
    max_vertical_leap,
    three_quarter_sprint
FROM NBA_DB.dbo.draft_combine_stats;





-- Remove NULL records
DELETE FROM Fact_Game WHERE pts_home IS NULL;

-- Check duplicates
SELECT game_id, COUNT(*)
FROM Fact_Game
GROUP BY game_id
HAVING COUNT(*) > 1;



-- Best Offensive Teams

SELECT 
    dt.team_name,
    AVG(fg.pts_home) AS avg_points
FROM Fact_Game fg
JOIN Dim_Team dt ON fg.home_team_id = dt.team_id
GROUP BY dt.team_name
ORDER BY avg_points DESC;


-- Best Defensive Teams

SELECT 
    dt.team_name,
    AVG(fg.pts_away) AS avg_points_allowed
FROM Fact_Game fg
JOIN Dim_Team dt ON fg.home_team_id = dt.team_id
GROUP BY dt.team_name
ORDER BY avg_points_allowed ASC;



-- Home Advantage

SELECT 
    COUNT(CASE WHEN pts_home > pts_away THEN 1 END) AS home_wins,
    COUNT(CASE WHEN pts_away > pts_home THEN 1 END) AS away_wins
FROM Fact_Game;


-- Shooting Impact
SELECT 
    CASE WHEN pts_home > pts_away THEN 'Win' ELSE 'Loss' END AS result,
    AVG(fg_pct_home) AS avg_fg
FROM Fact_Game
GROUP BY CASE WHEN pts_home > pts_away THEN 'Win' ELSE 'Loss' END;


-- Most Consistent Teams

SELECT 
    dt.team_name,
    STDEV(pts_home) AS variance
FROM Fact_Game fg
JOIN Dim_Team dt ON fg.home_team_id = dt.team_id
GROUP BY dt.team_name
ORDER BY variance ASC;


-- Biggest Wins

SELECT TOP 10
    game_id,
    ABS(pts_home - pts_away) AS margin
FROM Fact_Game
ORDER BY margin DESC;


-- Combine Insights
SELECT 
    AVG(height) AS avg_height,
    AVG(weight) AS avg_weight,
    AVG(wingspan) AS avg_wingspan
FROM Fact_Combine;



-- Draft Analysis

SELECT 
    overall_pick,
    COUNT(*) AS players
FROM Fact_Draft
GROUP BY overall_pick
ORDER BY overall_pick;



-- Fastest Players

SELECT TOP 10 *
FROM Fact_Combine
ORDER BY sprint ASC;

-- Attendance Trend

SELECT 
    YEAR(game_date) AS year,
    AVG(attendance) AS avg_attendance
FROM Dim_Game_Info
GROUP BY YEAR(game_date)
ORDER BY year;


WITH TeamStats AS (
    SELECT home_team_id, AVG(pts_home) avg_pts
    FROM Fact_Game
    GROUP BY home_team_id
)
SELECT * FROM TeamStats WHERE avg_pts > 100;


SELECT 
    game_id,
    pts_home,
    RANK() OVER (ORDER BY pts_home DESC) AS rank_points
FROM Fact_Game;



SELECT 
    game_id,
    pts_home,
    SUM(pts_home) OVER (ORDER BY game_id) AS running_total
FROM Fact_Game;