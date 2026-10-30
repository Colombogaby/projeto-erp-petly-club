-- ============================================================================
-- PROJETO ERP PETLY CLUB - CONSULTAS DE AUDITORIA
-- ============================================================================
-- Grupo 7 | SGBD: PostgreSQL 16
-- Uso de IA: consultas elaboradas com auxílio de IA (Claude). Todas foram executadas e conferidas
-- pela equipe no banco do grupo.
-- Pré-requisito: petly_club_ddl_limpo.sql + Massa_de_Dados_Completa_-_ERP_Petly_Club.sql
-- Na base do grupo, todas as consultas devem retornar 0 linhas (dados consistentes).
-- Como rodar: psql -d petly_club -f consultas_auditoria.sql
-- ============================================================================

-- [AU01] Pedidos concluídos sem pagamento suficiente
-- Regra: RN15, RN16
-- O que verifica: Procura pedidos já concluídos (pago, enviado, entregue ou retirado) em que a soma dos pagamentos autorizados é diferente do valor total do pedido. O banco não impede isso sozinho: a conferência fica na aplicação ([TRG-11]).
-- Decisão: Conferir o caixa do dia e o pagamento com o cliente ou com a operadora antes do fechamento (RF26).
\echo '[AU01] Pedidos concluídos sem pagamento suficiente'
SELECT p.id_pedido, p.canal_venda, p.status,
       t.valor_total,
       COALESCE(SUM(g.valor) FILTER (WHERE g.status = 'autorizado'), 0) AS pago_autorizado
FROM pedido p
JOIN v_pedido_total t ON t.id_pedido = p.id_pedido
LEFT JOIN pagamento g ON g.id_pedido = p.id_pedido
WHERE p.status IN ('pago', 'enviado', 'entregue', 'retirado')
GROUP BY p.id_pedido, p.canal_venda, p.status, t.valor_total
HAVING COALESCE(SUM(g.valor) FILTER (WHERE g.status = 'autorizado'), 0) <> t.valor_total
ORDER BY p.id_pedido;

-- [AU02] Pedidos sem itens
-- Regra: RN03
-- O que verifica: Procura pedidos que não têm nenhum produto. Todo pedido precisa de pelo menos um item, mas como o item é que aponta para o pedido, uma FK não garante isso ([TRG-10]).
-- Decisão: Cancelar ou completar o pedido; pedido vazio distorce os relatórios de vendas e o ticket médio.
\echo '[AU02] Pedidos sem itens'
SELECT p.id_pedido, p.data_pedido, p.canal_venda, p.status
FROM pedido p
WHERE NOT EXISTS (SELECT 1 FROM item_pedido i WHERE i.id_pedido = p.id_pedido)
ORDER BY p.id_pedido;

-- [AU03] Itens vendidos sem baixa correta no estoque
-- Regra: RN20, RN21
-- O que verifica: Compara, em cada item de pedido concluído, a quantidade vendida com o que saiu dos lotes (vendas menos devoluções). Se for diferente, o estoque físico não bate com as vendas.
-- Decisão: Registrar a movimentação de venda que faltou, no lote correto (FEFO), ou investigar se o produto saiu sem registro.
\echo '[AU03] Itens vendidos sem baixa correta no estoque'
SELECT i.id_pedido, i.id_produto, i.quantidade AS vendido,
       COALESCE(SUM(CASE WHEN m.tipo = 'venda' THEN m.quantidade
                         WHEN m.tipo = 'devolucao' THEN -m.quantidade END), 0) AS baixado
FROM item_pedido i
JOIN pedido p ON p.id_pedido = i.id_pedido
LEFT JOIN movimentacao_estoque m ON m.id_pedido = i.id_pedido AND m.id_produto = i.id_produto
WHERE p.status IN ('pago', 'enviado', 'entregue', 'retirado')
GROUP BY i.id_pedido, i.id_produto, i.quantidade
HAVING COALESCE(SUM(CASE WHEN m.tipo = 'venda' THEN m.quantidade
                         WHEN m.tipo = 'devolucao' THEN -m.quantidade END), 0) <> i.quantidade
