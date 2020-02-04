CREATE VIEW linkage_view AS (
    SELECT cid, agent, MIN(height) AS height, MIN(timestamp) AS timestamp
    FROM (
        SELECT object_to AS cid, subject AS agent, MIN(height) AS height, MIN(timestamp) AS timestamp
        FROM cyberlink
        GROUP BY object_to, subject
        
        UNION
        
        SELECT object_from AS cid, subject AS agent, MIN(height) AS height, MIN(timestamp) AS timestamp
        FROM cyberlink
        GROUP BY object_from, subject
    ) AS merged_linkage
    GROUP BY cid, agent
)

CREATE VIEW rewards_view AS (
    WITH top_cids AS (
        SELECT cid, block, rank
        FROM relevance
    ), B_linked_agents AS (
        SELECT * 
        FROM (
            SELECT agent, height AS block, cid, RANK () OVER ( 
              PARTITION BY cid
              ORDER BY timestamp
            ) order_number
            FROM linkage_view
        ) AS tmp
        WHERE order_number <= 10
    )
    SELECT 
        B_linked_agents.agent, 
        top_cids.cid, 
        top_cids.block AS block, 
        B_linked_agents.block AS test_block,
        top_cids.rank, 
        B_linked_agents.order_number
    FROM top_cids, B_linked_agents
    WHERE top_cids.cid = B_linked_agents.cid
    AND B_linked_agents.block <= top_cids.block
)


CREATE VIEW linkages_view AS (
    SELECT linkage_view.cid, block, count(*) AS linkages
    FROM linkage_view, relevance
    WHERE linkage_view.cid = relevance.cid
    AND linkage_view.height <= relevance.block
    GROUP BY linkage_view.cid, block
)