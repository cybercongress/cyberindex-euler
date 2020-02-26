CREATE TABLE message
(
    id SERIAL PRIMARY KEY,
    subject CHAR(44) NOT NULL,
    type character varying(64) NOT NULL,
    value jsonb NOT NULL DEFAULT '{}'::jsonb,
    timestamp timestamp without time zone NOT NULL,
    height integer NOT NULL REFERENCES block(height),
    txhash CHAR(64) NOT NULL UNIQUE REFERENCES transaction(txhash),
    code integer DEFAULT 0,
    codespace character varying(64)
);