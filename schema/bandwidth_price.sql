CREATE TABLE bandwidth_price
(
    id SERIAL PRIMARY KEY,
    height integer NOT NULL UNIQUE,
    price numeric NOT NULL
);