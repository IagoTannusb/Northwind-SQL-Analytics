WITH base as (
	SELECT
		o.order_date::date AS order_date,
		EXTRACT(YEAR FROM o.order_date)::int as ano,
		EXTRACT(MONTH FROM O.order_date)::int as mes_num,
		((od.unit_price * od.quantity) *(1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o on o.order_id = od.order_id
), acumulado_mes as (
	SELECT
		ano,
		mes_num,
		sum(receita) as receita_total
	FROM base
	GROUP BY ano, mes_num
)
select
	ano,
	mes_num,
	receita_total,
	sum(receita_total) over (
		PARTITION BY ano 
	    ORDER BY mes_num 
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS receita_ytd
from acumulado_mes
order by ano, mes_num