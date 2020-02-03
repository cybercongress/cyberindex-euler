CREATE VIEW rewards_view AS (
    WITH linkage AS (
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
    ), top_cids AS (
        SELECT cid, block, rank
        FROM relevance
    ), top_cids_sum AS (
        SELECT block, sum(rank) AS rank_sum
        FROM top_cids
        WHERE cid IN (SELECT cid FROM linkage)
        GROUP BY block
    ), B_linked_agents AS (
        SELECT * 
        FROM (
            SELECT agent, height AS block, cid, RANK () OVER ( 
              PARTITION BY cid
              ORDER BY timestamp
            ) order_number
            FROM linkage
        ) AS tmp
        WHERE order_number <= 10
    ), B_linked_agents_max_order AS (
        SELECT block, cid, max(order_number) AS max_order_number
        FROM B_linked_agents
        GROUP BY block, cid
    )
    SELECT 
        B_linked_agents.agent, 
        top_cids.cid, 
        top_cids.block AS block, 
        B_linked_agents.block AS test_block,
        top_cids.rank, 
        B_linked_agents.order_number,
        top_cids_sum.rank_sum,
        B_linked_agents_max_order.max_order_number
    FROM top_cids, B_linked_agents, top_cids_sum, B_linked_agents_max_order
    WHERE top_cids.cid = B_linked_agents.cid
    AND B_linked_agents.block <= top_cids.block
    AND top_cids_sum.block = top_cids.block
    AND (
        B_linked_agents_max_order.cid = B_linked_agents.cid 
        AND B_linked_agents_max_order.block = B_linked_agents.block
    )
)