CREATE VIEW euler4_per_day AS (
    SELECT
        "date",
        COALESCE(tmp.eul,0) as euler4
    FROM
        time_series
    LEFT JOIN (
        SELECT
            first_tx,
            count(first_tx) as eul
        FROM (
            WITH first_tx AS (
                SELECT
                    date(min("timestamp")) as first_tx,
                    subject
                FROM
                    transaction
                WHERE
                    code = '0'
                GROUP BY
                    subject
            ), eul_gift AS (
                SELECT
                    subject
                FROM
                    gift_info
                WHERE
                    euler4 IS NOT NULL
            )
            SELECT
                first_tx.first_tx,
                first_tx.subject
            FROM
                first_tx, eul_gift
            WHERE
                eul_gift.subject = first_tx.subject
            ORDER BY
                first_tx.first_tx ASC
        ) tmp
        GROUP BY first_tx
    ) tmp
    ON (
        time_series."date" = tmp.first_tx
    )
);

CREATE VIEW euler4_total AS (
    SELECT
        time_series."date",
        eul.euler4,
        eul.total
    FROM
        time_series
    LEFT JOIN (
        SELECT
            euler4_per_day.date,
            euler4_per_day.euler4 AS euler4,
            sum(euler4_per_day.euler4) OVER (ORDER BY euler4_per_day.date) AS total
            FROM euler4_per_day
            ORDER BY euler4_per_day.date
        ) eul
    ON (
        time_series.date = eul.date
    )
);

CREATE VIEW ethereum_per_day AS (
    SELECT
        "date",
        COALESCE(tmp.eth,0) as ethereum
        FROM
            time_series
        LEFT JOIN (
            SELECT
                first_tx,
                count(first_tx) as eth
            FROM (
                WITH first_tx AS (
                    SELECT
                        date(min("timestamp")) as first_tx,
                        subject
                    FROM
                        transaction
                    WHERE
                        code = '0'
                    GROUP BY
                        subject
                ), eth_gift AS (
                    SELECT
                        subject
                    FROM
                        gift_info
                    WHERE
                        ethereum IS NOT NULL
                )
                SELECT
                    first_tx.first_tx,
                    first_tx.subject
                FROM
                    first_tx, eth_gift
                WHERE
                    eth_gift.subject = first_tx.subject
                ORDER BY
                    first_tx.first_tx ASC
            ) tmp
            GROUP BY first_tx
        ) tmp
    ON (
        time_series."date" = tmp.first_tx
    )
);

CREATE VIEW ethereum_total AS (
    SELECT
        time_series."date",
        eth.ethereum,
        eth.total
    FROM
        time_series
    LEFT JOIN (
        SELECT
            ethereum_per_day.date,
            ethereum_per_day.ethereum AS ethereum,
            sum(ethereum_per_day.ethereum) OVER (ORDER BY ethereum_per_day.date) AS total
            FROM ethereum_per_day
            ORDER BY ethereum_per_day.date
        ) eth
    ON (
        time_series.date = eth.date
    )
);

CREATE VIEW urbit_per_day AS (
    SELECT
        "date",
        COALESCE(tmp.urb,0) as urbit
        FROM
            time_series
        LEFT JOIN (
            SELECT
                first_tx,
                count(first_tx) as urb
            FROM (
                WITH first_tx AS (
                    SELECT
                        date(min("timestamp")) as first_tx,
                        subject
                    FROM
                        transaction
                    WHERE
                        code = '0'
                    GROUP BY
                        subject
                ), urb_gift AS (
                    SELECT
                        subject
                    FROM
                        gift_info
                    WHERE
                        urbit IS NOT NULL
                )
                SELECT
                    first_tx.first_tx,
                    first_tx.subject
                FROM
                    first_tx, urb_gift
                WHERE
                    urb_gift.subject = first_tx.subject
                ORDER BY
                    first_tx.first_tx ASC
            ) tmp
            GROUP BY first_tx
        ) tmp
    ON (
        time_series."date" = tmp.first_tx
    )
);

