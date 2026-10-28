-- ============================================================================
-- PROJETO ERP PETLY CLUB - TESTES DE INTEGRIDADE
-- ============================================================================
-- Grupo 7 | SGBD: PostgreSQL 16
-- Pré-requisito: rodar petly_club_ddl_limpo.sql e depois Massa_de_Dados_Completa_-_ERP_Petly_Club.sql.
-- Como rodar: psql -d petly_club -a -f testes_integridade.sql
-- Parte 1 (T01 a T23): comandos que o banco DEVE RECUSAR. Cada um deve terminar em ERROR.
-- Parte 2 (U01 a D01): UPDATE e DELETE que o banco DEVE ACEITAR. Rodam dentro de
-- BEGIN ... ROLLBACK, para a base de testes continuar igual depois da execução.
-- O teste T24 (duas vendas simultâneas) precisa de duas sessões e está no final, em comentário.
-- ============================================================================

\set ON_ERROR_STOP off

-- ============================== PARTE 1: COMANDOS QUE DEVEM SER RECUSADOS ==============================

-- [T01] PK duplicada
-- Regra: Cada categoria é identificada por um único id (identificação única).
-- Restrição: pk_categoria (PRIMARY KEY)
-- Esperado: ERROR. O id 1 já pertence à categoria 'Racoes e Alimentos'.
\echo '[T01] PK duplicada'
INSERT INTO categoria (id_categoria, nome)
OVERRIDING SYSTEM VALUE
VALUES (1, 'Categoria Repetida');

-- [T02] ID digitado manualmente
-- Regra: O identificador é gerado pelo sistema e não muda (GENERATED ALWAYS AS IDENTITY).
-- Restrição: id_cliente GENERATED ALWAYS AS IDENTITY
-- Esperado: ERROR. O banco não aceita que a aplicação escolha o id; ele é sempre gerado.
\echo '[T02] ID digitado manualmente'
INSERT INTO cliente (id_cliente, nome, cpf)
VALUES (50, 'Cliente Teste', '11111111111');

-- [T03] CPF repetido
-- Regra: RN18: o mesmo CPF não pode ser cadastrado duas vezes.
-- Restrição: uk_cliente_cpf (UNIQUE)
-- Esperado: ERROR. O CPF 12345678901 já é da cliente Maria Souza.
\echo '[T03] CPF repetido'
INSERT INTO cliente (nome, cpf, email)
VALUES ('Maria S. Copia', '12345678901', 'outra@email.com');

-- [T04] Código de barras repetido
-- Regra: RNF05: o código de barras localiza um único produto no caixa.
-- Restrição: uk_produto_barras (UNIQUE)
-- Esperado: ERROR. O código 7890000000011 já é da Ração Premium 15kg.
\echo '[T04] Código de barras repetido'
INSERT INTO produto (nome, marca, codigo_barras, preco, controla_validade, id_categoria)
VALUES ('Racao Copia', 'Marca X', '7890000000011', 99.90, TRUE, 1);

-- [T05] Pedido de cliente inexistente
-- Regra: RN01, RP02: todo pedido pertence a um cliente cadastrado.
-- Restrição: fk_pedido_cliente (FOREIGN KEY)
-- Esperado: ERROR. Não existe cliente 999.
\echo '[T05] Pedido de cliente inexistente'
INSERT INTO pedido (canal_venda, tipo_recebimento, id_cliente)
VALUES ('loja_virtual', 'entrega', 999);

-- [T06] Venda saindo do lote de outro produto
-- Regra: RN20 e ajuste [A1]: a unidade vendida sai de um lote do mesmo produto do item.
-- Restrição: fk_mov_lote: FK composta (id_lote, id_produto) → lote
-- Esperado: ERROR. O lote 3 é de Shampoo (produto 2), mas a venda é da Ração (produto 1).
\echo '[T06] Venda saindo do lote de outro produto'
INSERT INTO movimentacao_estoque (tipo, quantidade, id_lote, id_produto, id_funcionario, id_pedido)
VALUES ('venda', 1, 3, 1, 2, 1);

-- [T07] Excluir cliente que tem pedidos
-- Regra: RNF03: o histórico de vendas é mantido (5 anos); nada é apagado em cascata.
-- Restrição: fk_pedido_cliente ON DELETE RESTRICT
-- Esperado: ERROR. A cliente 1 tem o pedido 1; apagar o cadastro deixaria o pedido sem cliente.
\echo '[T07] Excluir cliente que tem pedidos'
DELETE FROM cliente WHERE id_cliente = 1;