ORDER BY i.id_pedido, i.id_produto;

-- [AU04] Reservas presas em pedidos encerrados
-- Regra: RN21, RN22
-- O que verifica: Procura reservas que continuam abertas em pedidos cancelados, entregues ou retirados. Uma reserva esquecida deixa o produto indisponível para venda sem que ele tenha saído do estoque.
-- Decisão: Registrar a liberação da reserva para devolver a quantidade ao disponível do catálogo (RF17).
\echo '[AU04] Reservas presas em pedidos encerrados'
SELECT p.id_pedido, p.status, m.id_lote, m.id_produto,
       SUM(CASE WHEN m.tipo = 'reserva' THEN m.quantidade
                WHEN m.tipo IN ('liberacao_reserva', 'venda') THEN -m.quantidade
                ELSE 0 END) AS reserva_em_aberto
FROM movimentacao_estoque m
JOIN pedido p ON p.id_pedido = m.id_pedido
WHERE p.canal_venda = 'loja_virtual'
  AND p.status IN ('cancelado', 'entregue', 'retirado')
GROUP BY p.id_pedido, p.status, m.id_lote, m.id_produto
HAVING SUM(CASE WHEN m.tipo = 'reserva' THEN m.quantidade
                WHEN m.tipo IN ('liberacao_reserva', 'venda') THEN -m.quantidade
                ELSE 0 END) > 0
ORDER BY p.id_pedido;

-- [AU05] Pagamentos e contas a receber que não batem
-- Regra: RN22, RN24
-- O que verifica: Confere o financeiro de cada pagamento: autorizado tem de ter contas a receber que somam o seu valor; recusado ou pendente não pode ter conta; estornado só pode ter contas canceladas.
-- Decisão: Corrigir o lançamento antes do fechamento: um valor previsto a mais ou a menos distorce o fluxo de caixa (RF37).
\echo '[AU05] Pagamentos e contas a receber que não batem'
SELECT g.id_pagamento, g.id_pedido, g.forma_pagamento, g.status, g.valor,
       COALESCE(SUM(c.valor_bruto), 0) AS soma_contas,
       COUNT(c.*) FILTER (WHERE c.status <> 'cancelada') AS contas_ativas
FROM pagamento g
LEFT JOIN conta_receber c ON c.id_pagamento = g.id_pagamento
GROUP BY g.id_pagamento, g.id_pedido, g.forma_pagamento, g.status, g.valor
HAVING (g.status = 'autorizado' AND COALESCE(SUM(c.valor_bruto), 0) <> g.valor)
    OR (g.status IN ('pendente', 'recusado') AND COUNT(c.*) > 0)
    OR (g.status = 'estornado' AND COUNT(c.*) FILTER (WHERE c.status <> 'cancelada') > 0)
ORDER BY g.id_pagamento;

-- [AU06] Compras com recebimento ou financeiro inconsistente
-- Regra: RN12, RN25
-- O que verifica: Compara o status de cada compra com o que realmente chegou (entradas por item) e o total da compra com a soma das parcelas a pagar ([TRG-06], [TRG-09]).
-- Decisão: Cobrar do fornecedor o que falta entregar ou corrigir as parcelas antes do vencimento.
\echo '[AU06] Compras com recebimento ou financeiro inconsistente'
WITH receb AS (
    SELECT r.id_compra,
           SUM(r.quantidade_comprada) AS comprado,
           SUM(LEAST(r.quantidade_recebida, r.quantidade_comprada)) AS recebido
    FROM v_item_compra_recebido r GROUP BY r.id_compra),
fin AS (SELECT id_compra, SUM(valor) AS parcelas FROM conta_pagar GROUP BY id_compra)
SELECT c.id_compra, c.status, r.comprado, r.recebido,
       t.valor_total, COALESCE(f.parcelas, 0) AS parcelas
