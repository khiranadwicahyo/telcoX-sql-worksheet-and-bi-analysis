select 
	sp.plan_name,
	round(avg(b.monthly_charge)) as ARPU,
	MIN(b.monthly_charge) AS min_charge,
    MAX(b.monthly_charge) AS max_charge
FROM customer_profile cp
JOIN subscription_plan sp ON sp.plan_id = cp.plan_id
JOIN billing b on b.customer_id = cp.customer_id
GROUP BY sp.plan_name
ORDER BY ARPU DESC;