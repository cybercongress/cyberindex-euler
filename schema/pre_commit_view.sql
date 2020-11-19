CREATE TABLE old_pre_commits
(
    consensus_pubkey character varying(83) NOT NULL UNIQUE PRIMARY KEY,
    precommits NUMERIC
);

CREATE MATERIALIZED VIEW pre_commit_view AS (
    SELECT
        consensus_pubkey,
        sum(precommits) AS precommits
    FROM (
        (
        SELECT
            consensus_pubkey,
            count(*) AS precommits
        FROM (
            SELECT
                pre_commit.validator_address,
                validator.consensus_pubkey
            FROM
                pre_commit
            LEFT JOIN
                validator
            ON
                pre_commit.validator_address = validator.address
        ) AS e
        GROUP BY consensus_pubkey
        ) UNION all (
        SELECT * FROM old_pre_commits
         )
    ) q
    GROUP BY
        consensus_pubkey
);

CREATE UNIQUE INDEX ON pre_commit_view (
    consensus_pubkey
);

CREATE OR REPLACE FUNCTION refresh_pre_commit_view()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
REFRESH MATERIALIZED VIEW CONCURRENTLY pre_commit_view;
RETURN NULL;
END $$;

CREATE TRIGGER refresh_pre_commit_view
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON pre_commit
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_pre_commit_view();