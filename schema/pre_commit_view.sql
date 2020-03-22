CREATE VIEW pre_commit_view AS (
    SELECT consensus_pubkey, count(*) AS "precommits" FROM (
        SELECT pre_commit.validator_address, validator.consensus_pubkey
        FROM pre_commit
        LEFT JOIN validator
        ON pre_commit.validator_address = validator.address
    ) AS e 
    GROUP BY consensus_pubkey
)