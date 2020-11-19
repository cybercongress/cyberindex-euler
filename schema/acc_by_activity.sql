CREATE MATERIALIZED VIEW accs_by_act AS (
    SELECT
        DISTINCT ON(subject) "transaction".subject,
        del.first_delegation,
        send.first_send,
        link.first_link,
        first_tw.first_tweet,
        foll.first_follow,
        av.first_avatar,
        folls.follows,
        links.cyberlinks,
        tw.tweets,
        five_f.first_5_folls,
        twfive_f.first_25_folls,
        ten_links.first_10_links,
        hun_links.first_100_links
    FROM transaction
    LEFT JOIN (
        SELECT
            subject,
            date(min("timestamp")) as first_delegation
        FROM
          message
        WHERE
            "type" = 'cosmos-sdk/MsgDelegate' OR
            "type" = 'cosmos-sdk/MsgCreateValidator' AND
            code = '0'
        GROUP BY
            subject
    ) del
    ON (
        transaction.subject = del.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            date(min("timestamp")) as first_send
        FROM
          message
        WHERE
            "type" = 'cosmos-sdk/MsgSend' OR
            "type" = 'cosmos-sdk/MsgMultiSend' AND
            code = '0'
        GROUP BY
            subject
    ) send
    ON (
        transaction.subject = send.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            date(min("timestamp")) as first_link
        FROM
            cyberlink
        GROUP BY
            subject
    ) link
    ON (
        transaction.subject = link.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            date(min("timestamp")) as first_tweet
        FROM
            cyberlink
        WHERE
            object_from = 'QmbdH2WBamyKLPE5zu4mJ9v49qvY8BFfoumoVPMR5V4Rvx'
        GROUP BY
            subject
    ) first_tw
    ON (
        transaction.subject = first_tw.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            date(min("timestamp")) as first_follow
        FROM
            cyberlink
        WHERE
            object_from = 'QmPLSA5oPqYxgc8F7EwrM8WS9vKrr1zPoDniSRFh8HSrxx'
        GROUP BY
            subject
    ) foll
    ON (
        transaction.subject = foll.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            date(min("timestamp")) as first_avatar
        FROM
            cyberlink
        WHERE
            object_from = 'Qmf89bXkJH9jw4uaLkHmZkxQ51qGKfUPtAMxA8rTwBrmTs'
        GROUP BY
            subject
    ) av
    ON (
        transaction.subject = av.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            count(object_from) as follows
        FROM
            cyberlink
        WHERE
            object_from = 'QmPLSA5oPqYxgc8F7EwrM8WS9vKrr1zPoDniSRFh8HSrxx'
        GROUP BY
            subject
    ) folls
    ON (
        transaction.subject = folls.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            count(karma) as cyberlinks
        FROM
            cyberlink
        GROUP BY
            subject
    ) links
    ON (
        transaction.subject = links.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            count(object_from) as tweets
        FROM
            cyberlink
        WHERE
            object_from = 'QmbdH2WBamyKLPE5zu4mJ9v49qvY8BFfoumoVPMR5V4Rvx'
        GROUP BY
            subject
    ) tw
    ON (
        transaction.subject = tw.subject
    )
    LEFT JOIN (
        SELECT
            ord.subject,
            date("timestamp") as first_5_folls
        FROM (
            SELECT
                row_number() over (partition by subject order by "timestamp" asc) as "order",
                subject,
                "timestamp"
            FROM
                cyberlink
            WHERE
                object_from = 'QmPLSA5oPqYxgc8F7EwrM8WS9vKrr1zPoDniSRFh8HSrxx'
        ) ord
            WHERE
                ord."order" = 5
    ) five_f
    ON (
        transaction.subject = five_f.subject
    )
    LEFT JOIN (
        SELECT
            ord.subject,
            date("timestamp") as first_25_folls
        FROM (
            SELECT
                row_number() over (partition by subject order by "timestamp" asc) as "order",
                subject,
                "timestamp"
            FROM
                cyberlink
            WHERE
                object_from = 'QmPLSA5oPqYxgc8F7EwrM8WS9vKrr1zPoDniSRFh8HSrxx'
        ) ord
            WHERE
                ord."order" = 25
    ) twfive_f
    ON (
        transaction.subject = twfive_f.subject
    )
    LEFT JOIN (
        SELECT
        ord.subject,
        date("timestamp") as first_10_links
        FROM(
            SELECT
                row_number() over (partition by subject order by "timestamp" asc) as "order",
                subject,
                "timestamp"
            FROM
                cyberlink
        ) ord
        WHERE
            ord."order" = 10
    ) ten_links
    ON (
        transaction.subject = ten_links.subject
    )
    LEFT JOIN (
        SELECT
            ord.subject,
            date("timestamp") as first_100_links
        FROM (
            SELECT
                row_number() over (partition by subject order by "timestamp" asc) as "order",
                subject,
                "timestamp"
            FROM
                cyberlink
        ) ord
        WHERE
            ord."order" = 100
    ) hun_links
    ON (
        transaction.subject = hun_links.subject
    )
);

CREATE UNIQUE INDEX ON accs_by_act (
    subject
);

CREATE OR REPLACE FUNCTION refresh_accs_by_act()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
REFRESH MATERIALIZED VIEW CONCURRENTLY accs_by_act;
RETURN NULL;
END $$;

CREATE TRIGGER refresh_accs_by_act
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON transaction
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_accs_by_act();
