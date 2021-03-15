CREATE VIEW karma_view AS (
    SELECT cyberlink.subject, SUM(cyberlink.karma) AS "karma" FROM cyberlink
    WHERE cyberlink.height <= 3638501
    GROUP BY cyberlink.subject
)