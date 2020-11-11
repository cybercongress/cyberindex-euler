CREATE TABLE object
(
    id SERIAL PRIMARY KEY,
    object VARCHAR(256) NOT NULL,
    subject CHAR(44) NOT NULL,
    timestamp timestamp without time zone NOT NULL,
    height integer NOT NULL REFERENCES block(height),
    txhash CHAR(64) NOT NULL REFERENCES transaction(txhash)
);