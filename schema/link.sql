CREATE TABLE link
(
    id SERIAL PRIMARY KEY,
    cid_from VARCHAR(256) NOT NULL,
    cid_to VARCHAR(256) NOT NULL,
    agent CHAR(44) NOT NULL,
    timestamp timestamp without time zone NOT NULL,
    height integer NOT NULL REFERENCES block(height),
    transaction CHAR(64) NOT NULL UNIQUE REFERENCES transaction(txhash)
);