-- [T08] Produto sem categoria
-- Regra: RN04: todo produto pertence a uma categoria.
-- Restrição: produto.id_categoria NOT NULL
-- Esperado: ERROR. O produto foi enviado sem categoria.
\echo '[T08] Produto sem categoria'
INSERT INTO produto (nome, marca, codigo_barras, preco, controla_validade)
VALUES ('Coleira P', 'Marca D', '7890000000999', 39.90, FALSE);

-- [T09] Preço zero
-- Regra: Dicionário: o preço de venda é maior que zero.
-- Restrição: ck_produto_preco CHECK (preco > 0)
-- Esperado: ERROR. Preço 0 não é aceito.
\echo '[T09] Preço zero'
INSERT INTO produto (nome, marca, codigo_barras, preco, controla_validade, id_categoria)
VALUES ('Petisco Gratis', 'Marca C', '7890000000998', 0, TRUE, 1);

-- [T10] Loja física com entrega
-- Regra: RN17: o caixa só vende no balcão; retirada e entrega são da loja virtual.
-- Restrição: ck_pedido_canal_recebimento (CHECK)
-- Esperado: ERROR. A combinação loja_fisica + entrega não existe no negócio.
\echo '[T10] Loja física com entrega'
INSERT INTO pedido (canal_venda, tipo_recebimento, id_cliente, id_funcionario)
VALUES ('loja_fisica', 'entrega', 1, 2);

-- [T11] Venda no caixa sem funcionário
-- Regra: RN14: toda venda da loja física é registrada por um funcionário.
-- Restrição: ck_pedido_func_fisica (CHECK)
-- Esperado: ERROR. Falta o funcionário que registrou a venda.
\echo '[T11] Venda no caixa sem funcionário'
INSERT INTO pedido (canal_venda, tipo_recebimento, id_cliente)
VALUES ('loja_fisica', 'balcao', 1);

-- [T12] Cancelamento no caixa sem autorização
-- Regra: RP07 e ajuste [A3]: cancelar na loja física exige autorização da gerência.
-- Restrição: ck_pedido_cancel_fisica (CHECK)
-- Esperado: ERROR. O pedido 1 é da loja física e não tem id_autorizador_cancelamento.
\echo '[T12] Cancelamento no caixa sem autorização'
UPDATE pedido SET status = 'cancelado'
WHERE id_pedido = 1;

-- [T13] Perda sem autorizador
-- Regra: RP11 e ajuste [A2]: perda e ajuste de estoque só com autorização da gerência.
-- Restrição: ck_mov_autorizacao (CHECK)
-- Esperado: ERROR. A perda foi registrada sem id_autorizador.
\echo '[T13] Perda sem autorizador'
INSERT INTO movimentacao_estoque (tipo, quantidade, motivo, id_lote, id_produto, id_funcionario)
VALUES ('perda', 1, 'Embalagem rasgada', 2, 1, 3);

-- [T14] Perda sem motivo
-- Regra: RP11, RF35: perda, ajuste e devolução precisam de motivo.
-- Restrição: ck_mov_motivo (CHECK)
-- Esperado: ERROR. O motivo ficou vazio.
\echo '[T14] Perda sem motivo'
INSERT INTO movimentacao_estoque (tipo, quantidade, id_lote, id_produto, id_funcionario, id_autorizador)
VALUES ('perda', 1, 2, 1, 3, 1);

-- [T15] Crédito em 4 vezes
-- Regra: RN24: crédito em até 3x sem juros.
-- Restrição: ck_pag_parcelas CHECK (numero_parcelas BETWEEN 1 AND 3)
-- Esperado: ERROR. 4 parcelas passa do limite.
\echo '[T15] Crédito em 4 vezes'
INSERT INTO pagamento (id_pedido, forma_pagamento, valor, numero_parcelas)
VALUES (2, 'cartao_credito', 134.70, 4);

-- [T16] Débito parcelado
-- Regra: RN24: só o cartão de crédito é parcelado; as demais formas são em 1 vez.
-- Restrição: ck_pag_parcelas_credito (CHECK)
-- Esperado: ERROR. Débito em 2 parcelas não existe.
\echo '[T16] Débito parcelado'
INSERT INTO pagamento (id_pedido, forma_pagamento, valor, numero_parcelas)
VALUES (2, 'cartao_debito', 134.70, 2);

