-- ============================================================================
-- PROJETO ERP PETLY CLUB - MASSA DE DADOS (POPULAÇÃO COMPLETA DE TESTES)
-- ============================================================================
-- Autores: Grupo 7
-- Cobertura de Testes: Cenários da Seção 17.1 do README e Requisitos RF01 a RF37 / RNF01 a RNF10.
-- SGBD: PostgreSQL 16
-- Data de referência dos testes: 27/10/2026
-- Base: Modelo Lógico do grupo (16 tabelas, ajustes [A1], [A2] e [A3] aprovados)
--
-- REGRAS E DOMÍNIOS DO MODELO LÓGICO:
-- - Regra de Saída de Estoque: FEFO (First Expire, First Out - RN20 / RF11)
-- - Toda movimentação de 'entrada' vinculada a um item de compra (id_compra + id_produto)
-- - Reserva, liberação, venda e devolução vinculadas a um item de pedido (id_pedido + id_produto)
-- - Perda e ajuste sem item, com motivo e autorizador (id_autorizador - RP11)
-- - Na loja virtual, a 'venda' consome a reserva; 'liberacao_reserva' só no cancelamento (RN21, RN22)
-- - canal_venda: 'loja_fisica', 'loja_virtual'
-- - tipo_recebimento: 'balcao', 'retirada', 'entrega'
-- - status do pedido: 'pendente', 'pago', 'em_preparacao', 'enviado', 'entregue', 'retirado', 'cancelado'
-- - status do pagamento: 'pendente', 'autorizado', 'recusado', 'estornado'
-- - status de entrega: 'em_separacao', 'enviado', 'entregue'
-- - status da compra: 'solicitada', 'recebida_parcialmente', 'recebida', 'cancelada'
-- - status da conta_receber: 'pendente', 'recebida', 'cancelada'
-- - status da conta_pagar: 'pendente', 'paga_parcialmente', 'paga', 'cancelada'
-- - Campos derivados NÃO são inseridos (saldos do lote, quantidade recebida, valor pago, totais):
--   saem das visões do modelo lógico.
-- - As chaves usam GENERATED ALWAYS AS IDENTITY; para inserir IDs fixos, cada INSERT usa
--   OVERRIDING SYSTEM VALUE, e as sequences são reajustadas no final.
-- ============================================================================

BEGIN;

-- 1. LIMPEZA PREVENTIVA DE TODAS AS TABELAS EM ORDEM INVERSA DE DEPENDÊNCIA (FK)

TRUNCATE TABLE
    movimentacao_estoque,
    pagamento_conta,
    conta_pagar,
    conta_receber,
    pagamento,
    entrega,
    item_pedido,
    pedido,
    item_compra,
    compra,
    lote,
    produto,
    funcionario,
    cliente,
    fornecedor,
    categoria
RESTART IDENTITY CASCADE;

-- ============================================================================
-- 2. CADASTROS BÁSICOS E INDEPENDENTES (RF01, RF03, RF04, RF05, RF28, RNF01, RNF02, RNF09)
-- ============================================================================

-- Categorias de Produtos (RF28)
INSERT INTO categoria (id_categoria, nome, descricao) OVERRIDING SYSTEM VALUE VALUES
(1, 'Racoes e Alimentos', 'Alimentos secos e umidos para caes e gatos'),
(2, 'Higiene e Beleza', 'Shampoos, condicionadores e tapetes higienicos'),
(3, 'Farmacia e Cuidados', 'Medicamentos, antipulgas e vermifugos'),
(4, 'Acessorios e Brinquedos', 'Guias, coleiras, brinquedos interativos e caminhas');

-- Fornecedores (RF04)
INSERT INTO fornecedor (id_fornecedor, razao_social, cnpj, telefone, email) OVERRIDING SYSTEM VALUE VALUES
(1, 'NutriPet Distribuidora de Alimentos LTDA', '12345678000199', '1133334444', 'contato@nutripet.com.br'),
(2, 'PharmaVet Laboratorios S.A.', '98765432000188', '1144445555', 'vendas@pharmavet.com.br'),
(3, 'PetStyle Acessorios e Utilidades ME', '45678912000177', '1155556666', 'atendimento@petstyle.com');

