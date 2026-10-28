# Nicolas — Consultas gerenciais

SGBD: PostgreSQL 16. As consultas usam as tabelas do modelo lógico e, nas consultas 3 e 4, a visão `v_lote_saldo` (seção 7.1 do modelo lógico), porque o saldo do lote é derivado das movimentações e não fica gravado. Os totais de pedido também são calculados (`quantidade × preco_unitario − desconto`). Todas foram executadas sobre a massa de dados do grupo, com data de referência 27/10/2026.

## 1. Produtos mais vendidos por canal

**Pergunta:** quais são os 5 produtos mais vendidos em cada canal (loja física e loja virtual)?

```sql
WITH vendas AS (
    SELECT p.canal_venda,
           pr.id_produto,
           pr.nome,
           pr.marca,
           SUM(ip.quantidade)                     AS unidades_vendidas,
           SUM(ip.quantidade * ip.preco_unitario) AS receita_bruta
    FROM pedido p
    JOIN item_pedido ip ON ip.id_pedido  = p.id_pedido
    JOIN produto     pr ON pr.id_produto = ip.id_produto
    WHERE p.status NOT IN ('pendente', 'cancelado')
    GROUP BY p.canal_venda, pr.id_produto, pr.nome, pr.marca
),
ranking AS (
    SELECT v.*,
           ROW_NUMBER() OVER (
               PARTITION BY v.canal_venda
               ORDER BY v.unidades_vendidas DESC, v.receita_bruta DESC
           ) AS posicao
    FROM vendas v
)
SELECT canal_venda, posicao, nome, marca, unidades_vendidas, receita_bruta
FROM ranking
WHERE posicao <= 5
ORDER BY canal_venda, posicao;
```

**Informação:** ranking dos 5 itens que mais saem em cada canal, com unidades e receita bruta (antes do desconto do pedido, que é por pedido e não por item).

**Decisão:** priorizar reposição e destaque (vitrine, catálogo online) dos mais vendidos de cada canal e perceber produtos que vendem bem em um canal e mal no outro.

---

## 2. Vendas por período

**Pergunta:** quanto vendemos por mês, em cada canal, e qual o ticket médio?

```sql
WITH total_pedido AS (
    SELECT p.id_pedido,
           p.canal_venda,
           p.data_pedido,
           SUM(ip.quantidade * ip.preco_unitario) - p.desconto AS valor_total
    FROM pedido p
    JOIN item_pedido ip ON ip.id_pedido = p.id_pedido
    WHERE p.status NOT IN ('pendente', 'cancelado')
    GROUP BY p.id_pedido, p.canal_venda, p.data_pedido, p.desconto
)
SELECT TO_CHAR(data_pedido, 'YYYY-MM')  AS mes,
       canal_venda,
       COUNT(*)                         AS qtd_pedidos,
       SUM(valor_total)                 AS faturamento,
       ROUND(AVG(valor_total), 2)       AS ticket_medio
FROM total_pedido
GROUP BY TO_CHAR(data_pedido, 'YYYY-MM'), canal_venda
ORDER BY mes, canal_venda;
```

**Informação:** faturamento líquido de desconto, número de pedidos e ticket médio mês a mês, separados por canal.

**Decisão:** identificar meses fortes e fracos, comparar o crescimento da loja virtual com a física e planejar promoções e compras para os períodos de baixa.

---

## 3. Produtos no estoque mínimo ou abaixo

**Pergunta:** quais produtos estão com o estoque disponível no mínimo ou abaixo dele?

```sql
SELECT pr.id_produto,
       pr.nome,
       pr.marca,
       c.nome                                  AS categoria,
       pr.estoque_minimo,
       COALESCE(SUM(vs.quantidade_disponivel), 0) AS quantidade_disponivel,
       pr.estoque_minimo - COALESCE(SUM(vs.quantidade_disponivel), 0) AS falta_para_o_minimo
FROM produto pr
JOIN categoria c        ON c.id_categoria = pr.id_categoria
LEFT JOIN lote l        ON l.id_produto = pr.id_produto
                       AND (l.data_validade IS NULL OR l.data_validade >= CURRENT_DATE)
LEFT JOIN v_lote_saldo vs ON vs.id_lote = l.id_lote
GROUP BY pr.id_produto, pr.nome, pr.marca, c.nome, pr.estoque_minimo
HAVING COALESCE(SUM(vs.quantidade_disponivel), 0) <= pr.estoque_minimo
ORDER BY falta_para_o_minimo DESC, pr.nome;
```

**Informação:** lista de produtos para repor, com o disponível (saldo físico menos reservas, só de lotes não vencidos) comparado ao `estoque_minimo`.

**Decisão:** gerar a solicitação de compra aos fornecedores, começando pelos itens com maior falta.

---

## 4. Lotes perto de vencer

**Pergunta:** quais lotes com saldo vencem nos próximos 30 dias (ou já venceram)?

```sql
SELECT pr.nome,
       pr.marca,
       l.codigo_lote,
       l.data_validade,
       (l.data_validade - CURRENT_DATE) AS dias_para_vencer,
       vs.saldo_fisico,
       vs.quantidade_disponivel,
       CASE WHEN l.data_validade < CURRENT_DATE THEN 'vencido'
            ELSE 'a vencer' END         AS situacao
FROM lote l
JOIN produto      pr ON pr.id_produto = l.id_produto
JOIN v_lote_saldo vs ON vs.id_lote    = l.id_lote
WHERE l.data_validade IS NOT NULL
  AND l.data_validade <= CURRENT_DATE + 30
  AND vs.saldo_fisico > 0
ORDER BY l.data_validade, pr.nome;
```

**Informação:** lotes com saldo físico que vencem em até 30 dias, mais os que já venceram e ainda têm saldo, com os dias restantes.

**Decisão:** dar saída prioritária aos lotes que vencem primeiro (promoção ou venda antes do prazo) e registrar perda, com autorização da gerência, dos lotes vencidos, já que produto vencido não pode ser vendido.

---

## 5. Valores a receber por mês

**Pergunta:** quanto vamos receber em cada mês, por forma de pagamento?

```sql
SELECT TO_CHAR(cr.data_prevista, 'YYYY-MM')    AS mes,
       pg.forma_pagamento,
       COUNT(*)                                AS qtd_parcelas,
       SUM(cr.valor_bruto)                     AS total_bruto,
       SUM(cr.valor_liquido)                   AS total_liquido,
       SUM(cr.valor_bruto - cr.valor_liquido)  AS taxas
FROM conta_receber cr
JOIN pagamento pg ON pg.id_pagamento = cr.id_pagamento
WHERE cr.status = 'pendente'
GROUP BY TO_CHAR(cr.data_prevista, 'YYYY-MM'), pg.forma_pagamento
ORDER BY mes, pg.forma_pagamento;
```

**Informação:** parcelas ainda não recebidas, agrupadas pelo mês da `data_prevista`, com valor bruto, líquido (após taxa da operadora) e o custo das taxas.

**Decisão:** projetar o fluxo de caixa dos próximos meses, planejar o pagamento das contas a pagar e avaliar o peso das taxas de cada forma de pagamento.