-- [T17] Conta recebida sem data
-- Regra: RN24: o valor só é recebido quando entra na conta, e essa data fica registrada.
-- Restrição: ck_cr_recebimento (CHECK)
-- Esperado: ERROR. A parcela foi marcada como recebida sem data_recebimento.
\echo '[T17] Conta recebida sem data'
UPDATE conta_receber SET status = 'recebida'
WHERE id_conta_receber = 2;

-- [T18] Mesmo produto duas vezes no pedido
-- Regra: RN03: o produto aparece uma única vez em cada pedido, com a quantidade total.
-- Restrição: pk_item_pedido PRIMARY KEY (id_pedido, id_produto)
-- Esperado: ERROR. A Ração (produto 1) já é item do pedido 1.
\echo '[T18] Mesmo produto duas vezes no pedido'
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario)
VALUES (1, 1, 3, 189.90);

-- [T19] Mesmo produto duas vezes na compra
-- Regra: RN10: o produto aparece uma vez por compra, com a quantidade total.
-- Restrição: pk_item_compra PRIMARY KEY (id_compra, id_produto)
-- Esperado: ERROR. A Ração (produto 1) já é item da compra 1.
\echo '[T19] Mesmo produto duas vezes na compra'
INSERT INTO item_compra (id_compra, id_produto, quantidade_comprada, custo_unitario)
VALUES (1, 1, 5, 100.00);

-- [T20] Alterar uma movimentação de estoque
-- Regra: RN19, RNF03: o histórico do estoque não pode ser alterado nem excluído; erro se corrige com ajuste.
-- Restrição: trg01_mov_imutavel (gatilho BEFORE UPDATE OR DELETE)
-- Esperado: ERROR. O gatilho bloqueia qualquer UPDATE ou DELETE na tabela.
\echo '[T20] Alterar uma movimentação de estoque'
UPDATE movimentacao_estoque SET quantidade = 99
WHERE id_movimentacao = 1;

-- [T21] Vender sem saldo
-- Regra: RN07: não se vende mais do que a quantidade disponível do lote.
-- Restrição: trg02_mov_saldo (gatilho BEFORE INSERT)
-- Esperado: ERROR. O lote 6 (brinquedo) já tem saldo 0: a última unidade foi vendida no pedido 1.
\echo '[T21] Vender sem saldo'
INSERT INTO movimentacao_estoque (tipo, quantidade, id_lote, id_produto, id_funcionario, id_pedido)
VALUES ('venda', 1, 6, 4, 2, 1);

-- [T22] Entrada em lote vencido
-- Regra: RF12, RP09: lote vencido só admite perda, liberação de reserva e ajuste.
-- Restrição: trg03_mov_validade (gatilho BEFORE INSERT)
-- Esperado: ERROR. O lote 4 venceu em 30/09/2026.
\echo '[T22] Entrada em lote vencido'
INSERT INTO movimentacao_estoque (tipo, quantidade, data_hora, id_lote, id_produto, id_funcionario, id_compra)
VALUES ('entrada', 5, '2026-10-27 10:00', 4, 3, 3, 101);

-- [T23] Pagar mais que o valor da parcela
-- Regra: RN23: a soma dos pagamentos não passa do valor da parcela.
-- Restrição: trg08_pagconta_valida (gatilho BEFORE INSERT)
-- Esperado: ERROR. A parcela 1 vale R$ 1.000,00 e já tem R$ 500,00 pagos.
\echo '[T23] Pagar mais que o valor da parcela'
INSERT INTO pagamento_conta (id_conta_pagar, valor_pago, forma_pagamento)
VALUES (1, 600.00, 'pix');

-- ============================== PARTE 2: UPDATE E DELETE QUE DEVEM SER ACEITOS ==============================

-- [U01] UPDATE: reajuste de preço não altera vendas antigas
-- Regra: RN13: o preço vendido fica registrado no item do pedido.
-- Restrição envolvida: item_pedido.preco_unitario guarda o preço do momento da venda
-- Esperado: aceito. O preço de catálogo passou para R$ 199,90, mas o pedido 1 continua com R$ 189,90.
\echo '[U01] UPDATE: reajuste de preço não altera vendas antigas'
BEGIN;
UPDATE produto SET preco = 199.90 WHERE id_produto = 1;
SELECT p.preco AS preco_atual, i.preco_unitario AS preco_no_pedido_1
FROM produto p JOIN item_pedido i ON i.id_produto = p.id_produto
WHERE p.id_produto = 1 AND i.id_pedido = 1;
ROLLBACK;