-- Funcionários e Perfis de Acesso (RF05, RNF01, RNF02: a senha é guardada só como hash bcrypt)
INSERT INTO funcionario (id_funcionario, nome, cpf, cargo, login, senha) OVERRIDING SYSTEM VALUE VALUES
(1, 'Carlos Alberto Silva', '11122233344', 'gerente', 'carlos.gerente', '$2b$12$eImiTXuWVxfM37uY4JANjOL.sU8.J18d5M4Z.bWjUeO1wD6y9kYKy'),
(2, 'Ana Paula Souza', '22233344455', 'operador_caixa', 'ana.caixa', '$2b$12$eImiTXuWVxfM37uY4JANjOL.sU8.J18d5M4Z.bWjUeO1wD6y9kYKy'),
(3, 'Roberto Martins', '33344455566', 'estoquista', 'roberto.estoque', '$2b$12$eImiTXuWVxfM37uY4JANjOL.sU8.J18d5M4Z.bWjUeO1wD6y9kYKy'),
(4, 'Fernanda Lima', '44455566677', 'atendente', 'fernanda.atendente', '$2b$12$eImiTXuWVxfM37uY4JANjOL.sU8.J18d5M4Z.bWjUeO1wD6y9kYKy');

-- Clientes (RF03, RNF09)
INSERT INTO cliente (id_cliente, nome, cpf, telefone, email) OVERRIDING SYSTEM VALUE VALUES
(1, 'Maria Souza', '12345678901', '11988887777', 'maria.souza@email.com'),
(2, 'Joao Lima', '98765432100', '11977776666', 'joao.lima@email.com'),
(3, 'Beatriz Oliveira', '45678912300', '11966665555', 'beatriz.oliveira@email.com'),
(4, 'Lucas Mendes', '78912345600', '11955554444', 'lucas.mendes@email.com'),
(5, 'Camila Rocha', '32165498700', '11944443333', 'camila.rocha@email.com'),
(6, 'Gabriel Costa', '65498732100', '11933332222', 'gabriel.costa@email.com');

-- Produtos (RF01, RF02)
INSERT INTO produto (id_produto, nome, descricao, marca, codigo_barras, preco, estoque_minimo, controla_validade, id_categoria) OVERRIDING SYSTEM VALUE VALUES
(1, 'Racao Premium Caes Adultos 15kg', 'Racao seca completa para caes adultos', 'NutriPet', '7890000000011', 189.90, 5, TRUE, 1),
(2, 'Shampoo Neutro 500ml', 'Shampoo suave para caes e gatos', 'PetClean', '7890000000028', 29.90, 10, TRUE, 2),
(3, 'Antipulgas e Carrapatos 10-20kg', 'Comprimido mastigavel dose unica', 'PharmaVet', '7890000000035', 89.90, 8, TRUE, 3),
(4, 'Bolinha de Borracha Interativa', 'Brinquedo resistente para caes', 'PetStyle', '7890000000042', 19.90, 15, FALSE, 4),
(5, 'Racao Gatos Castrados 3kg', 'Racao seca especial para gatos castrados', 'NutriPet', '7890000000059', 74.90, 6, TRUE, 1),
(6, 'Petisco Dental Caes 200g', 'Petisco para higiene bucal de caes', 'NutriPet', '7890000000066', 24.90, 5, TRUE, 1);

-- ============================================================================
-- 3. ESTOQUE INICIAL E COMPRAS INICIAIS (REGRA MODELO LÓGICO: Entrada vinculada a Item de Compra)
-- ============================================================================
-- As compras de carga inicial foram recebidas em mais de uma entrega (RN25) e já estão pagas.
-- A data de cada compra é anterior à primeira entrada ligada a ela.

