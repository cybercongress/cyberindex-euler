CREATE VIEW tweets_per_day AS (
    SELECT
    day::date as "date",
    COALESCE(tweets.tweets, 0) as tweets
    FROM
        generate_series('2020-07-15', now(), INTERVAL '1 day') day
    LEFT JOIN (
        SELECT date(cyberlink."timestamp") AS date,
        count(cyberlink."timestamp") FILTER (WHERE cyberlink.object_from = 'QmbdH2WBamyKLPE5zu4mJ9v49qvY8BFfoumoVPMR5V4Rvx') AS tweets
        FROM cyberlink
        WHERE cyberlink."timestamp" > '2020-07-14'
        GROUP BY (date(cyberlink."timestamp"))
        ORDER BY (date(cyberlink."timestamp"))
    ) tweets
    ON (
        day::date = tweets."date"
    )
);

CREATE VIEW tweets_total AS (
    SELECT
        day::date as "date",
        tw.tweets,
        COALESCE(tw.total, 0) as total
    FROM
        generate_series('2020-07-15', now(), INTERVAL '1 day') day
    LEFT JOIN (
        SELECT tweets_per_day.date,
        tweets_per_day.tweets,
        sum(tweets_per_day.tweets) OVER (ORDER BY tweets_per_day.date) AS total
        FROM tweets_per_day
        ORDER BY tweets_per_day.date
    ) tw
    ON (
        day::date = tw.date
    )
);

