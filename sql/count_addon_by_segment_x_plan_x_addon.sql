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
        NTILE(3) OVER (ORDER BY avg_gb) AS usage_tier
    FROM usage_avg
),
addon_rank AS (
    SELECT
        CASE
            WHEN us.usage_tier = 3 THEN 'Heavy User'
            WHEN us.usage_tier = 2 THEN 'Medium User'
            ELSE 'Light User'
        END AS data_segment,
        sp.plan_name,
        ao.add_on_name,
        COUNT(*) AS addon_count,
        RANK() OVER (
            PARTITION BY
                CASE
                    WHEN us.usage_tier = 3 THEN 'Heavy User'
                    WHEN us.usage_tier = 2 THEN 'Medium User'
                    ELSE 'Light User'
                END,
                sp.plan_name
            ORDER BY COUNT(*) DESC
        ) AS addon_rank
    FROM usage_segment us
    JOIN customer_profile cp ON cp.customer_id = us.customer_id
    JOIN subscription_plan sp ON sp.plan_id = cp.plan_id
    JOIN add_on_usage ao ON ao.customer_id = us.customer_id
    GROUP BY data_segment, sp.plan_name, ao.add_on_name
)
SELECT
    data_segment,
    plan_name,
    add_on_name AS top_addon,
    addon_count
FROM addon_rank
WHERE addon_rank = 1
ORDER BY data_segment, plan_name;
