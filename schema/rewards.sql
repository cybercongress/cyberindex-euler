CREATE VIEW relevance_subject AS (
    SELECT
    rel.object,
    rel.rank,
    linkage.subject,
    linkage."timestamp",
    linkage.height
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
    ) linkage
ON (
        rel.object = linkage.object
    )
ORDER BY rank DESC)