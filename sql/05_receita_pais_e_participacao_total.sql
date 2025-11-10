WITH  base AS (
	SELECT
    	o.ship_country,
    	(od.unit_price * od.quantity * (1 - od.discount))::numeric(12,2) AS receita
	FROM orders o
	JOIN order_details od ON o.order_id = od.order_id
), receita_agrupada AS (
	SELECT 
		ship_country,
		SUM(receita) AS receita
	FROM base 
	GROUP BY ship_country
)
SELECT
	ship_country,
	receita,
	round(receita / SUM(receita) OVER ()  * 100,2) AS pct_total
FROM receita_agrupada
ORDER BY receita DESC;