-- [U02] UPDATE: pedido entregue
-- Regra: RN16, RN17: o status do pedido e o da entrega andam juntos; entrega concluída tem data.
-- Restrição envolvida: ck_pedido_status_fluxo e ck_entrega_data
-- Esperado: aceito. Os dois status passam para 'entregue', e a data fica registrada.
\echo '[U02] UPDATE: pedido entregue'
BEGIN;
UPDATE pedido SET status = 'entregue' WHERE id_pedido = 2;
UPDATE entrega SET status = 'entregue', data_entrega = '2026-10-28'
WHERE id_pedido = 2;
SELECT p.status AS pedido, e.status AS entrega, e.data_entrega
FROM pedido p JOIN entrega e USING (id_pedido) WHERE id_pedido = 2;
ROLLBACK;

-- [U03] INSERT + gatilho: pagamento que quita a parcela
-- Regra: RN23: a parcela só fica paga quando a soma dos pagamentos chega ao valor.
-- Restrição envolvida: trg08_pagconta_status (gatilho AFTER INSERT)
-- Esperado: aceito. Com os R$ 500,00 restantes, o gatilho muda a parcela de 'paga_parcialmente' para 'paga' e o saldo devedor vai a zero.
\echo '[U03] INSERT + gatilho: pagamento que quita a parcela'
BEGIN;
INSERT INTO pagamento_conta (id_conta_pagar, valor_pago, forma_pagamento)
VALUES (1, 500.00, 'pix');
SELECT * FROM v_conta_pagar_saldo WHERE id_conta_pagar = 1;
ROLLBACK;

-- [D01] DELETE: categoria sem produtos
-- Regra: Uma categoria criada por engano pode ser excluída enquanto não tiver produtos.
-- Restrição envolvida: fk_produto_categoria ON DELETE RESTRICT (só bloqueia se houver produto)
-- Esperado: aceito. A exclusão é aceita porque nenhum produto aponta para a categoria. Já a categoria 1, que tem produtos, seria recusada como no T07.
\echo '[D01] DELETE: categoria sem produtos'
BEGIN;
INSERT INTO categoria (nome) VALUES ('Categoria Teste');
DELETE FROM categoria WHERE nome = 'Categoria Teste';
ROLLBACK;

-- ============================== T24: DUAS VENDAS SIMULTÂNEAS DA ÚLTIMA UNIDADE ==============================
-- Regra: RN07, RNF10 e cenário 1 do README. Restrição: trg02_mov_saldo (trava FOR UPDATE na linha do lote).
-- Rodar numa CÓPIA da base: CREATE DATABASE petly_conc TEMPLATE petly_club;
--
-- Preparação (na cópia):
--   INSERT INTO movimentacao_estoque (tipo, quantidade, motivo, id_lote, id_produto, id_funcionario, id_autorizador)
--   VALUES ('ajuste_positivo', 1, 'Contagem encontrou 1 unidade', 6, 4, 3, 1);
--   INSERT INTO pedido (id_pedido, canal_venda, tipo_recebimento, id_cliente) OVERRIDING SYSTEM VALUE
--   VALUES (7, 'loja_virtual', 'entrega', 3);
--   INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES (7, 4, 1, 19.90);
--
-- Sessão 1 (caixa):
--   BEGIN;
--   INSERT INTO movimentacao_estoque (tipo, quantidade, id_lote, id_produto, id_funcionario, id_pedido)
--   VALUES ('venda', 1, 6, 4, 2, 1);
--   SELECT pg_sleep(3);
--   COMMIT;
--
-- Sessão 2 (loja virtual), iniciada enquanto a sessão 1 ainda está aberta:
--   INSERT INTO movimentacao_estoque (tipo, quantidade, id_lote, id_produto, id_pedido)
--   VALUES ('reserva', 1, 6, 4, 7);
--
-- Esperado: a sessão 2 espera a sessão 1 terminar e é recusada (Quantidade indisponivel no lote 6).
-- O saldo do lote 6 termina em 0, e não em -1.
-- Depois: DROP DATABASE petly_conc;
