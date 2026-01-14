SELECT 
    sp.plan_name,
    COUNT(cp.customer_id) AS total_customers,
    ROUND(AVG(cp.age), 1) AS avg_age,
    COUNT(*) FILTER (WHERE cp.segment = 'Youth') AS youth,
    COUNT(*) FILTER (WHERE cp.segment = 'Adult') AS adult,
    COUNT(*) FILTER (WHERE cp.segment = 'Senior') AS senior
FROM customer_profile cp
JOIN subscription_plan sp ON sp.plan_id = cp.plan_id
GROUP BY sp.plan_name
ORDER BY total_customers DESC;