CREATE VIEW urbit_total AS (
    SELECT
        time_series."date",
        urb.urbit,
        urb.total
    FROM
        time_series
    LEFT JOIN (
        SELECT
            urbit_per_day.date,
            urbit_per_day.urbit AS urbit,
            sum(urbit_per_day.urbit) OVER (ORDER BY urbit_per_day.date) AS total
            FROM urbit_per_day
            ORDER BY urbit_per_day.date
        ) urb
    ON (
        time_series.date = urb.date
    )
);

CREATE VIEW cosmos_per_day AS (
    SELECT
        "date",
        COALESCE(tmp.cosm,0) as cosmos
        FROM
            time_series
        LEFT JOIN (
            SELECT
                first_tx,
                count(first_tx) as cosm
            FROM (
                WITH first_tx AS (
                    SELECT
                        date(min("timestamp")) as first_tx,
                        subject
                    FROM
                        transaction
                    WHERE
                        code = '0'
                    GROUP BY
                        subject
                ), cosm_gift AS (
                    SELECT
                        subject
                    FROM
                        gift_info
                    WHERE
                        cosmos IS NOT NULL
                )
                SELECT
                    first_tx.first_tx,
                    first_tx.subject
                FROM
                    first_tx, cosm_gift
                WHERE
                    cosm_gift.subject = first_tx.subject
                ORDER BY
                    first_tx.first_tx ASC
            ) tmp
            GROUP BY first_tx
        ) tmp
    ON (
        time_series."date" = tmp.first_tx
    )
);

CREATE VIEW cosmos_total AS (
    SELECT
        time_series."date",
        cosm.cosmos,
        cosm.total
    FROM
        time_series
    LEFT JOIN (
        SELECT
            cosmos_per_day.date,
            cosmos_per_day.cosmos AS cosmos,
            sum(cosmos_per_day.cosmos) OVER (ORDER BY cosmos_per_day.date) AS total
            FROM cosmos_per_day
            ORDER BY cosmos_per_day.date
        ) cosm
    ON (
        time_series.date = cosm.date
    )
);

CREATE VIEW new_per_day AS (
    SELECT
        "date",
        COALESCE(tmp.new,0) as new
    FROM
        time_series
    LEFT JOIN (
        SELECT
            first_tx,
            count(first_tx) as new
        FROM (
            SELECT
                date(min("timestamp")) as first_tx,
                subject
            FROM
                transaction
            WHERE
                code = '0' AND
                NOT EXISTS (
                    SELECT  NULL
                    FROM    gift_info
                    WHERE   gift_info.subject = transaction.subject
                )
            GROUP BY
                subject
            ORDER BY first_tx asc
        ) tmp
        GROUP BY first_tx
    ) tmp
    ON (
        time_series."date" = tmp.first_tx
    )
);

CREATE VIEW new_total AS (
    SELECT
        time_series."date",
        nw.new,
        nw.total
    FROM
        time_series
    LEFT JOIN (
        SELECT
            new_per_day.date,
            new_per_day.new AS new,
            sum(new_per_day.new) OVER (ORDER BY new_per_day.date) AS total
            FROM new_per_day
            ORDER BY new_per_day.date
        ) nw
    ON (
        time_series.date = nw.date
    )
);

CREATE VIEW unique_per_day AS (
    SELECT
            "date",
            COALESCE(tmp.account,0) as account
    FROM
        time_series
    LEFT JOIN (
        SELECT
            first_tx,
            count(first_tx) as account
        FROM (
            SELECT
                date(min("timestamp")) as first_tx,
                subject
            FROM
                transaction
            WHERE
                code = '0'
            GROUP BY
                subject
            ORDER BY first_tx asc
        ) tmp
        GROUP BY first_tx
    ) tmp
    ON (
        time_series."date" = tmp.first_tx
    )
);

SELECT
    time_series."date",
    unq.account,
    unq.total
FROM
    time_series
LEFT JOIN (
    SELECT
        unique_per_day.date,
        unique_per_day.account AS account,
        sum(unique_per_day.account) OVER (ORDER BY unique_per_day.date) AS total
        FROM unique_per_day
        ORDER BY unique_per_day.date
    ) unq
ON (
    time_series.date = unq.date
);