CREATE TABLE comm_pool
(
    subject CHAR(44) NOT NULL UNIQUE PRIMARY KEY,
    cybs NUMERIC
);

CREATE TABLE takeoff
(
    timestamps timestamp without time zone,
    donors CHAR(45),
    donates REAL,
    cumsum REAL,
    a_cybs REAL,
    cybs REAL,
    price REAL
);

CREATE TABLE takeoff_leaderboard
(
    donors CHAR(44) NOT NULL UNIQUE PRIMARY KEY,
    cybs NUMERIC
);