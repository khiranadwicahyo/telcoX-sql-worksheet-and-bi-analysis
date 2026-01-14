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
),
addon_per_customer AS (
    SELECT
        customer_id,
        SUM(add_on_price) AS total_addon_charge
    FROM add_on_usage
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN us.usage_tier = 3 THEN 'Heavy User'
        WHEN us.usage_tier = 2 THEN 'Medium User'
        ELSE 'Light User'
    END AS data_segment,

    ROUND(AVG(b.monthly_charge), 2) AS base_arpu,
    ROUND(AVG(COALESCE(apc.total_addon_charge, 0)), 2) AS addon_arpu,
    ROUND(AVG(b.monthly_charge + COALESCE(apc.total_addon_charge, 0)), 2) AS total_arpu
FROM usage_segment us
JOIN billing b
    ON b.customer_id = us.customer_id
LEFT JOIN addon_per_customer apc
    ON apc.customer_id = us.customer_id
GROUP BY data_segment
ORDER BY total_arpu DESC;