FROM compra c
JOIN receb r ON r.id_compra = c.id_compra
JOIN v_compra_total t ON t.id_compra = c.id_compra
LEFT JOIN fin f ON f.id_compra = c.id_compra
WHERE c.status <> 'cancelada'
  AND (   (c.status = 'recebida' AND r.recebido < r.comprado)
       OR (c.status = 'recebida_parcialmente' AND (r.recebido = 0 OR r.recebido >= r.comprado))
       OR (c.status = 'solicitada' AND r.recebido > 0)
       OR COALESCE(f.parcelas, 0) <> t.valor_total)
ORDER BY c.id_compra;

-- [AU07] Lotes vencidos ainda com saldo
-- Regra: RF12, RP09
-- O que verifica: Procura lotes cuja validade já passou e que ainda têm unidades no estoque. Esses produtos não podem ser vendidos e precisam sair por perda.
-- Decisão: Retirar o lote da prateleira e registrar a perda com autorização da gerência (RP11).
\echo '[AU07] Lotes vencidos ainda com saldo'
SELECT l.id_lote, pr.nome, l.codigo_lote, l.data_validade,
       CURRENT_DATE - l.data_validade AS dias_vencido,
       s.saldo_fisico
FROM lote l
JOIN produto pr ON pr.id_produto = l.id_produto
JOIN v_lote_saldo s ON s.id_lote = l.id_lote
WHERE l.data_validade < CURRENT_DATE
  AND s.saldo_fisico > 0
ORDER BY l.data_validade;

-- [AU08] Perdas e ajustes autorizados por quem não é gerente
-- Regra: RP08, RP11
-- O que verifica: Confere quem autorizou cada perda e ajuste de estoque. O CHECK exige um autorizador, mas não sabe o cargo dele; a regra de que só a gerência autoriza fica nas permissões ([TRG-17]).
-- Decisão: Revisar a perda com a gerência e corrigir as permissões de quem autorizou.
\echo '[AU08] Perdas e ajustes autorizados por quem não é gerente'
SELECT m.id_movimentacao, m.data_hora, m.tipo, m.quantidade, m.motivo,
       a.nome AS autorizador, a.cargo
FROM movimentacao_estoque m
JOIN funcionario a ON a.id_funcionario = m.id_autorizador
WHERE m.tipo IN ('perda', 'ajuste_positivo', 'ajuste_negativo')
  AND a.cargo <> 'gerente'
ORDER BY m.data_hora;

-- [AU09] Descontos sem autorização registrada
-- Regra: RP05, RF32
-- O que verifica: Lista os pedidos com desconto que não têm o gerente que autorizou. O limite de desconto é parâmetro da aplicação, então a consulta mostra todos para conferência.
-- Decisão: Confirmar com a gerência se o desconto foi autorizado e, se não foi, tratar com o funcionário.
\echo '[AU09] Descontos sem autorização registrada'
SELECT p.id_pedido, p.data_pedido, p.canal_venda, p.desconto,
       t.valor_itens, f.nome AS registrado_por
FROM pedido p
JOIN v_pedido_total t ON t.id_pedido = p.id_pedido
LEFT JOIN funcionario f ON f.id_funcionario = p.id_funcionario
WHERE p.desconto > 0
  AND p.id_autorizador_desconto IS NULL
ORDER BY p.desconto DESC;

-- [AU10] Cadastros de clientes possivelmente duplicados
-- Regra: RN18, RF03
-- O que verifica: O CPF não se repete (UNIQUE), mas o mesmo cliente pode ter sido cadastrado duas vezes com CPF digitado errado. A consulta procura clientes diferentes com o mesmo e-mail ou o mesmo telefone.
-- Decisão: Confirmar com o cliente qual cadastro é o correto e unificar o histórico de compras no cadastro certo.
\echo '[AU10] Cadastros de clientes possivelmente duplicados'
SELECT c1.id_cliente, c1.nome, c1.cpf,
       c2.id_cliente AS possivel_duplicado, c2.nome AS nome_duplicado, c2.cpf AS cpf_duplicado,
       CASE WHEN c1.email = c2.email THEN 'mesmo e-mail' ELSE 'mesmo telefone' END AS motivo
