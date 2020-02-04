CREATE TABLE relevance
(
    id SERIAL PRIMARY KEY,
    object VARCHAR(256) NOT NULL,
    height integer NOT NULL,
    rank numeric NOT NULL
);

CREATE UNIQUE INDEX relevance_cid_block ON relevance(object, height);