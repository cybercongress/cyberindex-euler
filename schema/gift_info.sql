DROP TABLE IF EXISTS gift_info CASCADE;

CREATE TABLE gift_info
(
    subject CHAR(44) NOT NULL UNIQUE PRIMARY KEY,
    euler4 CHAR(51),
    urbit CHAR(42),
    cosmos CHAR(45),
    ethereum CHAR(42)
);