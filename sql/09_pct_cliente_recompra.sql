WITH pedidos AS (
  SELECT customer_id, 
  COUNT(DISTINCT order_id) AS qtd_pedidos
  FROM orders
  GROUP BY 1
)
SELECT
  ROUND(SUM(CASE WHEN qtd_pedidos > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS taxa_recompra_pct
FROM pedidos;