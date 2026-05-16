--Total Games
SELECT COUNT(DISTINCT game_id ) AS Total_Games
FROM fact_game;

-- Total Points
SELECT SUM(pts_home + pts_away) AS Total_Points
FROM fact_game;


-- Avg Points (Home / Away)

SELECT 
    AVG(pts_home) AS Avg_Home_Points,
    AVG(pts_away) AS Avg_Away_Points
FROM fact_game;


-- Home Win % vs Away Win %

SELECT 
    SUM(CASE WHEN pts_home > pts_away THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Home_Win_Percentage,
    SUM(CASE WHEN pts_away > pts_home THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Away_Win_Percentage
FROM fact_game;

-- Points by Team (Top Teams)
SELECT 
    t.team_name,
    SUM(CASE 
            WHEN fg.home_team_id = t.team_id THEN pts_home
            WHEN fg.away_team_id = t.team_id THEN pts_away
        END) AS Total_Points
FROM fact_game fg
JOIN dim_team t 
    ON t.team_id IN (fg.home_team_id, fg.away_team_id)
GROUP BY t.team_name
ORDER BY Total_Points DESC;


-- Average Points per Team
SELECT 
    AVG(fg.pts_home) AS avg_home_points,
    AVG(fg.pts_away) AS avg_away_points,
    AVG((fg.pts_home + fg.pts_away)/2) AS avg_team_points,
    AVG(ABS(fg.pts_home - fg.pts_away)) AS avg_point_difference
FROM fact_game fg;


-- FG% by Team (from player stats)

SELECT 
    t.team_name,
    AVG(fg.fact_game_id) * 100 AS Avg_FG_Percentage
FROM Fact_Game fg
full JOIN dim_team t ON fg.fact_game_id = t.team_id
GROUP BY t.team_name
ORDER BY Avg_FG_Percentage DESC;



-- Assists vs Rebounds Over Years
SELECT 
    d.year,
    SUM(f.assists) AS Total_Assists,
    SUM(f.rebounds) AS Total_Rebounds
FROM Fact_Game f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;


-- Total Teams
SELECT COUNT(*) AS Total_Teams
FROM dim_team;

-- Avg Points Per Game
SELECT AVG(pts_home + pts_away) AS Avg_Points_Per_Game
FROM fact_game;

-- Avg Team Points vs Opponent
SELECT 
    AVG(pts_home) AS Avg_Team_Points,
    AVG(pts_away) AS Avg_Opponent_Points
FROM fact_game;

-- Avg Point Difference
SELECT AVG(ABS(pts_home - pts_away)) AS Avg_Point_Difference
FROM fact_game;


--Home Advantage %
SELECT 
    SUM(CASE WHEN pts_home > pts_away THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Home_Advantage
FROM fact_game;

-- Teams Points Over Years
SELECT 
    d.year,
    SUM(pts_home + pts_away) AS Total_Points
FROM fact_game fg
JOIN dim_date d ON fg.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;


-- Teams Win Count
SELECT 
    t.team_name,
    SUM(CASE 
            WHEN fg.home_team_id = t.team_id AND pts_home > pts_away THEN 1
            WHEN fg.away_team_id = t.team_id AND pts_away > pts_home THEN 1
            ELSE 0
        END) AS Wins
FROM fact_game fg
JOIN dim_team t 
    ON t.team_id IN (fg.home_team_id, fg.away_team_id)
GROUP BY t.team_name
ORDER BY Wins DESC;



-- Home vs Away Performance per Team
SELECT 
    t.team_name,

    AVG(CASE WHEN fg.home_team_id= t.team_id THEN pts_home END) AS Avg_Home_Points,
    AVG(CASE WHEN fg.away_team_id = t.team_id THEN pts_away END) AS Avg_Away_Points

FROM fact_game fg
JOIN dim_team t 
    ON t.team_id IN (fg.home_team_id, fg.away_team_id)

GROUP BY t.team_name;





-- Max Vertical Jump
SELECT MAX(vertical_leap) AS Highest_Vertical
FROM fact_combine;


-- Height Distribution
SELECT 
    height,
    COUNT(*) AS Player_Count
FROM fact_combine
GROUP BY height
ORDER BY height;


-- Weight Distribution
SELECT 
    weight,
    COUNT(*) AS Player_Count
FROM fact_combine
GROUP BY weight
ORDER BY weight;


-- Vertical Jump by Player
SELECT 
    p.full_name,
    fc.vertical_leap
FROM fact_combine fc
JOIN Dim_Player p ON fc.player_id = p.player_id
ORDER BY fc.vertical_leap DESC;


--Fastest Sprint per Player
SELECT 
    p.full_name,
    fc.sprint
FROM fact_combine fc
JOIN dim_player p ON fc.player_id = p.player_id
ORDER BY fc.sprint ASC;


SELECT 
    CASE 
        WHEN height < 70 THEN 'Below 70'
        WHEN height BETWEEN 70 AND 75 THEN '70-75'
        WHEN height BETWEEN 76 AND 80 THEN '76-80'
        ELSE '80+'
    END AS Height_Range,
    
    ROUND(AVG(vertical_leap), 2) AS Avg_Vertical,
    ROUND(AVG(sprint), 2) AS Avg_Sprint

FROM fact_combine
GROUP BY 
    CASE 
        WHEN height < 70 THEN 'Below 70'
        WHEN height BETWEEN 70 AND 75 THEN '70-75'
        WHEN height BETWEEN 76 AND 80 THEN '76-80'
        ELSE '80+'
    END;



-- GAME PERFORMANCE OVERVIEW

-- Total Games + Points + Win %
SELECT 
    COUNT(*) AS Total_Games,
    SUM(pts_home + pts_away) AS Total_Points,
    ROUND(AVG(pts_home),2) AS Avg_Home_Points,
    ROUND(AVG(pts_away),2) AS Avg_Away_Points,
    ROUND(AVG(pts_home + pts_away),2) AS Avg_Points_Per_Game,
    ROUND(SUM(CASE WHEN pts_home > pts_away THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS Home_Win_Percentage,
    ROUND(SUM(CASE WHEN pts_away > pts_home THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS Away_Win_Percentage
FROM fact_game;


--  TEAM PERFORMANCE
  
-- Total Teams
SELECT COUNT(*) AS Total_Teams FROM dim_team;

-- Points by Team (Home + Away)
WITH team_points AS (
    SELECT home_team_id AS team_key, pts_home AS points FROM fact_game
    UNION ALL
    SELECT away_team_id, pts_away FROM fact_game
)
SELECT 
    t.team_name,
    SUM(tp.points) AS Total_Points
FROM team_points tp
JOIN dim_team t ON tp.team_key = t.team_id
GROUP BY t.team_name
ORDER BY Total_Points DESC;



-- Win Rate per Team
WITH team_results AS (
    SELECT 
        home_team_id AS team_key,
        CASE WHEN pts_home > pts_away THEN 1 ELSE 0 END AS win
    FROM fact_game
    UNION ALL
    SELECT 
        away_team_id,
        CASE WHEN pts_away > pts_home THEN 1 ELSE 0 END
    FROM fact_game
)
SELECT 
    t.team_name,
    COUNT(*) AS Total_Games,
    SUM(win) AS Wins,
    COUNT(*) - SUM(win) AS Losses,
    ROUND(SUM(win)*100.0/NULLIF(COUNT(*),0),2) AS Win_Percentage
FROM team_results tr
JOIN dim_team t ON tr.team_key = t.team_id
GROUP BY t.team_name
ORDER BY Win_Percentage DESC;




-- Home vs Away Points per Team
SELECT 
    t.team_name,
    ROUND(AVG(CASE WHEN fg.home_team_id = t.team_id THEN pts_home END),2) AS Avg_Home,
    ROUND(AVG(CASE WHEN fg.away_team_id = t.team_id THEN pts_away END),2) AS Avg_Away
FROM fact_game fg
JOIN dim_team t 
    ON t.team_id IN (fg.home_team_id, fg.away_team_id)
GROUP BY t.team_name;


-- SEASON TRENDS

-- Points Over Years
SELECT 
    d.year,
    SUM(fg.pts_home + fg.pts_away) AS Total_Points,
    ROUND(AVG(fg.pts_home + fg.pts_away),2) AS Avg_Points
FROM fact_game fg
JOIN dim_date d ON fg.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;

-- Assists vs Rebounds
-- Rebounds

SELECT 
    d.year,
    SUM(f.pts_home) AS Total_Rebounds_Home,
    SUM(f.pts_away) AS Total_Rebounds_Away
FROM fact_game f
JOIN dim_date d 
    ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;


-- Assists

SELECT 
    d.year,
    SUM(f.ast_home) AS Total_Assists_Home,
    SUM(f.ast_away) AS Total_Assists_Away
FROM fact_game f
JOIN dim_date d 
    ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;



--  SHOOTING PERFORMANCE

-- Away
SELECT 
    t.team_name,
    ROUND(AVG(fg.fg_pct_away)*100,2) AS Avg_FG_Percentage
FROM Fact_Game fg
JOIN Dim_Team t ON fg.away_team_id = t.team_id
GROUP BY t.team_name
ORDER BY Avg_FG_Percentage DESC;



-- Home
SELECT 
    t.team_name,
    ROUND(AVG(fg.fg_pct_home)*100,2) AS Avg_FG_Percentage
FROM Fact_Game fg
JOIN Dim_Team t ON fg.home_team_id = t.team_id
GROUP BY t.team_name
ORDER BY Avg_FG_Percentage DESC;

--COMBINE ANALYTICS

-- Key KPIs
SELECT 
    MAX(vertical_leap) AS Highest_Vertical,
    MIN(sprint) AS Fastest_Sprint,
    MAX(weight) AS Heaviest_Player,
    ROUND(AVG(weight / NULLIF(POWER(height/100.0,2),0)),2) AS Avg_BMI
FROM fact_combine;

-- Avg Draft Pick
SELECT ROUND(AVG(overall_pick),2) AS Avg_Draft_Pick
FROM Fact_Draft;


-- Height Distribution
SELECT 
    height,
    COUNT(*) AS Players_Count
FROM fact_combine
GROUP BY height
ORDER BY height;

-- Weight Distribution
SELECT 
    weight,
    COUNT(*) AS Players_Count
FROM fact_combine
GROUP BY weight
ORDER BY weight;


-- Vertical Jump by Player
SELECT 
    p.full_name,
    fc.vertical_leap
FROM fact_combine fc
JOIN dim_player p ON fc.player_id = p.player_id
ORDER BY fc.vertical_leap DESC;


-- Fastest Sprint by Player
SELECT 
    p.full_name,
    fc.sprint
FROM fact_combine fc
JOIN dim_player p ON fc.player_id = p.player_id
ORDER BY fc.sprint ASC;


-- Vertical vs Height Range
WITH height_groups AS (
    SELECT 
        CASE 
            WHEN height < 70 THEN 'Below 70'
            WHEN height BETWEEN 70 AND 75 THEN '70-75'
            WHEN height BETWEEN 76 AND 80 THEN '76-80'
            ELSE '80+'
        END AS Height_Range,
        vertical_leap,
        sprint
    FROM fact_combine
)
SELECT 
    Height_Range,
    ROUND(AVG(vertical_leap),2) AS Avg_Vertical,
    ROUND(AVG(sprint),2) AS Avg_Sprint
FROM height_groups
GROUP BY Height_Range;




   -- FULL TEAM SUMMARY
   

WITH team_stats AS (
    SELECT 
        t.team_name,
        COUNT(*) AS Games,
        SUM(CASE WHEN fg.home_team_id = t.team_id THEN pts_home ELSE pts_away END) AS Points_Scored,
        SUM(CASE WHEN fg.home_team_id = t.team_id THEN pts_away ELSE pts_home END) AS Points_Allowed,
        SUM(CASE 
            WHEN (fg.home_team_id = t.team_id AND pts_home > pts_away)
              OR (fg.away_team_id = t.team_id AND pts_away > pts_home)
            THEN 1 ELSE 0 END) AS Wins
    FROM fact_game fg
    JOIN dim_team t 
        ON t.team_id IN (fg.home_team_id, fg.away_team_id)
    GROUP BY t.team_name
)
SELECT 
    team_name,
    Games,
    Wins,
    Games - Wins AS Losses,
    ROUND(Wins*100.0/Games,2) AS Win_Percentage,
    Points_Scored,
    Points_Allowed,
    Points_Scored - Points_Allowed AS Point_Diff,
    ROUND(Points_Scored*1.0/Games,2) AS Avg_Scored,
    ROUND(Points_Allowed*1.0/Games,2) AS Avg_Allowed
FROM team_stats
ORDER BY Win_Percentage DESC;



--Top Teams Trend (Ranking Over Years)

WITH yearly_points AS (
    SELECT 
        d.year,
        t.team_name,
        SUM(CASE 
            WHEN fg.home_team_id = t.team_id THEN pts_home
            ELSE pts_away END) AS total_points
    FROM fact_game fg
    JOIN dim_date d ON fg.date_id = d.date_id
    JOIN dim_team t 
        ON t.team_id IN (fg.home_team_id, fg.away_team_id)
    GROUP BY d.year, t.team_name
)

SELECT *,
       RANK() OVER (PARTITION BY year ORDER BY total_points DESC) AS Rank_In_Year
FROM yearly_points;



-- Best Offensive vs Defensive Teams


WITH team_stats AS (
    SELECT 
        t.team_name,
        AVG(CASE WHEN fg.home_team_id = t.team_id THEN pts_home ELSE pts_away END) AS avg_scored,
        AVG(CASE WHEN fg.home_team_id = t.team_id THEN pts_away ELSE pts_home END) AS avg_allowed
    FROM fact_game fg
    JOIN dim_team t 
        ON t.team_id IN (fg.home_team_id, fg.away_team_id)
    GROUP BY t.team_name
)

SELECT *,
       RANK() OVER (ORDER BY avg_scored DESC) AS Offensive_Rank,
       RANK() OVER (ORDER BY avg_allowed ASC) AS Defensive_Rank
FROM team_stats;



-- Game Competitiveness (Close Games Analysis)


SELECT 
    COUNT(*) AS Total_Games,
    SUM(CASE WHEN ABS(pts_home - pts_away) <= 5 THEN 1 ELSE 0 END) AS Close_Games,
    ROUND(SUM(CASE WHEN ABS(pts_home - pts_away) <= 5 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS Close_Game_Percentage
FROM fact_game;



--  Clutch Teams (Performance in Close Games)

WITH close_games AS (
    SELECT *
    FROM fact_game
    WHERE ABS(pts_home - pts_away) <= 5
)

SELECT 
    t.team_name,
    SUM(CASE 
        WHEN (fg.home_team_id = t.team_id AND pts_home > pts_away)
          OR (fg.away_team_id = t.team_id AND pts_away > pts_home)
        THEN 1 ELSE 0 END) AS Close_Game_Wins
FROM close_games fg
JOIN dim_team t 
    ON t.team_id IN (fg.home_team_id, fg.away_team_id)
GROUP BY t.team_name
ORDER BY Close_Game_Wins DESC;




-- Home Advantage by Team

SELECT 
    t.team_name,
    ROUND(
        AVG(CASE WHEN fg.home_team_id = t.team_id THEN pts_home END) -
        AVG(CASE WHEN fg.away_team_id = t.team_id THEN pts_away END)
    ,2) AS Home_Advantage_Score
FROM fact_game fg
JOIN dim_team t 
    ON t.team_id IN (fg.home_team_id, fg.away_team_id)
GROUP BY t.team_name
ORDER BY Home_Advantage_Score DESC;



-- Most Improved Teams (Year over Year)


WITH yearly_perf AS (
    SELECT 
        d.year,
        t.team_name,
        AVG(CASE 
            WHEN fg.home_team_id = t.team_id THEN pts_home
            ELSE pts_away END) AS avg_points
    FROM fact_game fg
    JOIN dim_date d ON fg.date_id = d.date_id
    JOIN dim_team t 
        ON t.team_id IN (fg.home_team_id, fg.away_team_id)
    GROUP BY d.year, t.team_name
)

SELECT *,
       avg_points - LAG(avg_points) OVER (PARTITION BY team_name ORDER BY year) AS Improvement
FROM yearly_perf
ORDER BY Improvement DESC;


--Game Volatility (Scoring Variance)


SELECT 
    d.year,
    ROUND(VAR(pts_home + pts_away),2) AS Scoring_Variance
FROM fact_game fg
JOIN dim_date d ON fg.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;














-- Calculates each player's average total points and rebounds across all games, grouped by player and draft pick.


SELECT 
 p.full_name,
 fd.overall_pick,

 ROUND(AVG(fg.pts_home + fg.pts_away), 2) AS Avg_Total_Points,
 ROUND(AVG(fg.reb_home + fg.reb_away), 2) AS Avg_Total_Rebounds

FROM Fact_Draft fd

JOIN Dim_Player p 
 ON fd.player_id = p.player_id

JOIN Fact_Game fg 
 ON fd.team_id = fg.home_team_id 
 OR fd.team_id = fg.away_team_id

GROUP BY 
 p.full_name, 
 fd.overall_pick

ORDER BY fd.overall_pick ASC;



-- Computes each team's consistency in scoring by calculating the standard deviation of total points per game.
SELECT 
 t.team_name,
 ROUND(STDEV(fg.pts_home + fg.pts_away), 2) AS Points_Consistency
FROM Fact_Game fg
JOIN Dim_Team t 
 ON fg.home_team_id = t.team_id
GROUP BY t.team_name
ORDER BY Points_Consistency ASC;




-- Lists each team with the total number of drafted players and the average draft pick, ordered by best average pick.
SELECT 
 t.team_name,
 COUNT(*) AS total_players,
 AVG(fd.overall_pick) AS avg_pick
FROM Fact_Draft fd
JOIN Dim_Team t 
 ON fd.team_id = t.team_id
GROUP BY t.team_name
ORDER BY avg_pick ASC;



-- Calculates each team's overall game efficiency rating based on summed stats (points, rebounds, assists, steals, blocks minus turnovers), ordered from highest to lowest.

SELECT 
 t.team_name,

 ROUND(AVG(
 (fg.pts_home + fg.pts_away)
 + (fg.reb_home + fg.reb_away)
 + (fg.ast_home + fg.ast_away)
 + (fg.stl_home + fg.stl_away)
 + (fg.blk_home + fg.blk_away)
 - (fg.tov_home + fg.tov_away)
 ), 2) AS Efficiency_Rating

FROM Fact_Game fg

JOIN Dim_Team t 
 ON fg.home_team_id = t.team_id

GROUP BY t.team_name

ORDER BY Efficiency_Rating DESC;




-- Computes each team's average impact score by summing points, rebounds, assists, minus turnovers, ordered from highest to lowest.
SELECT 
 t.team_name,

 ROUND(AVG(
 (fg.pts_home + fg.pts_away)
 + (fg.reb_home + fg.reb_away)
 + (fg.ast_home + fg.ast_away)
 - (fg.tov_home + fg.tov_away)
 ), 2) AS Impact_Score

FROM Fact_Game fg

JOIN Dim_Team t 
 ON fg.home_team_id = t.team_id

GROUP BY t.team_name

ORDER BY Impact_Score DESC;




-- Calculates each team's average offensive (points) and defensive (steals + blocks) strength, ordered by offensive strength.

SELECT 
 t.team_name,

 ROUND(AVG(fg.pts_home + fg.pts_away),2) AS Offensive_Strength,
 ROUND(AVG(fg.stl_home + fg.stl_away + fg.blk_home + fg.blk_away),2) AS Defensive_Strength

FROM Fact_Game fg
JOIN Dim_Team t 
 ON fg.home_team_id = t.team_id

GROUP BY t.team_name
ORDER BY Offensive_Strength DESC;

