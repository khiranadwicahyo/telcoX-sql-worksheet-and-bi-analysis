SELECT 
    ad.add_on_name,
    COUNT(*) AS total_customers,
	ROUND(AVG(ad.add_on_price)) AS avg_price,
    ROUND(AVG(b.monthly_charge)) AS avg_revenue
FROM billing b
JOIN add_on_usage ad on ad.customer_id = b.customer_id 
GROUP BY ad.add_on_name
ORDER BY avg_revenue DESC;