WITH base as (
	SELECT
		c.category_name,
		p.product_name,
		od.quantity,
		((od.unit_price * od.quantity) *(1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o on o.order_id = od.order_id
						  INNER JOIN products p on p.product_id = od.product_id
						  INNER JOIN categories c ON c.category_id = p.category_id 
)
SELECT 
	category_name,
	product_name,
	SUM(quantity) as unidades_vendidas,
	round(SUM(receita), 2) as receita_total,
	RANK() OVER (PARTITION BY category_name ORDER BY SUM(receita) DESC) as posicao_categoria
FROM base
group by category_name, product_name