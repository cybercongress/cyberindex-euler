CREATE VIEW MATERIALIZED top_1000 AS (
SELECT
    row_number() OVER (PARTITION BY true) as id,
    rel.object,
    rel.rank,
    link.subject,
    link."timestamp",
    link.height
FROM (
        SELECT object, rank
        FROM relevance
        WHERE height = (SELECT MAX(height)
                FROM relevance)
    ) rel
LEFT JOIN
    (
        SELECT
            cyberlink.subject,
            cyberlink.object_from AS object,
            min(cyberlink.height) AS height,
            min(cyberlink."timestamp") AS "timestamp"
        FROM
            cyberlink
        GROUP BY
            cyberlink.object_from,
            cyberlink.subject
        UNION
        SELECT
            cyberlink.subject,
            cyberlink.object_to AS object,
            min(cyberlink.height) AS height,
            min(cyberlink."timestamp") AS "timestamp"
        FROM
            cyberlink
        GROUP BY
            cyberlink.object_to,
            cyberlink.subject
    ) link
ON (
        rel.object = link.object
    )
);

CREATE VIEW top_stats AS (
SELECT row_number() OVER (PARTITION BY true) as tsid, top_1000.object, top_1000."rank", top_1000.subject, top_1000."timestamp", top_1000.height, cnt.cnt,
RANK() OVER(
    PARTITION BY top_1000.object
    ORDER BY top_1000."timestamp"
    ) AS order_number
FROM top_1000
LEFT JOIN
    (
        SELECT top_1000.object, COUNT(top_1000.object) as cnt
        FROM top_1000
        GROUP BY top_1000.object
    ) cnt
ON (
        top_1000.object = cnt.object
    )
WHERE cnt.cnt <= 10
ORDER BY top_1000."rank" DESC, top_1000."timestamp" ASC
);

CREATE VIEW rewards_view AS (
SELECT *,
    case
        when top_stats.cnt = 1 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / top_stats.order_number
        when top_stats.cnt = 2 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 1.5)
        when top_stats.cnt = 3 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 1.83333333)
        when top_stats.cnt = 4 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 2.08333333)
        when top_stats.cnt = 5 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 2.28333333)
        when top_stats.cnt = 6 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 2.45)
        when top_stats.cnt = 7 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 2.59285714)
        when top_stats.cnt = 8 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 2.71785714)
        when top_stats.cnt = 9 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 2.82896825)
        when top_stats.cnt = 10 then top_stats."rank"/(SELECT SUM(SQ."rank") FROM (SELECT DISTINCT top_stats.object, top_stats."rank" FROM top_stats) SQ) / (top_stats.order_number * 2.92896825)
    end as share
FROM top_stats
);

CREATE VIEW relevance_leaderboard AS (
    SELECT
        subject,
        sum(share) as share
    FROM
        rewards_view
    GROUP BY
        subject
    ORDER BY
        share DESC
);

CREATE OR REPLACE FUNCTION refresh_top_1000()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
REFRESH MATERIALIZED VIEW CONCURRENTLY top_1000;
RETURN NULL;
END $$;

CREATE TRIGGER refresh_top_1000
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON relevance
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_top_1000();