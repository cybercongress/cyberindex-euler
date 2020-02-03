CREATE TABLE bandwidth_price
(
    id SERIAL PRIMARY KEY,
    block integer NOT NULL UNIQUE,
    price numeric NOT NULL
);