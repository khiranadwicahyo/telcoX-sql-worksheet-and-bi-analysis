WITH usage_avg AS (
    SELECT
        customer_id,
        AVG(data_usage) AS avg_gb
    FROM usage_activity
    GROUP BY customer_id
),
usage_segment AS (
    SELECT
        customer_id,
        avg_gb,
        NTILE(3) OVER (ORDER BY avg_gb) AS usage_tier
    FROM usage_avg
)
SELECT
    CASE
        WHEN usage_tier = 3 THEN 'Heavy User'
        WHEN usage_tier = 2 THEN 'Medium User'
        ELSE 'Light User'
    END AS data_segment,
    ROUND(AVG(b.monthly_charge), 2) AS arpu
FROM usage_segment us
JOIN billing b ON b.customer_id = us.customer_id
GROUP BY data_segment
ORDER BY arpu DESC;