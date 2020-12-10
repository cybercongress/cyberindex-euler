DROP MATERIALIZED VIEW IF EXISTS pre_commit_view CASCADE;
DROP VIEW IF EXISTS pre_commit_view CASCADE;

CREATE TABLE old_pre_commits
(
    consensus_pubkey character varying(83) NOT NULL UNIQUE PRIMARY KEY,
    precommits NUMERIC
);

CREATE VIEW pre_commit_view AS (
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