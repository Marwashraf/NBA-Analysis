-- ==========================================
-- 1. Database
-- ==========================================
CREATE DATABASE NBA_DW;
GO
USE NBA_DW;
GO

-- ==========================================
-- 2. Dimension Tables
-- ==========================================

-- Dim_Date
CREATE TABLE Dim_Date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_name NVARCHAR(20),
	season_type NVARCHAR(50)
);
ADD ;
-- Dim_Player
CREATE TABLE Dim_Player (
    player_id INT PRIMARY KEY,
    full_name NVARCHAR(100),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    is_active BIT
);

-- Dim_Team
CREATE TABLE Dim_Team (
    team_id INT PRIMARY KEY,
    team_name NVARCHAR(100),
    city NVARCHAR(100),
    abbreviation NVARCHAR(10),
    arena NVARCHAR(100),
    capacity INT,
    year_founded INT
);

-- Dim_Game_Info
CREATE TABLE Dim_Game_Info (
    game_id BIGINT PRIMARY KEY,
    game_date DATE,
    attendance INT,
    game_time NVARCHAR(50),
    date_id INT,
    FOREIGN KEY (date_id) REFERENCES Dim_Date(date_id)
);

-- ==========================================
-- 3. Fact Tables
-- ==========================================

-- Fact_Game: store game stats
CREATE TABLE Fact_Game (
    fact_game_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    game_id BIGINT NOT NULL,
    date_id INT NOT NULL,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,

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

    FOREIGN KEY (game_id) REFERENCES Dim_Game_Info(game_id),
    FOREIGN KEY (date_id) REFERENCES Dim_Date(date_id),
    FOREIGN KEY (home_team_id) REFERENCES Dim_Team(team_id),
    FOREIGN KEY (away_team_id) REFERENCES Dim_Team(team_id)
);

-- Fact_Draft: draft information
CREATE TABLE Fact_Draft (
    draft_id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    season INT,
    overall_pick INT,
    team_id INT NOT NULL,
    FOREIGN KEY (player_id) REFERENCES Dim_Player(player_id),
    FOREIGN KEY (team_id) REFERENCES Dim_Team(team_id)
);

-- Fact_Combine: player combine measurements
CREATE TABLE Fact_Combine (
    combine_id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    season INT,
    height FLOAT,
    weight FLOAT,
    wingspan FLOAT,
    vertical_leap FLOAT,
    sprint FLOAT,
    FOREIGN KEY (player_id) REFERENCES Dim_Player(player_id)
);


INSERT INTO Dim_Date
SELECT DISTINCT 
    game_date,
    YEAR(game_date),
    DATEPART(QUARTER, game_date),
    MONTH(game_date),
    DAY(game_date),
    DATENAME(WEEKDAY, game_date),
	season_type 
FROM NBA_DB.dbo.game;


truncate table Dim_Player

INSERT INTO Dim_Player
SELECT DISTINCT id, full_name, first_name, last_name, is_active
FROM NBA_DB.dbo.player;


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



INSERT INTO Dim_Game_Info (game_id, game_date, attendance, game_time)
SELECT game_id, game_date, attendance, game_time
FROM NBA_DB.dbo.game_info;

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
JOIN Dim_Date d ON g.game_date = d.full_date
JOIN Dim_Game_Info gi ON g.game_id = gi.game_id;


INSERT INTO Fact_Draft (player_id, season, overall_pick, team_id)
SELECT 
    d.person_id,
    d.season,
    d.overall_pick,
    d.team_id
FROM NBA_DB.dbo.draft_history d
JOIN Dim_Player p ON d.person_id = p.player_id;


INSERT INTO Fact_Combine (player_id, season, height,weight, wingspan,vertical_leap,sprint)
SELECT 
    d.player_id,
    d.season,
    d.height_w_shoes,
    d.weight,
    d.wingspan,
    d.max_vertical_leap,
    d.three_quarter_sprint
FROM NBA_DB.dbo.draft_combine_stats d
JOIN Dim_Player p ON d.player_id = p.player_id;


