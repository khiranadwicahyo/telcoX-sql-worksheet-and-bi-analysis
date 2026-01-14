SELECT
	cp.customer_id,
	cp.plan_id,
	sp.plan_name,
	round(avg(us.data_usage)::numeric, 2) as avg_data_usage,
	sp.data_quota
FROM customer_profile cp
JOIN subscription_plan sp ON sp.plan_id = cp.plan_id
JOIN usage_activity us on us.customer_id = cp.customer_id
GROUP BY cp.customer_id, sp.plan_name, sp.data_quota
HAVING AVG(us.data_usage) < sp.data_quota * 0.3
ORDER BY avg_data_usage ASC;