INSERT INTO compra (id_compra, data_compra, status, id_fornecedor) OVERRIDING SYSTEM VALUE VALUES
(100, '2026-05-05', 'recebida', 1),   -- NutriPet: racao caes (lotes A e B) e racao gatos
(101, '2025-08-25', 'recebida', 2),   -- PharmaVet: shampoo e antipulgas (lote antigo e lote novo)
(102, '2026-01-05', 'recebida', 3);   -- PetStyle: brinquedo

INSERT INTO item_compra (id_compra, id_produto, quantidade_comprada, custo_unitario) VALUES
(100, 1, 51, 100.00), -- 1 para lote A e 50 para lote B
(100, 5, 20, 40.00),
(100, 6, 12, 6.00),   -- petisco com validade curta (lote perto de vencer)
(101, 2, 40, 15.00),
(101, 3, 40, 45.00),  -- 15 lote vencido e 25 lote ok
(102, 4, 1, 8.00);

-- Lotes do Estoque Inicial
INSERT INTO lote (id_lote, codigo_lote, data_entrada, data_validade, id_produto) OVERRIDING SYSTEM VALUE VALUES
(1, 'LOTE-RAC-2026-A', '2026-05-10', '2026-11-15', 1), -- FEFO 1 (vence primeiro)
(2, 'LOTE-RAC-2026-B', '2026-08-01', '2027-08-01', 1), -- FEFO 2
(3, 'LOTE-SHA-2026-A', '2026-06-15', '2028-06-15', 2),
(4, 'LOTE-MED-VENCIDO', '2025-09-01', '2026-09-30', 3), -- Vencido em 30/09/2026 (Bloqueado RF12)
(5, 'LOTE-MED-OK', '2026-07-01', '2027-07-01', 3),      -- Lote válido de medicamento
(6, 'LOTE-BRINQ-01', '2026-01-10', NULL, 4),            -- Brinquedo sem controle de validade (1 unidade)
(7, 'LOTE-GAT-2026-A', '2026-07-10', '2027-03-20', 5),
(11, 'LOTE-PET-2026-A', '2026-08-15', '2026-11-10', 6);  -- Vence em 10/11/2026: aparece no alerta de 30 dias

-- Entradas Iniciais no Estoque
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(1, 'entrada', 1,  '2026-05-10 08:00:00', 'Entrada inicial lote racao A', 1, 3, NULL, 1, 100, NULL),
(2, 'entrada', 50, '2026-08-01 09:30:00', 'Entrada inicial lote racao B', 2, 3, NULL, 1, 100, NULL),
(3, 'entrada', 40, '2026-06-15 10:15:00', 'Entrada inicial shampoo', 3, 3, NULL, 2, 101, NULL),
(4, 'entrada', 15, '2025-09-01 11:00:00', 'Entrada lote antigo antipulgas', 4, 3, NULL, 3, 101, NULL),
(5, 'entrada', 25, '2026-07-01 14:00:00', 'Entrada lote novo antipulgas', 5, 3, NULL, 3, 101, NULL),
(6, 'entrada', 1,  '2026-01-10 16:00:00', 'Entrada inicial brinquedo', 6, 3, NULL, 4, 102, NULL),
(7, 'entrada', 20, '2026-07-10 09:00:00', 'Entrada inicial racao gatos', 7, 3, NULL, 5, 100, NULL),
(28, 'entrada', 12, '2026-08-15 10:00:00', 'Entrada inicial petisco dental', 11, 3, NULL, 6, 100, NULL);

-- Financeiro das compras iniciais: uma parcela cada, já paga (RN12, RN23)
-- Totais: compra 100 = 51 x 100,00 + 20 x 40,00 + 12 x 6,00 = 5.972,00; compra 101 = 40 x 15,00 + 40 x 45,00 = 2.400,00; compra 102 = 8,00
INSERT INTO conta_pagar (id_conta_pagar, id_compra, numero_parcela, valor, data_vencimento, status) OVERRIDING SYSTEM VALUE VALUES
(100, 100, 1, 5972.00, '2026-06-05', 'paga'),
(101, 101, 1, 2400.00, '2025-09-25', 'paga'),
(102, 102, 1, 8.00,    '2026-02-05', 'paga');

