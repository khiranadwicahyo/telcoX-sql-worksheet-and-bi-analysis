SELECT 
    segment,
    COUNT(*) FILTER (WHERE tenure_month < 3) AS high_risk,
    COUNT(*) FILTER (WHERE tenure_month BETWEEN 3 AND 12) AS medium_risk,
    COUNT(*) FILTER (WHERE tenure_month > 12) AS low_risk
FROM customer_profile
GROUP BY segment;
