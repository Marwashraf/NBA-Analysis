🏀 NBA Data Analytics Project
This project presents a complete data warehousing and analytics solution for historical NBA data. The original dataset was extracted from a SQLite database sourced from Kaggle – NBA Database by Wyatt Walsh, cleaned, and transformed into a structured Star Schema data warehouse using SQL Server. The final model supports high-performance analytical queries and interactive dashboards in Power BI.

📊 Original Dataset (Kaggle)
Source: NBA Database on Kaggle
https://www.kaggle.com/datasets/wyattowalsh/basketball

Scope: 65,000+ games (1946–47 to present), 4,800+ players, 30 teams

Contents: Box scores for 95%+ of games, 13M+ play-by-play rows, draft history, combine stats, and more

Format: SQLite database (nba.sqlite)l

🔧 Key Components
Data Cleaning & Integration

Resolved data type inconsistencies, duplicate records, and missing foreign key references.

Added placeholder records in dimension tables to preserve fact table integrity.

Data Warehouse Design (Star Schema)

Fact Tables: Fact_Game, Fact_Draft, Fact_Combine

Dimension Tables: Dim_Player, Dim_Team, Dim_Date, Dim_Game_Info

Established primary and foreign key relationships for consistent reporting.

SQL Analytics

Game performance (home/away win %, point differentials, close games)

Team efficiency (offensive/defensive rankings, clutch performance)

Season trends (scoring, assists, rebounds over time)

Player combine metrics (vertical jump, sprint speed, BMI analysis)

Power BI Dashboard Insights

58,000+ games analyzed | 12M total points

Home win percentage: 61.95% | Away: 38.05%

Top scoring franchises: Celtics, Warriors, Lakers, 76ers, Knicks

Draft analytics: 3,506 picks | Avg draft position: 30.78

Combine metrics & historical scoring trends (1946–1965)


├── Database/           # Cleaned dataset (sample or schema only)
├── DWH/                # Queries for insights & warehouse creation
├── Power BI/           # Dashboard file (.pbix)              
└── README.md

🚀 Getting Started
Clone the repo

Import the provided SQL scripts into SQL Server

Connect Power BI to the data warehouse

Explore the dashboard and run analytical queries

📌 Tools Used
SQL Server (SSMS)

Power BI

SQLite (source)