INSERT INTO pagamento_conta (id_pagamento_conta, id_conta_pagar, valor_pago, data_pagamento, forma_pagamento) OVERRIDING SYSTEM VALUE VALUES
(100, 100, 5972.00, '2026-06-05', 'boleto'),
(101, 101, 2400.00, '2025-09-25', 'boleto'),
(102, 102, 8.00,    '2026-02-05', 'pix');

-- ============================================================================
-- 4. CENÁRIOS OPERACIONAIS (SEÇÃO 17.1 DO README)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CENÁRIO A (README 17.1, cenários 1 e 2): Venda física com baixa por FEFO em dois lotes e consumo da última unidade
-- ----------------------------------------------------------------------------
-- A Ração 15kg sai 1 un. do Lote 1 (vence antes) e 1 un. do Lote 2 (cenário 2).
-- O brinquedo tem uma única unidade, no Lote 6: depois desta venda, a quantidade disponível é 0.
-- Uma segunda venda ou reserva dessa unidade deve ser RECUSADA pelo banco (cenário 1, [TRG-02]).
-- Essa tentativa é um teste de rejeição, e não faz parte da carga: ver testes de integridade.
INSERT INTO pedido (id_pedido, data_pedido, canal_venda, tipo_recebimento, status, desconto, id_cliente, id_funcionario) OVERRIDING SYSTEM VALUE VALUES
(1, '2026-10-20 10:30:00', 'loja_fisica', 'balcao', 'pago', 0.00, 1, 2);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 2, 189.90),
(1, 4, 1, 19.90);

-- Baixa FEFO em 2 lotes para Produto 1 + consumo total do Lote 6
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(8, 'venda', 1, '2026-10-20 10:30:00', 'Baixa FEFO Lote 1 (venc 15/11/2026)', 1, 2, NULL, 1, NULL, 1),
(9, 'venda', 1, '2026-10-20 10:30:00', 'Baixa FEFO Lote 2 (venc 01/08/2027)', 2, 2, NULL, 1, NULL, 1),
(10, 'venda', 1, '2026-10-20 10:30:00', 'Baixa total do Lote 6 (ultima unidade)', 6, 2, NULL, 4, NULL, 1);

INSERT INTO pagamento (id_pagamento, id_pedido, forma_pagamento, valor, numero_parcelas, data_autorizacao, status) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'dinheiro', 399.70, 1, '2026-10-20 10:30:00', 'autorizado');

INSERT INTO conta_receber (id_conta_receber, id_pagamento, numero_parcela, valor_bruto, valor_liquido, data_prevista, data_recebimento, status) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, 399.70, 399.70, '2026-10-20', '2026-10-20', 'recebida');


-- ----------------------------------------------------------------------------
-- CENÁRIO B (README 17.1, cenário 4): Compra recebida em DUAS entregas, com lotes distintos (RN25, RF34)
-- ----------------------------------------------------------------------------
INSERT INTO compra (id_compra, data_compra, status, id_fornecedor) OVERRIDING SYSTEM VALUE VALUES
(1, '2026-10-21', 'recebida', 1);

INSERT INTO item_compra (id_compra, id_produto, quantidade_comprada, custo_unitario) VALUES
(1, 1, 20, 100.00);

-- Rastreabilidade: cada entrega chegou com um lote diferente
INSERT INTO lote (id_lote, codigo_lote, data_entrada, data_validade, id_produto) OVERRIDING SYSTEM VALUE VALUES
(8, 'LOTE-RAC-2026-C1', '2026-10-22', '2027-10-22', 1),
(9, 'LOTE-RAC-2026-C2', '2026-10-23', '2027-11-30', 1);

INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(11, 'entrada', 10, '2026-10-22 14:00:00', 'Recebimento Compra 1 - Entrega 1', 8, 3, NULL, 1, 1, NULL),
(12, 'entrada', 10, '2026-10-23 10:00:00', 'Recebimento Compra 1 - Entrega 2', 9, 3, NULL, 1, 1, NULL);

-- Financeiro da Compra 1: R$ 2.000,00 em 2 parcelas (RN12)
INSERT INTO conta_pagar (id_conta_pagar, id_compra, numero_parcela, valor, data_vencimento, status) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, 1000.00, '2026-11-22', 'pendente'),
(2, 1, 2, 1000.00, '2026-12-22', 'pendente');


-- ----------------------------------------------------------------------------
-- CENÁRIO C (README 17.1, cenário 4, variação): Compra com recebimento parcial (RN25, RF34)
-- ----------------------------------------------------------------------------
-- Compradas 20 unidades, entregues 10. A quantidade recebida é derivada das entradas (v_item_compra_recebido)
-- e a compra fica 'recebida_parcialmente'. A conta a pagar é do valor total da compra (20 x 50,00),
-- porque a soma das parcelas tem de ser igual ao total da compra ([TRG-09]).
INSERT INTO compra (id_compra, data_compra, status, id_fornecedor) OVERRIDING SYSTEM VALUE VALUES
(2, '2026-10-23', 'recebida_parcialmente', 2);

INSERT INTO item_compra (id_compra, id_produto, quantidade_comprada, custo_unitario) VALUES
(2, 3, 20, 50.00);

INSERT INTO lote (id_lote, codigo_lote, data_entrada, data_validade, id_produto) OVERRIDING SYSTEM VALUE VALUES
(10, 'LOTE-MED-PARCIAL', '2026-10-25', '2027-10-25', 3);

-- Apenas as 10 unidades recebidas geram estoque
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(13, 'entrada', 10, '2026-10-25 10:00:00', 'Entrada parcial Compra 2 (10 de 20 uni)', 10, 3, NULL, 3, 2, NULL);

INSERT INTO conta_pagar (id_conta_pagar, id_compra, numero_parcela, valor, data_vencimento, status) OVERRIDING SYSTEM VALUE VALUES
(3, 2, 1, 1000.00, '2026-11-25', 'pendente');


-- ----------------------------------------------------------------------------
-- CENÁRIO D (README 17.1, cenário 6): Loja Virtual - Crédito em 3x com valor líquido, e venda consumindo a reserva
-- ----------------------------------------------------------------------------
INSERT INTO pedido (id_pedido, data_pedido, canal_venda, tipo_recebimento, status, desconto, id_cliente, id_funcionario) OVERRIDING SYSTEM VALUE VALUES
(2, '2026-10-24 14:00:00', 'loja_virtual', 'entrega', 'enviado', 0.00, 2, NULL);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(2, 2, 2, 29.90),
(2, 5, 1, 74.90);

-- 'reserva' no pedido -> 'venda' no envio (a venda da loja virtual consome a reserva - RN21)
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(14, 'reserva', 2, '2026-10-24 14:00:00', 'Reserva Pedido Virtual 2', 3, NULL, NULL, 2, NULL, 2),
(15, 'reserva', 1, '2026-10-24 14:00:00', 'Reserva Pedido Virtual 2', 7, NULL, NULL, 5, NULL, 2),
(16, 'venda', 2, '2026-10-25 09:00:00', 'Efetivacao de Venda por Envio Pedido 2', 3, 3, NULL, 2, NULL, 2),
(17, 'venda', 1, '2026-10-25 09:00:00', 'Efetivacao de Venda por Envio Pedido 2', 7, 3, NULL, 5, NULL, 2);

