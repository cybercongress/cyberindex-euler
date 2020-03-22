CREATE VIEW karma_view AS (
    SELECT cyberlink.subject, SUM(cyberlink.karma) AS "karma" FROM cyberlink
    GROUP BY cyberlink.subject
)