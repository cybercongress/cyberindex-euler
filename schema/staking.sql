CREATE TABLE staking
(
    id SERIAL PRIMARY KEY,
    operator_address VARCHAR(256) NOT NULL,
    height integer NOT NULL,
    tokens numeric NOT NULL
);

CREATE UNIQUE INDEX staking_block ON staking(operator_address, height);