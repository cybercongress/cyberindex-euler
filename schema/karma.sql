CREATE VIEW karma_view AS (
    SELECT subject, links_count.height, links * COALESCE(price, 0.01) * 100 AS karma
    FROM (
        SELECT subject, height, count(*) AS links
        FROM cyberlink
        GROUP BY subject, height
    ) AS links_count 
    LEFT JOIN (
        SELECT height, price 
        FROM bandwidth_price
    ) AS bandwidth_price_tmp
    ON
        links_count.height = bandwidth_price_tmp.height
)