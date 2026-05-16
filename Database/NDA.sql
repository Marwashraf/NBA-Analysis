CREATE DATABASE NBA_DW;
GO

USE NBA_DW;
GO


-----Dim Date
CREATE TABLE Dim_Date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT,
    season VARCHAR(10)
);

------ Dim Team
CREATE TABLE Dim_Team (
    team_key INT IDENTITY(1,1) PRIMARY KEY,
    team_id INT,
    team_name VARCHAR(100),
    abbreviation VARCHAR(10),
    city VARCHAR(50),
    state VARCHAR(50),
    year_founded INT
);

------Dim Player 
CREATE TABLE Dim_Player (
    player_key INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT,
    full_name VARCHAR(100),
    position VARCHAR(10),
    height VARCHAR(10),
    weight FLOAT,
    country VARCHAR(50)
);


-------Dim Game 
CREATE TABLE Dim_Game (
    game_key INT IDENTITY(1,1) PRIMARY KEY,
    game_id VARCHAR(20),
    season VARCHAR(10),
    game_date DATE,
    matchup VARCHAR(100)
);


----------Fact 1
CREATE TABLE Fact_Player_Game (
    fact_key INT IDENTITY(1,1) PRIMARY KEY,

    game_key INT,
    player_key INT,
    team_key INT,
    date_key INT,

    minutes FLOAT,
    points INT,
    rebounds INT,
    assists INT,
    steals INT,
    blocks INT,
    turnovers INT,
    fg_pct FLOAT,
    fg3_pct FLOAT,
    ft_pct FLOAT,

    FOREIGN KEY (game_key) REFERENCES Dim_Game(game_key),
    FOREIGN KEY (player_key) REFERENCES Dim_Player(player_key),
    FOREIGN KEY (team_key) REFERENCES Dim_Team(team_key),
    FOREIGN KEY (date_key) REFERENCES Dim_Date(date_key)
);


-----dim_arena
CREATE TABLE dim_arena (
    arena_key INT IDENTITY PRIMARY KEY,
    arena_name VARCHAR(100),
    city VARCHAR(50),
    capacity INT
);


----- OFFcial 
CREATE TABLE dim_official (
    official_key INT IDENTITY PRIMARY KEY,
    official_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

-----Draft
CREATE TABLE dim_draft (
    draft_key INT IDENTITY PRIMARY KEY,
    season INT,
    round_number INT,
    overall_pick INT
);

------
CREATE TABLE fact_games (
    fact_id INT IDENTITY PRIMARY KEY,

    game_key INT NOT NULL,
    date_id INT NOT NULL,

    home_team_key INT NOT NULL,
    away_team_key INT NOT NULL,

    pts_home INT,
    pts_away INT,

    -- Relationships
    CONSTRAINT fk_fg_game FOREIGN KEY (game_key) 
        REFERENCES dim_game(game_key),

    CONSTRAINT fk_fg_date FOREIGN KEY (date_id) 
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_fg_home_team FOREIGN KEY (home_team_key) 
        REFERENCES dim_team(team_key),

    CONSTRAINT fk_fg_away_team FOREIGN KEY (away_team_key) 
        REFERENCES dim_team(team_key)
);


CREATE TABLE fact_draft (
    fact_id INT IDENTITY PRIMARY KEY,

    player_key INT NOT NULL,
    team_key INT NOT NULL,
    draft_key INT NOT NULL,

    -- Relationships
    CONSTRAINT fk_fd_player FOREIGN KEY (player_key)
        REFERENCES dim_player(player_key),

    CONSTRAINT fk_fd_team FOREIGN KEY (team_key)
        REFERENCES dim_team(team_key),

    CONSTRAINT fk_fd_draft FOREIGN KEY (draft_key)
        REFERENCES dim_draft(draft_key)
);


CREATE TABLE fact_draft (
    fact_id INT IDENTITY PRIMARY KEY,

    player_key INT NOT NULL,
    team_key INT NOT NULL,
    draft_key INT NOT NULL,

    -- Relationships
    CONSTRAINT fk_fd_player FOREIGN KEY (player_key)
        REFERENCES dim_player(player_key),

    CONSTRAINT fk_fd_team FOREIGN KEY (team_key)
        REFERENCES dim_team(team_key),

    CONSTRAINT fk_fd_draft FOREIGN KEY (draft_key)
        REFERENCES dim_draft(draft_key)
);


CREATE TABLE fact_game_events (
    fact_id INT IDENTITY PRIMARY KEY,

    game_key INT NOT NULL,

    lead_changes INT,
    times_tied INT,

    CONSTRAINT fk_fge_game FOREIGN KEY (game_key)
        REFERENCES dim_game(game_key)
);


CREATE TABLE fact_combine (
    fact_id INT IDENTITY PRIMARY KEY,

    player_key INT NOT NULL,

    height FLOAT,
    weight FLOAT,
    wingspan FLOAT,
    vertical_jump FLOAT,

    CONSTRAINT fk_fc_player FOREIGN KEY (player_key)
        REFERENCES dim_player(player_key)
);



