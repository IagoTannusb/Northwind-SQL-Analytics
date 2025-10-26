WITH base as (
	SELECT
		o.order_date::date AS order_date,
		((od.unit_price * od.quantity) * (1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o on o.order_id = od.order_id
), 
receita_anual AS (
	SELECT
		to_char(order_date, 'YYYY') as ano,
		SUM(receita) as receita_total
	FROM base
	group by 1
), 
variacao as (
	SELECT
		ano,
		receita_total,
		LAG(receita_total) OVER (ORDER BY ano) AS receita_anterior
	FROM receita_anual
)
SELECT
	ano,
	receita_total,
	receita_anterior,
	round((receita_total - receita_anterior) * 100 / NULLIF(receita_anterior, 0),2) as variacao_percentual
FROM variacao	