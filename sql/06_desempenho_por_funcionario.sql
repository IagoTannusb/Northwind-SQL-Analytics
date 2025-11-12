WITH base AS (
	SELECT
		e.first_name,
		e.last_name,
		o.order_id,
        (od.unit_price * od.quantity * (1 - od.discount))::numeric(12,2) AS receita
	FROM orders o INNER JOIN order_details od ON o.order_id = od.order_id
				  INNER JOIN employees e ON o.employee_id = e.employee_id
), agrupado AS (
	SELECT 
		first_name || ' ' || last_name AS funcionario,
		COUNT(DISTINCT order_id) AS pedidos,
		ROUND(SUM(receita), 2) AS receita_total
	FROM base
	GROUP BY 1
	ORDER BY receita_total DESC
)
SELECT
	funcionario,
	pedidos,
	receita_total
FROM agrupado;