FROM cliente c1
JOIN cliente c2 ON c2.id_cliente > c1.id_cliente
               AND (c1.email = c2.email OR c1.telefone = c2.telefone)
ORDER BY c1.id_cliente;

-- ============================================================================
-- TESTES DAS CONSULTAS: cada bloco insere um erro proposital que o banco aceita,
-- roda a consulta (que deve encontrá-lo) e desfaz tudo com ROLLBACK.
-- ============================================================================

-- Teste da AU01: Um pedido marcado como 'pago' sem nenhum pagamento registrado.
\echo 'Teste da AU01'
BEGIN;
INSERT INTO pedido (id_pedido, canal_venda, tipo_recebimento, status, id_cliente, id_funcionario) OVERRIDING SYSTEM VALUE
VALUES (90, 'loja_fisica', 'balcao', 'pago', 1, 2);
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES (90, 5, 1, 74.90);
SELECT p.id_pedido, p.canal_venda, p.status,
       t.valor_total,
       COALESCE(SUM(g.valor) FILTER (WHERE g.status = 'autorizado'), 0) AS pago_autorizado
FROM pedido p
JOIN v_pedido_total t ON t.id_pedido = p.id_pedido
LEFT JOIN pagamento g ON g.id_pedido = p.id_pedido
WHERE p.status IN ('pago', 'enviado', 'entregue', 'retirado')
GROUP BY p.id_pedido, p.canal_venda, p.status, t.valor_total
HAVING COALESCE(SUM(g.valor) FILTER (WHERE g.status = 'autorizado'), 0) <> t.valor_total
ORDER BY p.id_pedido;
ROLLBACK;

-- Teste da AU02: Um pedido aberto na loja virtual sem nenhum produto.
\echo 'Teste da AU02'
BEGIN;
INSERT INTO pedido (id_pedido, canal_venda, tipo_recebimento, id_cliente) OVERRIDING SYSTEM VALUE
VALUES (91, 'loja_virtual', 'entrega', 2);
SELECT p.id_pedido, p.data_pedido, p.canal_venda, p.status
FROM pedido p
WHERE NOT EXISTS (SELECT 1 FROM item_pedido i WHERE i.id_pedido = p.id_pedido)
ORDER BY p.id_pedido;
ROLLBACK;

-- Teste da AU03: O pedido vendeu 3 shampoos, mas só 1 saiu do lote.
\echo 'Teste da AU03'
BEGIN;
INSERT INTO pedido (id_pedido, canal_venda, tipo_recebimento, status, id_cliente, id_funcionario) OVERRIDING SYSTEM VALUE
VALUES (92, 'loja_fisica', 'balcao', 'pago', 4, 2);
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES (92, 2, 3, 29.90);
INSERT INTO movimentacao_estoque (tipo, quantidade, id_lote, id_produto, id_funcionario, id_pedido)
VALUES ('venda', 1, 3, 2, 2, 92);
SELECT i.id_pedido, i.id_produto, i.quantidade AS vendido,
       COALESCE(SUM(CASE WHEN m.tipo = 'venda' THEN m.quantidade
                         WHEN m.tipo = 'devolucao' THEN -m.quantidade END), 0) AS baixado
FROM item_pedido i
JOIN pedido p ON p.id_pedido = i.id_pedido
LEFT JOIN movimentacao_estoque m ON m.id_pedido = i.id_pedido AND m.id_produto = i.id_produto
WHERE p.status IN ('pago', 'enviado', 'entregue', 'retirado')
GROUP BY i.id_pedido, i.id_produto, i.quantidade
HAVING COALESCE(SUM(CASE WHEN m.tipo = 'venda' THEN m.quantidade
                         WHEN m.tipo = 'devolucao' THEN -m.quantidade END), 0) <> i.quantidade
ORDER BY i.id_pedido, i.id_produto;
ROLLBACK;

