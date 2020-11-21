CREATE EXTENSION tablefunc;

CREATE MATERIALIZED VIEW tx_order AS (
    SELECT *
    FROM (
        SELECT
          tmp.subject,
          row_number() OVER (
            PARTITION BY tmp.subject
            ORDER BY
              tmp."timestamp"
          ) AS ordering,
          tmp.txhash,
          tmp."timestamp",
          CASE
            WHEN tmp.type = 'recieve' OR tmp.type = 'cosmos-sdk/MsgSend' OR tmp.type = 'cosmos-sdk/MsgMultiSend' THEN 'transfer'
          ELSE tmp.type
          END AS "type"
        FROM (
            SELECT *
            FROM (
                SELECT
                    "timestamp",
                    BTRIM(recipient, '\"') :: char(44) AS subject,
                    txhash,
                    CASE
                        WHEN "type" = 'cosmos-sdk/MsgSend' THEN 'recieve'
                    END AS "type"
                FROM (
                    SELECT
                        "timestamp",
                        subject,
                        recipient,
                        txhash,
                        "type",
                        row_number() OVER (
                            PARTITION BY recipient
                            ORDER BY "timestamp"
                        ) AS ordering
                    FROM (
                        SELECT
                            "timestamp",
                            subject,
                            text(value :: json -> 'to_address') AS recipient,
                            txhash,
                            "type"
                        FROM
                            message
                        WHERE
                            "type" = 'cosmos-sdk/MsgSend' AND
                            code = 0
                    ) tmp
                ) tmp
                WHERE ordering = 1
                UNION
                SELECT *
                FROM (
                    SELECT
                        transaction."timestamp",
                        transaction.subject,
                        transaction.txhash,
                        tp."type"
                    FROM
                        transaction
                    LEFT JOIN (
                        SELECT
                            message.subject,
                            message.txhash,
                            message.type
                        FROM
                            message
                    ) tp ON (tp.txhash = transaction.txhash)
                ) tmp
            ) temp
        ) tmp
    ) tmp
    WHERE
        tmp.ordering = 1 OR
        tmp.ordering = 2
    ORDER BY "timestamp"
);

CREATE UNIQUE INDEX ON tx_order (
    subject,
    ordering
);

CREATE MATERIALIZED VIEW cohorts AS (
    SELECT
        final_result.subject,
        date(final_result.register) AS register,
        date(final_result.first_act) AS first_act,
        reg."type" AS register_act_type,
        scnd."type" AS first_act_type,
        date(date_trunc('month', reg."timestamp")) AS register_act_month,
        CASE
            WHEN final_result.first_act IS NULL THEN -1
            ELSE TRUNC(DATE_PART('day', scnd."timestamp" - reg."timestamp")/30)
            END AS diff,
        CASE
            WHEN final_result.subject IN (SELECT subject FROM gift_info WHERE ethereum IS NOT NULL) THEN 'ethereum'
            WHEN final_result.subject IN (SELECT subject FROM gift_info WHERE cosmos IS NOT NULL) THEN 'cosmos'
            WHEN final_result.subject IN (SELECT subject FROM gift_info WHERE urbit IS NOT NULL) THEN 'urbit'
            WHEN final_result.subject IN (SELECT subject FROM gift_info WHERE euler4 IS NOT NULL) THEN 'euler4'
            ELSE 'new'
            END AS tag
    FROM
        crosstab('SELECT subject, ordering, "timestamp" FROM tx_order ORDER BY subject, "timestamp", ordering') AS final_result(subject char(44), register timestamp, first_act timestamp)
    LEFT JOIN (
        SELECT
            subject,
            "timestamp",
            "type"
        FROM tx_order
        WHERE
            ordering = 1
    ) reg
    ON (
        final_result.subject = reg.subject
    )
    LEFT JOIN (
        SELECT
            subject,
            "timestamp",
            "type"
        FROM tx_order
        WHERE
            ordering = 2
    ) scnd
    ON (
        final_result.subject = scnd.subject
    )
);

CREATE UNIQUE INDEX ON cohorts (
    subject
);

CREATE OR REPLACE FUNCTION refresh_tx_order()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
REFRESH MATERIALIZED VIEW CONCURRENTLY tx_order;
RETURN NULL;
END $$;

CREATE TRIGGER refresh_tx_order
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON transaction
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_tx_order();

CREATE OR REPLACE FUNCTION refresh_cohorts()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
REFRESH MATERIALIZED VIEW CONCURRENTLY cohorts;
RETURN NULL;
END $$;

CREATE TRIGGER refresh_cohorts
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON transaction
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_cohorts();
