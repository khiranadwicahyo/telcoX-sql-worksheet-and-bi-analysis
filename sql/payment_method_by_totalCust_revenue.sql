-- SELECT 
--     sp.plan_name,
--     SUM(b.total_spend_last_12m) as total_revenue,
--     SUM(b.total_spend_last_12m) FILTER (WHERE b.payment_method = 'AutoPay') AS autopay,
--     SUM(b.total_spend_last_12m) FILTER (WHERE b.payment_method = 'Credit Card') AS credit_card,
--     SUM(b.total_spend_last_12m) FILTER (WHERE b.payment_method = 'E-Wallet') AS e_wallet,
--     SUM(b.total_spend_last_12m) FILTER (WHERE b.payment_method = 'Virtual Account') AS virtual_account
-- FROM customer_profile cp
-- JOIN subscription_plan sp ON sp.plan_id = cp.plan_id
-- JOIN billing b on b.customer_id = cp.customer_id
-- GROUP BY sp.plan_name
-- ORDER BY total_revenue DESC;

SELECT 
    payment_method,
    COUNT(*) AS total_customers,
    ROUND(AVG(monthly_charge)) AS avg_revenue
FROM billing
GROUP BY payment_method
ORDER BY avg_revenue DESC;
