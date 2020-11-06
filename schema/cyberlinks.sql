CREATE VIEW cyberlinks_per_day AS (
    SELECT
        day::date as "date",
        COALESCE(links.links, 0) as links
    FROM
        generate_series('2020-04-04', now(), INTERVAL '1 day') day
    LEFT JOIN (
        SELECT date(cyberlink."timestamp") AS date,
        count(cyberlink."timestamp") AS links
        FROM cyberlink
        WHERE cyberlink."timestamp" > '2020-04-04'
        GROUP BY (date(cyberlink."timestamp"))
        ORDER BY (date(cyberlink."timestamp"))
    ) links
    ON(
        day::date = links."date"
    )
);

CREATE VIEW cyberlinks_total AS (
    SELECT
        day::date as "date",
        cl.links,
        COALESCE(cl.total, 0) as total
    FROM
        generate_series('2020-04-04', now(), INTERVAL '1 day') day
    LEFT JOIN (
        SELECT cyberlinks_per_day.date,
        cyberlinks_per_day.links,
        sum(cyberlinks_per_day.links) OVER (ORDER BY cyberlinks_per_day.date) AS total
        FROM cyberlinks_per_day
        ORDER BY cyberlinks_per_day.date
    ) cl
    ON (
        day::date = cl.date
    )
);


