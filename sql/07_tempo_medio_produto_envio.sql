WITH base AS (
	SELECT
		s.company_name as transportadora,
		o.shipped_date,
		o.order_date,
		o.required_date,
		o.order_id
	FROM orders o INNER JOIN order_details od ON o.order_id = od.order_id
				  INNER JOIN shippers s ON o.ship_via = s.shipper_id
)
SELECT 
	transportadora,
	ROUND(AVG(shipped_date - order_date), 2) media_dias_envio,
	ROUND(AVG(CASE WHEN shipped_date <= required_date THEN 1 ELSE 0 END) * 100, 2) AS pct_no_prazo
FROM base
GROUP BY transportadora
