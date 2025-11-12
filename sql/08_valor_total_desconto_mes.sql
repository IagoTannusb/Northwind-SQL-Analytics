WITH base AS (
SELECT 
o.order_date,
od.unit_price,
od.quantity,
(od.unit_price * od.quantity)::numeric(12,2) AS valor_bruto,
(od.unit_price * od.quantity * (1 - od.discount))::numeric(12,2) AS receita_liquida
FROM orders o INNER JOIN order_details od ON o.order_id = od.order_id
)

SELECT 
	EXTRACT(YEAR FROM order_date)::int AS ano_num,
	EXTRACT(MONTH FROM order_date)::int AS mes_num,
	SUM(valor_bruto) - SUM(receita_liquida) AS valor_descontado,
	SUM(valor_bruto) AS valor_bruto,
	SUM(receita_liquida) AS receita_liquida
FROM base
GROUP BY 1,2
ORDER BY 1,2