INSERT INTO entrega (id_entrega, logradouro, numero, complemento, bairro, cidade, uf, cep, data_prevista, data_entrega, status, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(1, 'Rua das Flores', '123', 'Apto 45', 'Jardim Paulista', 'Sao Paulo', 'SP', '01415000', '2026-10-28', NULL, 'enviado', 2);

INSERT INTO pagamento (id_pagamento, id_pedido, forma_pagamento, valor, numero_parcelas, data_autorizacao, status) OVERRIDING SYSTEM VALUE VALUES
(2, 2, 'cartao_credito', 134.70, 3, '2026-10-24 14:00:00', 'autorizado');

-- Crédito parcelado em 3x com taxa da operadora descontada (Bruto: R$ 44,90 / Líquido: R$ 42,65)
-- Em 27/10/2026 as três parcelas ainda estão pendentes: autorizado não é recebido (RN24)
INSERT INTO conta_receber (id_conta_receber, id_pagamento, numero_parcela, valor_bruto, valor_liquido, data_prevista, data_recebimento, status) OVERRIDING SYSTEM VALUE VALUES
(2, 2, 1, 44.90, 42.65, '2026-11-24', NULL, 'pendente'),
(3, 2, 2, 44.90, 42.65, '2026-12-24', NULL, 'pendente'),
(4, 2, 3, 44.90, 42.65, '2027-01-24', NULL, 'pendente');


-- ----------------------------------------------------------------------------
-- CENÁRIO E (README 17.1, cenário 7): Loja Virtual com PIX recusado e liberação da reserva
-- ----------------------------------------------------------------------------
INSERT INTO pedido (id_pedido, data_pedido, canal_venda, tipo_recebimento, status, desconto, id_cliente, id_funcionario) OVERRIDING SYSTEM VALUE VALUES
(3, '2026-10-25 15:00:00', 'loja_virtual', 'entrega', 'cancelado', 0.00, 3, NULL);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(3, 1, 1, 189.90);

-- Liberação de reserva ocorre exclusivamente em caso de cancelamento; o saldo físico não muda
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(18, 'reserva', 1, '2026-10-25 15:00:00', 'Reserva Pedido Virtual 3', 2, NULL, NULL, 1, NULL, 3),
(19, 'liberacao_reserva', 1, '2026-10-25 16:00:00', 'Liberacao por cancelamento de PIX expirado', 2, NULL, NULL, 1, NULL, 3);

-- Pagamento recusado: não tem data de autorização e não gera conta a receber
INSERT INTO pagamento (id_pagamento, id_pedido, forma_pagamento, valor, numero_parcelas, data_autorizacao, status) OVERRIDING SYSTEM VALUE VALUES
(3, 3, 'pix', 189.90, 1, NULL, 'recusado');


-- ----------------------------------------------------------------------------
-- CENÁRIO F (complementar - RN17, RN21): Pedido Virtual com retirada na loja
-- ----------------------------------------------------------------------------
INSERT INTO pedido (id_pedido, data_pedido, canal_venda, tipo_recebimento, status, desconto, id_cliente, id_funcionario) OVERRIDING SYSTEM VALUE VALUES
(4, '2026-10-26 09:00:00', 'loja_virtual', 'retirada', 'retirado', 0.00, 4, 2);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(4, 2, 1, 29.90);

INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(20, 'reserva', 1, '2026-10-26 09:00:00', 'Reserva Pedido 4 Retirada', 3, NULL, NULL, 2, NULL, 4),
(21, 'venda', 1, '2026-10-26 11:30:00', 'Efetivacao de Venda na Retirada Balcao', 3, 2, NULL, 2, NULL, 4);

INSERT INTO pagamento (id_pagamento, id_pedido, forma_pagamento, valor, numero_parcelas, data_autorizacao, status) OVERRIDING SYSTEM VALUE VALUES
(4, 4, 'pix', 29.90, 1, '2026-10-26 09:00:00', 'autorizado');

INSERT INTO conta_receber (id_conta_receber, id_pagamento, numero_parcela, valor_bruto, valor_liquido, data_prevista, data_recebimento, status) OVERRIDING SYSTEM VALUE VALUES
(5, 4, 1, 29.90, 29.90, '2026-10-26', '2026-10-26', 'recebida');


-- ----------------------------------------------------------------------------
-- CENÁRIO G (README 17.1, cenário 3): Produto vencido e perda por avaria, com autorizador (RF12, RP09, RP11)
-- ----------------------------------------------------------------------------
-- Responsável: estoquista Roberto (id_funcionario = 3). Autorizador: gerente Carlos (id_autorizador = 1).
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(22, 'perda', 1, '2026-10-26 16:00:00', 'Avaria na embalagem durante a arrumacao', 2, 3, 1, 1, NULL, NULL),
(23, 'perda', 15, '2026-10-27 08:30:00', 'Descarte obrigatorio de lote vencido em 30/09/2026', 4, 3, 1, 3, NULL, NULL);


-- ----------------------------------------------------------------------------
-- CENÁRIO H (README 17.1, cenário 5): Pagamento parcial de uma parcela da conta a pagar (RN23)
-- ----------------------------------------------------------------------------
-- Pagamento de R$ 500,00 sobre a parcela 1 da Compra 1 (R$ 1.000,00).
-- O valor pago e o saldo devedor não são colunas: saem da visão v_conta_pagar_saldo.
INSERT INTO pagamento_conta (id_pagamento_conta, id_conta_pagar, valor_pago, data_pagamento, forma_pagamento) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 500.00, '2026-10-26', 'transferencia');