-- Teste da AU04: O pedido foi cancelado, mas as 2 unidades reservadas nunca foram liberadas.
\echo 'Teste da AU04'
BEGIN;
INSERT INTO pedido (id_pedido, canal_venda, tipo_recebimento, status, id_cliente) OVERRIDING SYSTEM VALUE
VALUES (93, 'loja_virtual', 'entrega', 'cancelado', 5);
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES (93, 5, 2, 74.90);
INSERT INTO movimentacao_estoque (tipo, quantidade, id_lote, id_produto, id_pedido)
VALUES ('reserva', 2, 7, 5, 93);
SELECT p.id_pedido, p.status, m.id_lote, m.id_produto,
       SUM(CASE WHEN m.tipo = 'reserva' THEN m.quantidade
                WHEN m.tipo IN ('liberacao_reserva', 'venda') THEN -m.quantidade
                ELSE 0 END) AS reserva_em_aberto
FROM movimentacao_estoque m
JOIN pedido p ON p.id_pedido = m.id_pedido
WHERE p.canal_venda = 'loja_virtual'
  AND p.status IN ('cancelado', 'entregue', 'retirado')
GROUP BY p.id_pedido, p.status, m.id_lote, m.id_produto
HAVING SUM(CASE WHEN m.tipo = 'reserva' THEN m.quantidade
                WHEN m.tipo IN ('liberacao_reserva', 'venda') THEN -m.quantidade
                ELSE 0 END) > 0
ORDER BY p.id_pedido;
ROLLBACK;

-- Teste da AU05: Um Pix autorizado que não gerou conta a receber.
\echo 'Teste da AU05'
BEGIN;
INSERT INTO pagamento (id_pedido, forma_pagamento, valor, numero_parcelas, data_autorizacao, status)
VALUES (1, 'pix', 10.00, 1, '2026-10-20 11:00', 'autorizado');
SELECT g.id_pagamento, g.id_pedido, g.forma_pagamento, g.status, g.valor,
       COALESCE(SUM(c.valor_bruto), 0) AS soma_contas,
       COUNT(c.*) FILTER (WHERE c.status <> 'cancelada') AS contas_ativas
FROM pagamento g
LEFT JOIN conta_receber c ON c.id_pagamento = g.id_pagamento
GROUP BY g.id_pagamento, g.id_pedido, g.forma_pagamento, g.status, g.valor
HAVING (g.status = 'autorizado' AND COALESCE(SUM(c.valor_bruto), 0) <> g.valor)
    OR (g.status IN ('pendente', 'recusado') AND COUNT(c.*) > 0)
    OR (g.status = 'estornado' AND COUNT(c.*) FILTER (WHERE c.status <> 'cancelada') > 0)
ORDER BY g.id_pagamento;
ROLLBACK;

-- Teste da AU06: Uma compra marcada como 'recebida' sem nenhuma entrada e sem conta a pagar.
\echo 'Teste da AU06'
BEGIN;
INSERT INTO compra (id_compra, data_compra, status, id_fornecedor) OVERRIDING SYSTEM VALUE
VALUES (90, '2026-10-26', 'recebida', 3);
INSERT INTO item_compra (id_compra, id_produto, quantidade_comprada, custo_unitario) VALUES (90, 4, 10, 8.00);
WITH receb AS (
    SELECT r.id_compra,
           SUM(r.quantidade_comprada) AS comprado,
           SUM(LEAST(r.quantidade_recebida, r.quantidade_comprada)) AS recebido
    FROM v_item_compra_recebido r GROUP BY r.id_compra),
fin AS (SELECT id_compra, SUM(valor) AS parcelas FROM conta_pagar GROUP BY id_compra)
SELECT c.id_compra, c.status, r.comprado, r.recebido,
       t.valor_total, COALESCE(f.parcelas, 0) AS parcelas
FROM compra c
JOIN receb r ON r.id_compra = c.id_compra
JOIN v_compra_total t ON t.id_compra = c.id_compra
LEFT JOIN fin f ON f.id_compra = c.id_compra
WHERE c.status <> 'cancelada'
  AND (   (c.status = 'recebida' AND r.recebido < r.comprado)
       OR (c.status = 'recebida_parcialmente' AND (r.recebido = 0 OR r.recebido >= r.comprado))
       OR (c.status = 'solicitada' AND r.recebido > 0)
       OR COALESCE(f.parcelas, 0) <> t.valor_total)
