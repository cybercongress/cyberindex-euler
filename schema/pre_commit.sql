-- DDL generated by Postico 1.5.8
-- Not all database features are supported. Do not use for backup.

-- Table Definition ----------------------------------------------

CREATE TABLE pre_commit (
    id SERIAL PRIMARY KEY,
    validator_address character varying(40) NOT NULL REFERENCES validator(address),
    timestamp timestamp without time zone NOT NULL,
    voting_power integer NOT NULL,
    proposer_priority integer NOT NULL,
    height integer NOT NULL
);

-- Indices -------------------------------------------------------

CREATE UNIQUE INDEX pre_commit_pkey ON pre_commit(id int4_ops);
CREATE INDEX pre_commit_height_key ON pre_commit(height int4_ops);
CREATE INDEX pre_commit_validator_address_key ON pre_commit(validator_address text_ops);
