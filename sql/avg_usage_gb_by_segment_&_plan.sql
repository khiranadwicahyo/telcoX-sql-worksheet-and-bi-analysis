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
        WHEN us.usage_tier = 3 THEN 'Heavy User'
        WHEN us.usage_tier = 2 THEN 'Medium User'
        ELSE 'Light User'
    END AS data_segment,
    sp.plan_name,
    COUNT(*) AS total_customers,
    ROUND(AVG(us.avg_gb)::numeric, 2) AS avg_usage_gb
FROM usage_segment us
JOIN customer_profile cp 
    ON cp.customer_id = us.customer_id
JOIN subscription_plan sp 
    ON sp.plan_id = cp.plan_id
GROUP BY data_segment, sp.plan_name
ORDER BY data_segment, total_customers DESC;
