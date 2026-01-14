SELECT
	cp.customer_id,
	CASE
		WHEN AVG(us.data_usage) > 20 THEN 'Heavy Data User'
		WHEN AVG(us.data_usage) BETWEEN 10 AND 20 THEN 'Medium User'
		ELSE 'Light User'
	 END AS data_segment,
    ROUND(AVG(us.data_usage)::numeric, 1) AS avg_gb
FROM customer_profile cp
JOIN usage_activity us on us.customer_id = cp.customer_id
GROUP BY cp.customer_id
ORDER BY avg_gb DESC;