ORDER BY c.id_compra;
ROLLBACK;

-- Teste da AU07: Um lote de ração para gatos que venceu em 15/10/2026 e ainda tem 4 unidades.
\echo 'Teste da AU07'
BEGIN;
INSERT INTO lote (id_lote, codigo_lote, data_entrada, data_validade, id_produto) OVERRIDING SYSTEM VALUE
VALUES (90, 'LOTE-GAT-VENC', '2026-08-01', '2026-10-15', 5);
INSERT INTO item_compra (id_compra, id_produto, quantidade_comprada, custo_unitario) VALUES (102, 5, 4, 40.00);
INSERT INTO movimentacao_estoque (tipo, quantidade, data_hora, id_lote, id_produto, id_funcionario, id_compra)
VALUES ('entrada', 4, '2026-08-01 09:00', 90, 5, 3, 102);
SELECT l.id_lote, pr.nome, l.codigo_lote, l.data_validade,
       CURRENT_DATE - l.data_validade AS dias_vencido,
       s.saldo_fisico
FROM lote l
JOIN produto pr ON pr.id_produto = l.id_produto
JOIN v_lote_saldo s ON s.id_lote = l.id_lote
WHERE l.data_validade < CURRENT_DATE
  AND s.saldo_fisico > 0
ORDER BY l.data_validade;
ROLLBACK;

-- Teste da AU08: Uma perda autorizada pelo estoquista Roberto, que não é gerente.
\echo 'Teste da AU08'
BEGIN;
INSERT INTO movimentacao_estoque (tipo, quantidade, motivo, id_lote, id_produto, id_funcionario, id_autorizador)
VALUES ('perda', 1, 'Embalagem rasgada', 2, 1, 4, 3);
SELECT m.id_movimentacao, m.data_hora, m.tipo, m.quantidade, m.motivo,
       a.nome AS autorizador, a.cargo
FROM movimentacao_estoque m
JOIN funcionario a ON a.id_funcionario = m.id_autorizador
WHERE m.tipo IN ('perda', 'ajuste_positivo', 'ajuste_negativo')
  AND a.cargo <> 'gerente'
ORDER BY m.data_hora;
ROLLBACK;

-- Teste da AU09: Um desconto de R$ 20,00 lançado no pedido 1 sem autorizador.
\echo 'Teste da AU09'
BEGIN;
UPDATE pedido SET desconto = 20.00 WHERE id_pedido = 1;
SELECT p.id_pedido, p.data_pedido, p.canal_venda, p.desconto,
       t.valor_itens, f.nome AS registrado_por
FROM pedido p
JOIN v_pedido_total t ON t.id_pedido = p.id_pedido
LEFT JOIN funcionario f ON f.id_funcionario = p.id_funcionario
WHERE p.desconto > 0
  AND p.id_autorizador_desconto IS NULL
ORDER BY p.desconto DESC;
ROLLBACK;

-- Teste da AU10: A cliente Maria Souza cadastrada de novo, com dois dígitos do CPF trocados.
\echo 'Teste da AU10'
BEGIN;
INSERT INTO cliente (nome, cpf, telefone, email)
VALUES ('Maria Souza', '12345678910', '11988887777', 'maria.souza@email.com');
SELECT c1.id_cliente, c1.nome, c1.cpf,
       c2.id_cliente AS possivel_duplicado, c2.nome AS nome_duplicado, c2.cpf AS cpf_duplicado,
       CASE WHEN c1.email = c2.email THEN 'mesmo e-mail' ELSE 'mesmo telefone' END AS motivo
FROM cliente c1
JOIN cliente c2 ON c2.id_cliente > c1.id_cliente
               AND (c1.email = c2.email OR c1.telefone = c2.telefone)
ORDER BY c1.id_cliente;
ROLLBACK;
