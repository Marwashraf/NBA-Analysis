ALTER TABLE game
ADD CONSTRAINT PK_game PRIMARY KEY (game_id);

ALTER TABLE team
ADD CONSTRAINT PK_team PRIMARY KEY (id);

ALTER TABLE player
ADD CONSTRAINT PK_player PRIMARY KEY (id);

ALTER TABLE common_player_info
ADD CONSTRAINT PK_common_player PRIMARY KEY (person_id);

ALTER TABLE game_info
ADD CONSTRAINT PK_game_info PRIMARY KEY (game_id);

ALTER TABLE line_score
ADD CONSTRAINT PK_line_score PRIMARY KEY (game_id);

ALTER TABLE other_stats
ADD CONSTRAINT PK_other_stats PRIMARY KEY (game_id);

ALTER TABLE game_summary
ADD CONSTRAINT PK_game_summary PRIMARY KEY (game_id);

ALTER TABLE officials
ADD CONSTRAINT PK_officials PRIMARY KEY (game_id, official_id);

ALTER TABLE inactive_players
ADD CONSTRAINT PK_inactive PRIMARY KEY (game_id, player_id);

ALTER TABLE draft_history
ADD CONSTRAINT PK_draft PRIMARY KEY (person_id, season);


ALTER TABLE game
ADD CONSTRAINT FK_game_home_team
FOREIGN KEY (team_id_home) REFERENCES team(id);

ALTER TABLE game
ADD CONSTRAINT FK_game_away_team
FOREIGN KEY (team_id_away) REFERENCES team(id);


ALTER TABLE game_info
ADD CONSTRAINT FK_game_info
FOREIGN KEY (game_id) REFERENCES game(game_id);

ALTER TABLE game_summary
ADD CONSTRAINT FK_game_summary
FOREIGN KEY (game_id) REFERENCES game(game_id);

ALTER TABLE line_score
ADD CONSTRAINT FK_line_score
FOREIGN KEY (game_id) REFERENCES game(game_id);

ALTER TABLE other_stats
ADD CONSTRAINT FK_other_stats
FOREIGN KEY (game_id) REFERENCES game(game_id);


ALTER TABLE common_player_info
ADD CONSTRAINT FK_player_team
FOREIGN KEY (team_id) REFERENCES team(id);


ALTER TABLE inactive_players
ADD CONSTRAINT FK_inactive_game
FOREIGN KEY (game_id) REFERENCES game(game_id);

ALTER TABLE inactive_players
ADD CONSTRAINT FK_inactive_player
FOREIGN KEY (player_id) REFERENCES player(id);


ALTER TABLE officials
ADD CONSTRAINT FK_officials_game
FOREIGN KEY (game_id) REFERENCES game(game_id);


ALTER TABLE draft_history
ADD CONSTRAINT FK_draft_player
FOREIGN KEY (person_id) REFERENCES player(id);

ALTER TABLE draft_history
ADD CONSTRAINT FK_draft_player
FOREIGN KEY (person_id) REFERENCES player(id);

ALTER TABLE draft_history
ADD CONSTRAINT FK_draft_team
FOREIGN KEY (team_id) REFERENCES team(id);


SELECT COUNT(*) FROM game;

