SELECT
    product_name AS produto,
    units_in_stock AS estoque_atual,
    units_on_order AS em_pedido,
    reorder_level AS minimo_exigido,
    (units_in_stock + units_on_order) AS estoque_total,
    (reorder_level - (units_in_stock + units_on_order)) AS faltam_para_repor
FROM products
WHERE (units_in_stock + units_on_order) <= reorder_level
  AND reorder_level > 0
  AND discontinued = 0 
ORDER BY faltam_para_repor DESC, estoque_total ASC;