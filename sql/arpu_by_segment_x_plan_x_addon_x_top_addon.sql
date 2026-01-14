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

addon_per_customer AS (
    SELECT
        customer_id,
        SUM(add_on_price) AS total_addon_charge
    FROM add_on_usage
    GROUP BY customer_id
),

-- =========================
-- ARPU AGGREGATION
-- =========================
arpu_segment_plan AS (
    SELECT
        CASE
            WHEN us.usage_tier = 3 THEN 'Heavy User'
            WHEN us.usage_tier = 2 THEN 'Medium User'
            ELSE 'Light User'
        END AS data_segment,
        sp.plan_name,

        ROUND(AVG(b.monthly_charge)::numeric, 2) AS base_arpu,
        ROUND(AVG(COALESCE(apc.total_addon_charge, 0))::numeric, 2) AS addon_arpu,
        ROUND(
            AVG(b.monthly_charge + COALESCE(apc.total_addon_charge, 0))::numeric,
            2
        ) AS total_arpu

    FROM usage_segment us
    JOIN billing b
        ON b.customer_id = us.customer_id
    JOIN customer_profile cp
        ON cp.customer_id = us.customer_id
    JOIN subscription_plan sp
        ON sp.plan_id = cp.plan_id
    LEFT JOIN addon_per_customer apc
        ON apc.customer_id = us.customer_id

    GROUP BY data_segment, sp.plan_name
),

-- =========================
-- TOP ADD-ON PER SEGMENT x PLAN
-- =========================
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

        ROW_NUMBER() OVER (
            PARTITION BY
                CASE
                    WHEN us.usage_tier = 3 THEN 'Heavy User'
                    WHEN us.usage_tier = 2 THEN 'Medium User'
                    ELSE 'Light User'
                END,
                sp.plan_name
            ORDER BY COUNT(*) DESC
        ) AS rn

    FROM usage_segment us
    JOIN customer_profile cp
        ON cp.customer_id = us.customer_id
    JOIN subscription_plan sp
        ON sp.plan_id = cp.plan_id
    JOIN add_on_usage ao
        ON ao.customer_id = us.customer_id

    GROUP BY data_segment, sp.plan_name, ao.add_on_name
)

-- =========================
-- FINAL OUTPUT
-- =========================
SELECT
    a.data_segment,
    a.plan_name,
    a.base_arpu,
    a.addon_arpu,
    a.total_arpu,
    ar.add_on_name AS top_addon,
    ar.addon_count AS top_addon_users
FROM arpu_segment_plan a
LEFT JOIN addon_rank ar
    ON ar.data_segment = a.data_segment
   AND ar.plan_name = a.plan_name
   AND ar.rn = 1
ORDER BY
    a.data_segment,
    a.total_arpu DESC;
