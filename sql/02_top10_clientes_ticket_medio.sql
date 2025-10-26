WITH base as (
	SELECT
	c.customer_id,
	c.company_name,
	COUNT(DISTINCT o.order_id) AS total_pedidos,
	SUM((od.unit_price  * od.quantity) * (1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o ON o.order_id = od.order_id
						  INNER JOIN customers c ON c.customer_id = o.customer_id
	group by c.customer_id, c.company_name
)
SELECT
	company_name,
	total_pedidos,
	ROUND(receita,2) AS receita_total,
	ROUND(receita/NULLIF(total_pedidos,0),2) AS ticket_medio
FROM base
ORDER BY receita_total DESC
LIMIT 10