-- O status da parcela é mantido pelo gatilho [TRG-08]; o UPDATE abaixo só é necessário se o gatilho ainda não existir
UPDATE conta_pagar
SET status = 'paga_parcialmente'
WHERE id_conta_pagar = 1;


-- ----------------------------------------------------------------------------
-- CENÁRIO I (complementar - RF32, RF15, RN24): Desconto autorizado + pagamento dividido em duas formas
-- ----------------------------------------------------------------------------
-- 1 Antipulgas (R$ 89,90) com R$ 10,00 de desconto autorizado pelo gerente Carlos. Total: R$ 79,90.
INSERT INTO pedido (id_pedido, data_pedido, canal_venda, tipo_recebimento, status, desconto, id_cliente, id_funcionario, id_autorizador_desconto) OVERRIDING SYSTEM VALUE VALUES
(5, '2026-10-27 09:00:00', 'loja_fisica', 'balcao', 'pago', 10.00, 5, 2, 1);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(5, 3, 1, 89.90);

-- FEFO: o Lote 4 está vencido, então a venda sai do Lote 5
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(24, 'venda', 1, '2026-10-27 09:00:00', 'Venda balcao Pedido 5', 5, 2, NULL, 3, NULL, 5);

INSERT INTO pagamento (id_pagamento, id_pedido, forma_pagamento, valor, numero_parcelas, data_autorizacao, status) OVERRIDING SYSTEM VALUE VALUES
(5, 5, 'dinheiro', 29.90, 1, '2026-10-27 09:00:00', 'autorizado'),
(6, 5, 'pix', 50.00, 1, '2026-10-27 09:00:00', 'autorizado');

-- Uma conta a receber para cada pagamento
INSERT INTO conta_receber (id_conta_receber, id_pagamento, numero_parcela, valor_bruto, valor_liquido, data_prevista, data_recebimento, status) OVERRIDING SYSTEM VALUE VALUES
(6, 5, 1, 29.90, 29.90, '2026-10-27', '2026-10-27', 'recebida'),
(7, 6, 1, 50.00, 50.00, '2026-10-27', '2026-10-27', 'recebida');


-- ----------------------------------------------------------------------------
-- CENÁRIO J (README 17.1, cenário 8): Cancelamento no caixa de venda já baixada, com autorizador, devolução e perda
-- ----------------------------------------------------------------------------
INSERT INTO pedido (id_pedido, data_pedido, canal_venda, tipo_recebimento, status, desconto, id_cliente, id_funcionario, id_autorizador_cancelamento) OVERRIDING SYSTEM VALUE VALUES
(6, '2026-10-27 09:20:00', 'loja_fisica', 'balcao', 'cancelado', 0.00, 6, 2, 1);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(6, 2, 2, 29.90);

