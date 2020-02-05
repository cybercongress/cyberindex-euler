CREATE VIEW linkage_view AS (
    SELECT object, subject, MIN(height) AS height, MIN(timestamp) AS timestamp
    FROM (
        SELECT object_to AS object, subject, MIN(height) AS height, MIN(timestamp) AS timestamp
        FROM cyberlink
        GROUP BY object_to, subject
        
        UNION
        
        SELECT object_from AS object, subject, MIN(height) AS height, MIN(timestamp) AS timestamp
        FROM cyberlink
        GROUP BY object_from, subject
    ) AS merged_linkage
    GROUP BY object, subject
);

CREATE VIEW rewards_view AS (
    WITH top_objects AS (
        SELECT object, height, rank
        FROM relevance
    ), linked_subjects AS (
        SELECT * 
        FROM (
            SELECT subject, height, object, RANK () OVER ( 
              PARTITION BY object
              ORDER BY timestamp
            ) order_number
            FROM linkage_view
        ) AS tmp
        WHERE order_number <= 10
    )
    SELECT 
        linked_subjects.subject, 
        top_objects.object, 
        top_objects.height AS block, 
        linked_subjects.height AS test_block,
        top_objects.rank, 
        linked_subjects.order_number
    FROM top_objects, linked_subjects
    WHERE top_objects.object = linked_subjects.object
    AND linked_subjects.height <= top_objects.height
);


CREATE VIEW linkages_view AS (
    SELECT linkage_view.object, relevance.height, count(*) AS linkages
    FROM linkage_view, relevance
    WHERE linkage_view.object = relevance.object
    AND linkage_view.height <= relevance.height
    GROUP BY linkage_view.object, relevance.height
)