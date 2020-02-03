CREATE TABLE relevance
(
    id SERIAL PRIMARY KEY,
    cid VARCHAR(256) NOT NULL,
    block integer NOT NULL,
    rank numeric NOT NULL
);

CREATE UNIQUE INDEX relevance_cid_block ON relevance(cid, block);