-- Venda -> Devolução (1 bom, ligada ao item do pedido) -> Perda (1 danificado; perda não tem item de pedido,
-- então a ligação com o pedido 6 fica no motivo - ck_mov_vinculo e seção 9 do modelo lógico)
INSERT INTO movimentacao_estoque (id_movimentacao, tipo, quantidade, data_hora, motivo, id_lote, id_funcionario, id_autorizador, id_produto, id_compra, id_pedido) OVERRIDING SYSTEM VALUE VALUES
(25, 'venda', 2, '2026-10-27 09:20:00', 'Venda balcao Pedido 6', 3, 2, NULL, 2, NULL, 6),
(26, 'devolucao', 1, '2026-10-27 09:25:00', 'Cancelamento do Pedido 6 - item intacto volta ao lote', 3, 2, NULL, 2, NULL, 6),
(27, 'perda', 1, '2026-10-27 09:25:00', 'Cancelamento do Pedido 6 - item devolvido com lacre rompido', 3, 2, 1, 2, NULL, NULL);

INSERT INTO pagamento (id_pagamento, id_pedido, forma_pagamento, valor, numero_parcelas, data_autorizacao, status) OVERRIDING SYSTEM VALUE VALUES
(7, 6, 'cartao_credito', 59.80, 1, '2026-10-27 09:20:00', 'estornado');

INSERT INTO conta_receber (id_conta_receber, id_pagamento, numero_parcela, valor_bruto, valor_liquido, data_prevista, data_recebimento, status) OVERRIDING SYSTEM VALUE VALUES
(8, 7, 1, 59.80, 59.80, '2026-11-26', NULL, 'cancelada');


-- ============================================================================
-- 5. REAJUSTE AUTOMÁTICO DAS SEQUENCES (PostgreSQL 16)
-- ============================================================================
-- item_compra e item_pedido não têm sequence: a chave é composta.

SELECT setval(pg_get_serial_sequence('categoria', 'id_categoria'), (SELECT MAX(id_categoria) FROM categoria));
SELECT setval(pg_get_serial_sequence('fornecedor', 'id_fornecedor'), (SELECT MAX(id_fornecedor) FROM fornecedor));
SELECT setval(pg_get_serial_sequence('funcionario', 'id_funcionario'), (SELECT MAX(id_funcionario) FROM funcionario));
SELECT setval(pg_get_serial_sequence('cliente', 'id_cliente'), (SELECT MAX(id_cliente) FROM cliente));
SELECT setval(pg_get_serial_sequence('produto', 'id_produto'), (SELECT MAX(id_produto) FROM produto));
SELECT setval(pg_get_serial_sequence('lote', 'id_lote'), (SELECT MAX(id_lote) FROM lote));
SELECT setval(pg_get_serial_sequence('compra', 'id_compra'), (SELECT MAX(id_compra) FROM compra));
SELECT setval(pg_get_serial_sequence('pedido', 'id_pedido'), (SELECT MAX(id_pedido) FROM pedido));
SELECT setval(pg_get_serial_sequence('movimentacao_estoque', 'id_movimentacao'), (SELECT MAX(id_movimentacao) FROM movimentacao_estoque));
SELECT setval(pg_get_serial_sequence('entrega', 'id_entrega'), (SELECT MAX(id_entrega) FROM entrega));
SELECT setval(pg_get_serial_sequence('pagamento', 'id_pagamento'), (SELECT MAX(id_pagamento) FROM pagamento));
SELECT setval(pg_get_serial_sequence('conta_receber', 'id_conta_receber'), (SELECT MAX(id_conta_receber) FROM conta_receber));
SELECT setval(pg_get_serial_sequence('conta_pagar', 'id_conta_pagar'), (SELECT MAX(id_conta_pagar) FROM conta_pagar));
SELECT setval(pg_get_serial_sequence('pagamento_conta', 'id_pagamento_conta'), (SELECT MAX(id_pagamento_conta) FROM pagamento_conta));

COMMIT;
