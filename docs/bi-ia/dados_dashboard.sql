WITH tp AS (
  SELECT p.*, t.valor_total FROM pedido p JOIN v_pedido_total t USING (id_pedido)
  WHERE p.status NOT IN ('pendente','cancelado')
)
SELECT json_build_object(
 'semanas', (SELECT json_agg(x ORDER BY semana) FROM (
    SELECT to_char(date_trunc('week', data_pedido),'YYYY-MM-DD') semana,
      COALESCE(SUM(valor_total) FILTER (WHERE canal_venda='loja_fisica'),0) fisica,
      COALESCE(SUM(valor_total) FILTER (WHERE canal_venda='loja_virtual'),0) virtual,
      COUNT(*) pedidos
    FROM tp GROUP BY 1) x),
 'kpi', (SELECT json_build_object(
    'faturamento', SUM(valor_total), 'pedidos', COUNT(*), 'ticket', ROUND(AVG(valor_total),2),
    'pct_virtual', ROUND(100.0*COUNT(*) FILTER (WHERE canal_venda='loja_virtual')/COUNT(*),1),
    'clientes', COUNT(DISTINCT id_cliente),
    'recompra', (SELECT ROUND(100.0*COUNT(*) FILTER (WHERE n>1)/COUNT(*),1) FROM (SELECT id_cliente, COUNT(*) n FROM tp GROUP BY 1) c),
    'cancel', (SELECT ROUND(100.0*COUNT(*) FILTER (WHERE status='cancelado')/COUNT(*),1) FROM pedido)
   ) FROM tp),
 'meses', (SELECT json_agg(x ORDER BY mes) FROM (
    SELECT to_char(data_pedido,'YYYY-MM') mes, SUM(valor_total) faturamento, COUNT(*) pedidos, ROUND(AVG(valor_total),2) ticket
    FROM tp GROUP BY 1) x),
 'produtos', (SELECT json_agg(x) FROM (
    SELECT pr.nome, SUM(ip.quantidade) unidades, SUM(ip.quantidade*ip.preco_unitario) receita,
      SUM(ip.quantidade*ip.preco_unitario) - SUM(ip.quantidade)*(SELECT ROUND(AVG(custo_unitario),2) FROM item_compra ic WHERE ic.id_produto=pr.id_produto) margem
    FROM tp JOIN item_pedido ip USING (id_pedido) JOIN produto pr USING (id_produto)
    GROUP BY pr.id_produto, pr.nome ORDER BY receita DESC LIMIT 8) x),
 'categorias', (SELECT json_agg(x) FROM (
    SELECT c.nome, SUM(ip.quantidade*ip.preco_unitario) receita
    FROM tp JOIN item_pedido ip USING (id_pedido) JOIN produto pr USING (id_produto) JOIN categoria c USING (id_categoria)
    GROUP BY c.nome ORDER BY receita DESC) x),
 'formas', (SELECT json_agg(x) FROM (
    SELECT forma_pagamento forma, COUNT(*) qtd, SUM(valor) valor FROM pagamento WHERE status='autorizado' GROUP BY 1 ORDER BY 3 DESC) x),
 'financeiro', (SELECT json_build_object(
    'recebido', (SELECT SUM(valor_liquido) FROM conta_receber WHERE status='recebida'),
    'a_receber', (SELECT SUM(valor_liquido) FROM conta_receber WHERE status='pendente'),
    'taxas', (SELECT SUM(valor_bruto-valor_liquido) FROM conta_receber WHERE status<>'cancelada'),
    'a_pagar', (SELECT SUM(saldo_devedor) FROM v_conta_pagar_saldo WHERE status<>'cancelada'))),
 'receber_mes', (SELECT json_agg(x ORDER BY mes) FROM (
    SELECT to_char(data_prevista,'YYYY-MM') mes, SUM(valor_liquido) valor FROM conta_receber WHERE status='pendente' GROUP BY 1) x),
 'pagar_mes', (SELECT json_agg(x ORDER BY mes) FROM (
    SELECT to_char(data_vencimento,'YYYY-MM') mes, SUM(saldo_devedor) valor FROM v_conta_pagar_saldo WHERE saldo_devedor>0 GROUP BY 1) x),
 'estoque_min', (SELECT json_agg(x) FROM (
    SELECT p.nome, p.estoque_minimo minimo,
      COALESCE(SUM(s.quantidade_disponivel) FILTER (WHERE l.data_validade IS NULL OR l.data_validade >= DATE '2026-10-27'),0) disponivel
    FROM produto p LEFT JOIN lote l USING (id_produto) LEFT JOIN v_lote_saldo s USING (id_lote)
    GROUP BY p.id_produto, p.nome, p.estoque_minimo
    HAVING COALESCE(SUM(s.quantidade_disponivel) FILTER (WHERE l.data_validade IS NULL OR l.data_validade >= DATE '2026-10-27'),0) <= p.estoque_minimo
    ORDER BY p.estoque_minimo - COALESCE(SUM(s.quantidade_disponivel) FILTER (WHERE l.data_validade IS NULL OR l.data_validade >= DATE '2026-10-27'),0) DESC) x),
 'lotes_vencer', (SELECT json_agg(x) FROM (
    SELECT pr.nome, l.codigo_lote lote, to_char(l.data_validade,'DD/MM/YYYY') validade, l.data_validade - DATE '2026-10-27' dias, s.saldo_fisico saldo
    FROM lote l JOIN produto pr USING (id_produto) JOIN v_lote_saldo s USING (id_lote)
    WHERE s.saldo_fisico > 0 AND l.data_validade <= DATE '2026-10-27' + 30 ORDER BY l.data_validade) x),
 'perdas', (SELECT json_build_object('unidades', SUM(m.quantidade), 'custo', SUM(m.quantidade * (SELECT ROUND(AVG(custo_unitario),2) FROM item_compra ic WHERE ic.id_produto=m.id_produto)))
    FROM movimentacao_estoque m WHERE m.tipo='perda'),
 'periodo', json_build_object('inicio', (SELECT to_char(MIN(data_pedido),'DD/MM/YYYY') FROM tp), 'fim', (SELECT to_char(MAX(data_pedido),'DD/MM/YYYY') FROM tp))
);
