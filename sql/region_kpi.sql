SELECT 
    cp.region,
	round(avg(b.monthly_charge)) as ARPU,
	round(avg(us.data_usage)) as avg_data_usage
FROM customer_profile cp
JOIN subscription_plan sp ON sp.plan_id = cp.plan_id
JOIN billing b on b.customer_id = cp.customer_id
JOIN usage_activity us on us.customer_id = cp.customer_id
GROUP BY cp.region
ORDER BY arpu DESC;