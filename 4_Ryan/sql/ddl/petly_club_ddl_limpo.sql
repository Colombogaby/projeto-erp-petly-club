-- ============================================================================
-- PROJETO ERP PETLY CLUB - SCRIPT DDL (MODELO FÍSICO)
-- ============================================================================
-- Grupo 7 | SGBD: PostgreSQL 16
-- Base: Modelo Lógico do grupo (16 tabelas, ajustes [A1], [A2] e [A3] aprovados).
-- A justificativa de cada restrição (a regra de negócio que ela protege) está nas
-- tabelas das seções 3 a 5 do Modelo Lógico; os gatilhos seguem a seção 6 ([TRG-nn]).
-- Os nomes das constraints seguem o padrão pk_, fk_, uk_ e ck_ + tabela + campo.
-- Ordem: tabelas independentes -> dependentes -> movimentacao_estoque -> gatilhos,
-- índices e visões. As demais regras da seção 6 (TRG-04 a TRG-07 e TRG-09 a TRG-18)
-- ficam a cargo da aplicação, dentro da mesma transação da operação.
-- ============================================================================

\set ON_ERROR_STOP on

DROP DATABASE IF EXISTS petly_club;
CREATE DATABASE petly_club;
\c petly_club

CREATE TABLE categoria (
    id_categoria  INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome          VARCHAR(60)  NOT NULL,
    descricao     VARCHAR(255),
    CONSTRAINT pk_categoria      PRIMARY KEY (id_categoria),
    CONSTRAINT uk_categoria_nome UNIQUE (nome)
);

CREATE TABLE cliente (
    id_cliente  INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome        VARCHAR(120) NOT NULL,
    cpf         CHAR(11)     NOT NULL,
    telefone    VARCHAR(20),
    email       VARCHAR(120),
    CONSTRAINT pk_cliente       PRIMARY KEY (id_cliente),
    CONSTRAINT uk_cliente_cpf   UNIQUE (cpf),
    CONSTRAINT ck_cliente_cpf   CHECK (cpf ~ '^[0-9]{11}$'),
    CONSTRAINT ck_cliente_email CHECK (email LIKE '%_@_%')
);

CREATE TABLE funcionario (
    id_funcionario  INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome            VARCHAR(120) NOT NULL,
    cpf             CHAR(11)     NOT NULL,
    cargo           VARCHAR(30)  NOT NULL,
    login           VARCHAR(50)  NOT NULL,
    senha           VARCHAR(255) NOT NULL,
    CONSTRAINT pk_funcionario       PRIMARY KEY (id_funcionario),
    CONSTRAINT uk_funcionario_cpf   UNIQUE (cpf),
    CONSTRAINT uk_funcionario_login UNIQUE (login),
    CONSTRAINT ck_funcionario_cpf   CHECK (cpf ~ '^[0-9]{11}$'),
    CONSTRAINT ck_funcionario_cargo CHECK (cargo IN
        ('gerente', 'atendente', 'operador_caixa', 'estoquista',
         'compras', 'financeiro', 'loja_virtual')),
    CONSTRAINT ck_funcionario_senha CHECK (CHAR_LENGTH(senha) >= 60)
);

CREATE TABLE fornecedor (
    id_fornecedor  INTEGER      GENERATED ALWAYS AS IDENTITY,
    razao_social   VARCHAR(150) NOT NULL,
    cnpj           CHAR(14)     NOT NULL,
    telefone       VARCHAR(20)  NOT NULL,
    email          VARCHAR(120),
    CONSTRAINT pk_fornecedor     PRIMARY KEY (id_fornecedor),
    CONSTRAINT uk_fornecedor_cnpj UNIQUE (cnpj),
    CONSTRAINT ck_fornecedor_cnpj CHECK (cnpj ~ '^[0-9]{14}$')
);

CREATE TABLE produto (
    id_produto         INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome               VARCHAR(120)  NOT NULL,
    descricao          VARCHAR(255),
    marca              VARCHAR(60)   NOT NULL,
    codigo_barras      VARCHAR(14)   NOT NULL,
    preco              NUMERIC(10,2) NOT NULL,
    estoque_minimo     INTEGER       NOT NULL DEFAULT 0,
    controla_validade  BOOLEAN       NOT NULL,
    id_categoria       INTEGER       NOT NULL,
    CONSTRAINT pk_produto        PRIMARY KEY (id_produto),
    CONSTRAINT uk_produto_barras UNIQUE (codigo_barras),
    CONSTRAINT ck_produto_barras CHECK (codigo_barras ~ '^[0-9]{8,14}$'),
    CONSTRAINT ck_produto_preco  CHECK (preco > 0),
    CONSTRAINT ck_produto_minimo CHECK (estoque_minimo >= 0),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria) ON DELETE RESTRICT ON UPDATE NO ACTION
);

CREATE TABLE lote (
    id_lote        INTEGER     GENERATED ALWAYS AS IDENTITY,
    id_produto     INTEGER     NOT NULL,
    codigo_lote    VARCHAR(40),
    data_validade  DATE,
    data_entrada   DATE        NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT pk_lote PRIMARY KEY (id_lote),
    CONSTRAINT fk_lote_produto FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT uk_lote_produto_codigo UNIQUE (id_produto, codigo_lote),
    CONSTRAINT uk_lote_id_produto     UNIQUE (id_lote, id_produto),
    CONSTRAINT ck_lote_codigo   CHECK (data_validade IS NULL OR codigo_lote IS NOT NULL),
    CONSTRAINT ck_lote_validade CHECK (data_validade IS NULL OR data_validade >= data_entrada)
);

CREATE TABLE compra (
    id_compra      INTEGER     GENERATED ALWAYS AS IDENTITY,
    id_fornecedor  INTEGER     NOT NULL,
    data_compra    DATE        NOT NULL DEFAULT CURRENT_DATE,
    status         VARCHAR(25) NOT NULL DEFAULT 'solicitada',

    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedor (id_fornecedor) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT ck_compra_status CHECK (status IN
        ('solicitada', 'recebida_parcialmente', 'recebida', 'cancelada'))
);

CREATE TABLE item_compra (
    id_compra            INTEGER       NOT NULL,
    id_produto           INTEGER       NOT NULL,
    quantidade_comprada  INTEGER       NOT NULL,
    custo_unitario       NUMERIC(10,2) NOT NULL,

    CONSTRAINT pk_item_compra PRIMARY KEY (id_compra, id_produto),
    CONSTRAINT fk_item_compra_compra FOREIGN KEY (id_compra)
        REFERENCES compra (id_compra) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_item_compra_produto FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT ck_item_compra_qtd   CHECK (quantidade_comprada > 0),
    CONSTRAINT ck_item_compra_custo CHECK (custo_unitario > 0)
);

CREATE TABLE conta_pagar (
    id_conta_pagar   INTEGER       GENERATED ALWAYS AS IDENTITY,
    id_compra        INTEGER       NOT NULL,
    numero_parcela   SMALLINT      NOT NULL,
    valor            NUMERIC(12,2) NOT NULL,
    data_vencimento  DATE          NOT NULL,
    status           VARCHAR(20)   NOT NULL DEFAULT 'pendente',

    CONSTRAINT pk_conta_pagar PRIMARY KEY (id_conta_pagar),
    CONSTRAINT fk_conta_pagar_compra FOREIGN KEY (id_compra)
        REFERENCES compra (id_compra) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT uk_conta_pagar_parcela UNIQUE (id_compra, numero_parcela),
    CONSTRAINT ck_conta_pagar_parcela CHECK (numero_parcela >= 1),
    CONSTRAINT ck_conta_pagar_valor   CHECK (valor > 0),
    CONSTRAINT ck_conta_pagar_status  CHECK (status IN
        ('pendente', 'paga_parcialmente', 'paga', 'cancelada'))
);

CREATE TABLE pagamento_conta (
    id_pagamento_conta  INTEGER       GENERATED ALWAYS AS IDENTITY,
    id_conta_pagar      INTEGER       NOT NULL,
    valor_pago          NUMERIC(12,2) NOT NULL,
    data_pagamento      DATE          NOT NULL DEFAULT CURRENT_DATE,
    forma_pagamento     VARCHAR(20)   NOT NULL,
    CONSTRAINT pk_pagamento_conta PRIMARY KEY (id_pagamento_conta),
    CONSTRAINT fk_pagamento_conta_conta FOREIGN KEY (id_conta_pagar)
        REFERENCES conta_pagar (id_conta_pagar) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT ck_pagamento_conta_valor CHECK (valor_pago > 0),
    CONSTRAINT ck_pagamento_conta_forma CHECK (forma_pagamento IN ('pix', 'boleto', 'transferencia'))
);

CREATE TABLE pedido (
    id_pedido                    INTEGER       GENERATED ALWAYS AS IDENTITY,
    id_cliente                   INTEGER       NOT NULL,
    id_funcionario               INTEGER,
    data_pedido                  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canal_venda                  VARCHAR(12)   NOT NULL,
    tipo_recebimento             VARCHAR(10)   NOT NULL,
    status                       VARCHAR(15)   NOT NULL DEFAULT 'pendente',
    desconto                     NUMERIC(10,2) NOT NULL DEFAULT 0,
    id_autorizador_desconto      INTEGER,
    id_autorizador_cancelamento  INTEGER,

    CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_pedido_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_pedido_aut_desconto FOREIGN KEY (id_autorizador_desconto)
        REFERENCES funcionario (id_funcionario) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_pedido_aut_cancelamento FOREIGN KEY (id_autorizador_cancelamento)
        REFERENCES funcionario (id_funcionario) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT ck_pedido_canal    CHECK (canal_venda IN ('loja_fisica', 'loja_virtual')),
    CONSTRAINT ck_pedido_receb    CHECK (tipo_recebimento IN ('balcao', 'retirada', 'entrega')),
    CONSTRAINT ck_pedido_status   CHECK (status IN
        ('pendente', 'pago', 'em_preparacao', 'enviado', 'entregue', 'retirado', 'cancelado')),
    CONSTRAINT ck_pedido_desconto CHECK (desconto >= 0),

    CONSTRAINT ck_pedido_canal_recebimento CHECK (
           (canal_venda = 'loja_fisica'  AND tipo_recebimento = 'balcao')
        OR (canal_venda = 'loja_virtual' AND tipo_recebimento IN ('retirada', 'entrega'))),

    CONSTRAINT ck_pedido_func_fisica CHECK (canal_venda <> 'loja_fisica' OR id_funcionario IS NOT NULL),

    CONSTRAINT ck_pedido_status_fluxo CHECK (
           (status NOT IN ('em_preparacao', 'enviado', 'entregue', 'retirado') OR canal_venda = 'loja_virtual')
       AND (status NOT IN ('enviado', 'entregue') OR tipo_recebimento = 'entrega')
       AND (status <> 'retirado' OR tipo_recebimento = 'retirada')),

    CONSTRAINT ck_pedido_cancel_fisica CHECK (
        NOT (canal_venda = 'loja_fisica' AND status = 'cancelado')
        OR id_autorizador_cancelamento IS NOT NULL)
);

CREATE TABLE item_pedido (
    id_pedido       INTEGER       NOT NULL,
    id_produto      INTEGER       NOT NULL,
    quantidade      INTEGER       NOT NULL,
    preco_unitario  NUMERIC(10,2) NOT NULL,

    CONSTRAINT pk_item_pedido PRIMARY KEY (id_pedido, id_produto),
    CONSTRAINT fk_item_pedido_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_item_pedido_produto FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT ck_item_pedido_qtd   CHECK (quantidade > 0),
    CONSTRAINT ck_item_pedido_preco CHECK (preco_unitario > 0)
);

CREATE TABLE pagamento (
    id_pagamento      INTEGER       GENERATED ALWAYS AS IDENTITY,
    id_pedido         INTEGER       NOT NULL,
    forma_pagamento   VARCHAR(15)   NOT NULL,
    valor             NUMERIC(12,2) NOT NULL,
    numero_parcelas   SMALLINT      NOT NULL DEFAULT 1,
    data_autorizacao  TIMESTAMP,
    status            VARCHAR(12)   NOT NULL DEFAULT 'pendente',
    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pagamento_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT ck_pag_forma    CHECK (forma_pagamento IN
        ('dinheiro', 'pix', 'cartao_debito', 'cartao_credito')),
    CONSTRAINT ck_pag_valor    CHECK (valor > 0),
    CONSTRAINT ck_pag_parcelas CHECK (numero_parcelas BETWEEN 1 AND 3),
    CONSTRAINT ck_pag_status   CHECK (status IN ('pendente', 'autorizado', 'recusado', 'estornado')),

    CONSTRAINT ck_pag_parcelas_credito CHECK (forma_pagamento = 'cartao_credito' OR numero_parcelas = 1),

    CONSTRAINT ck_pag_autorizacao CHECK (
           (status IN ('autorizado', 'estornado')     AND data_autorizacao IS NOT NULL)
        OR (status NOT IN ('autorizado', 'estornado') AND data_autorizacao IS NULL))
);

CREATE TABLE conta_receber (
    id_conta_receber  INTEGER       GENERATED ALWAYS AS IDENTITY,
    id_pagamento      INTEGER       NOT NULL,
    numero_parcela    SMALLINT      NOT NULL,
    valor_bruto       NUMERIC(12,2) NOT NULL,
    valor_liquido     NUMERIC(12,2) NOT NULL,
    data_prevista     DATE          NOT NULL,
    data_recebimento  DATE,
    status            VARCHAR(10)   NOT NULL DEFAULT 'pendente',
    CONSTRAINT pk_conta_receber PRIMARY KEY (id_conta_receber),
    CONSTRAINT fk_conta_receber_pagamento FOREIGN KEY (id_pagamento)
        REFERENCES pagamento (id_pagamento) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT uk_cr_parcela  UNIQUE (id_pagamento, numero_parcela),
    CONSTRAINT ck_cr_parcela  CHECK (numero_parcela BETWEEN 1 AND 3),
    CONSTRAINT ck_cr_bruto    CHECK (valor_bruto > 0),
    CONSTRAINT ck_cr_liquido  CHECK (valor_liquido > 0 AND valor_liquido <= valor_bruto),
    CONSTRAINT ck_cr_status   CHECK (status IN ('pendente', 'recebida', 'cancelada')),

    CONSTRAINT ck_cr_recebimento CHECK (
           (status = 'pendente' AND data_recebimento IS NULL)
        OR (status = 'recebida' AND data_recebimento IS NOT NULL)
        OR  status = 'cancelada')
);

CREATE TABLE entrega (
    id_entrega     INTEGER      GENERATED ALWAYS AS IDENTITY,
    id_pedido      INTEGER      NOT NULL,
    logradouro     VARCHAR(120) NOT NULL,
    numero         VARCHAR(10)  NOT NULL,
    complemento    VARCHAR(60),
    bairro         VARCHAR(60)  NOT NULL,
    cidade         VARCHAR(60)  NOT NULL,
    uf             CHAR(2)      NOT NULL,
    cep            CHAR(8)      NOT NULL,
    data_prevista  DATE         NOT NULL,
    data_entrega   DATE,
    status         VARCHAR(15)  NOT NULL DEFAULT 'em_separacao',
    CONSTRAINT pk_entrega PRIMARY KEY (id_entrega),
    CONSTRAINT fk_entrega_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido) ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT uk_entrega_pedido UNIQUE (id_pedido),
    CONSTRAINT ck_entrega_uf     CHECK (uf ~ '^[A-Z]{2}$'),
    CONSTRAINT ck_entrega_cep    CHECK (cep ~ '^[0-9]{8}$'),
    CONSTRAINT ck_entrega_status CHECK (status IN ('em_separacao', 'enviado', 'entregue')),
    CONSTRAINT ck_entrega_data   CHECK (
           (status = 'entregue' AND data_entrega IS NOT NULL)
        OR (status <> 'entregue' AND data_entrega IS NULL))
);

CREATE TABLE movimentacao_estoque (
    id_movimentacao  BIGINT      GENERATED ALWAYS AS IDENTITY,
    id_lote          INTEGER     NOT NULL,
    id_produto       INTEGER     NOT NULL,
    tipo             VARCHAR(20) NOT NULL,
    quantidade       INTEGER     NOT NULL,
    data_hora        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo           VARCHAR(255),
    id_funcionario   INTEGER,
    id_autorizador   INTEGER,
    id_pedido        INTEGER,
    id_compra        INTEGER,
    CONSTRAINT pk_movimentacao_estoque PRIMARY KEY (id_movimentacao),
    CONSTRAINT fk_mov_lote        FOREIGN KEY (id_lote, id_produto)
        REFERENCES lote (id_lote, id_produto)                 ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_mov_item_pedido FOREIGN KEY (id_pedido, id_produto)
        REFERENCES item_pedido (id_pedido, id_produto)        ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_mov_item_compra FOREIGN KEY (id_compra, id_produto)
        REFERENCES item_compra (id_compra, id_produto)        ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_mov_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario)               ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_mov_autorizador FOREIGN KEY (id_autorizador)
        REFERENCES funcionario (id_funcionario)               ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT ck_mov_tipo       CHECK (tipo IN ('entrada', 'reserva', 'liberacao_reserva', 'venda',
                                                 'devolucao', 'perda', 'ajuste_positivo', 'ajuste_negativo')),
    CONSTRAINT ck_mov_quantidade CHECK (quantidade > 0),

    CONSTRAINT ck_mov_vinculo CHECK (
           (tipo = 'entrada' AND id_compra IS NOT NULL AND id_pedido IS NULL)
        OR (tipo IN ('reserva', 'liberacao_reserva', 'venda', 'devolucao') AND id_pedido IS NOT NULL AND id_compra IS NULL)
        OR (tipo IN ('perda', 'ajuste_positivo', 'ajuste_negativo') AND id_pedido IS NULL AND id_compra IS NULL)),

    CONSTRAINT ck_mov_motivo CHECK (
        tipo NOT IN ('devolucao', 'perda', 'ajuste_positivo', 'ajuste_negativo')
        OR (motivo IS NOT NULL AND CHAR_LENGTH(TRIM(motivo)) > 0)),

    CONSTRAINT ck_mov_responsavel CHECK (tipo IN ('reserva', 'liberacao_reserva') OR id_funcionario IS NOT NULL),

    CONSTRAINT ck_mov_autorizacao CHECK (
        tipo NOT IN ('perda', 'ajuste_positivo', 'ajuste_negativo') OR id_autorizador IS NOT NULL)
);

CREATE FUNCTION fn_mov_imutavel() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Movimentacao de estoque nao pode ser alterada nem excluida (RN19). Registre um ajuste.';
END; $$;

CREATE TRIGGER trg01_mov_imutavel BEFORE UPDATE OR DELETE ON movimentacao_estoque
    FOR EACH ROW EXECUTE FUNCTION fn_mov_imutavel();

CREATE INDEX idx_mov_lote_tipo        ON movimentacao_estoque (id_lote, tipo);
CREATE INDEX idx_mov_item_pedido      ON movimentacao_estoque (id_pedido, id_produto);
CREATE INDEX idx_mov_item_compra      ON movimentacao_estoque (id_compra, id_produto);
CREATE INDEX idx_lote_produto_valid   ON lote (id_produto, data_validade);
CREATE INDEX idx_pedido_cliente_data  ON pedido (id_cliente, data_pedido);
CREATE INDEX idx_pedido_canal_data    ON pedido (canal_venda, data_pedido);
CREATE INDEX idx_pagamento_pedido     ON pagamento (id_pedido);
CREATE INDEX idx_cr_status_prevista   ON conta_receber (status, data_prevista);
CREATE INDEX idx_cp_status_vencimento ON conta_pagar (status, data_vencimento);
CREATE INDEX idx_pagconta_conta       ON pagamento_conta (id_conta_pagar);
CREATE INDEX idx_compra_fornecedor    ON compra (id_fornecedor);
CREATE INDEX idx_produto_categoria    ON produto (id_categoria);

CREATE VIEW v_lote_saldo AS
SELECT t.id_lote, t.id_produto, t.saldo_fisico, t.quantidade_reservada,
       t.saldo_fisico - t.quantidade_reservada AS quantidade_disponivel
FROM (
    SELECT l.id_lote, l.id_produto,
        COALESCE(SUM(CASE WHEN m.tipo IN ('entrada', 'devolucao', 'ajuste_positivo') THEN m.quantidade
                          WHEN m.tipo IN ('venda', 'perda', 'ajuste_negativo')       THEN -m.quantidade
                          ELSE 0 END), 0) AS saldo_fisico,
        COALESCE(SUM(CASE WHEN m.tipo = 'reserva'           THEN m.quantidade
                          WHEN m.tipo = 'liberacao_reserva' THEN -m.quantidade
                          WHEN m.tipo = 'venda' AND p.canal_venda = 'loja_virtual' THEN -m.quantidade
                          ELSE 0 END), 0) AS quantidade_reservada
    FROM lote l
    LEFT JOIN movimentacao_estoque m ON m.id_lote = l.id_lote
    LEFT JOIN pedido p               ON p.id_pedido = m.id_pedido
    GROUP BY l.id_lote, l.id_produto
) t;

CREATE VIEW v_item_compra_recebido AS
SELECT ic.id_compra, ic.id_produto, ic.quantidade_comprada,
       COALESCE(SUM(m.quantidade), 0) AS quantidade_recebida
FROM item_compra ic
LEFT JOIN movimentacao_estoque m
       ON m.id_compra = ic.id_compra AND m.id_produto = ic.id_produto AND m.tipo = 'entrada'
GROUP BY ic.id_compra, ic.id_produto, ic.quantidade_comprada;

CREATE VIEW v_conta_pagar_saldo AS
SELECT cp.id_conta_pagar, cp.id_compra, cp.numero_parcela, cp.valor, cp.data_vencimento, cp.status,
       COALESCE(SUM(pc.valor_pago), 0)            AS valor_pago_total,
       cp.valor - COALESCE(SUM(pc.valor_pago), 0) AS saldo_devedor
FROM conta_pagar cp
LEFT JOIN pagamento_conta pc ON pc.id_conta_pagar = cp.id_conta_pagar
GROUP BY cp.id_conta_pagar, cp.id_compra, cp.numero_parcela, cp.valor, cp.data_vencimento, cp.status;

CREATE VIEW v_pedido_total AS
SELECT p.id_pedido,
       COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0)              AS valor_itens,
       p.desconto,
       COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0) - p.desconto AS valor_total
FROM pedido p
LEFT JOIN item_pedido ip ON ip.id_pedido = p.id_pedido
GROUP BY p.id_pedido, p.desconto;

CREATE VIEW v_compra_total AS
SELECT c.id_compra,
       COALESCE(SUM(ic.quantidade_comprada * ic.custo_unitario), 0) AS valor_total
FROM compra c
LEFT JOIN item_compra ic ON ic.id_compra = c.id_compra
GROUP BY c.id_compra;

CREATE VIEW v_produto_estoque AS
SELECT p.id_produto, p.nome, p.estoque_minimo,
       COALESCE(SUM(s.quantidade_disponivel)
                FILTER (WHERE l.data_validade IS NULL OR l.data_validade >= CURRENT_DATE), 0) AS quantidade_disponivel,
       COALESCE(SUM(s.quantidade_disponivel)
                FILTER (WHERE l.data_validade IS NULL OR l.data_validade >= CURRENT_DATE), 0)
           <= p.estoque_minimo AS no_estoque_minimo
FROM produto p
LEFT JOIN lote l           ON l.id_produto = p.id_produto
LEFT JOIN v_lote_saldo s   ON s.id_lote = l.id_lote
GROUP BY p.id_produto, p.nome, p.estoque_minimo;

CREATE VIEW v_cliente_mascarado AS
SELECT id_cliente, nome,
       CONCAT('***.', SUBSTR(cpf, 4, 3), '.', SUBSTR(cpf, 7, 3), '-**') AS cpf,
       telefone, email
FROM cliente;

-- [TRG-02] RN07, RF10, RNF10: o saldo físico e a reserva do lote nunca ficam negativos,
-- e a reserva nunca passa do saldo físico. A trava (FOR UPDATE) na linha do lote faz
-- duas vendas da mesma unidade esperarem uma pela outra: a primeira é aceita e a
-- segunda é recusada (cenário 1 do README).
CREATE FUNCTION fn_mov_saldo() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_saldo     INTEGER;
    v_reservado INTEGER;
    v_canal     VARCHAR(12);
BEGIN
    PERFORM 1 FROM lote WHERE id_lote = NEW.id_lote FOR UPDATE;

    SELECT saldo_fisico, quantidade_reservada INTO v_saldo, v_reservado
    FROM v_lote_saldo WHERE id_lote = NEW.id_lote;

    IF NEW.tipo IN ('entrada', 'devolucao', 'ajuste_positivo') THEN
        v_saldo := v_saldo + NEW.quantidade;
    ELSIF NEW.tipo IN ('venda', 'perda', 'ajuste_negativo') THEN
        v_saldo := v_saldo - NEW.quantidade;
    END IF;

    IF NEW.tipo = 'reserva' THEN
        v_reservado := v_reservado + NEW.quantidade;
    ELSIF NEW.tipo = 'liberacao_reserva' THEN
        v_reservado := v_reservado - NEW.quantidade;
    ELSIF NEW.tipo = 'venda' THEN
        SELECT canal_venda INTO v_canal FROM pedido WHERE id_pedido = NEW.id_pedido;
        IF v_canal = 'loja_virtual' THEN
            v_reservado := v_reservado - NEW.quantidade;   -- a venda da loja virtual consome a reserva (RN21)
        END IF;
    END IF;

    IF v_saldo < 0 THEN
        RAISE EXCEPTION 'Saldo insuficiente no lote % (RN07): o saldo fisico ficaria em %.', NEW.id_lote, v_saldo;
    END IF;
    IF v_reservado < 0 THEN
        RAISE EXCEPTION 'Reserva insuficiente no lote % (RN21): a reserva ficaria em %.', NEW.id_lote, v_reservado;
    END IF;
    IF v_reservado > v_saldo THEN
        RAISE EXCEPTION 'Quantidade indisponivel no lote % (RN07): reservado % maior que o saldo %.', NEW.id_lote, v_reservado, v_saldo;
    END IF;
    RETURN NEW;
END; $$;

CREATE TRIGGER trg02_mov_saldo BEFORE INSERT ON movimentacao_estoque
    FOR EACH ROW EXECUTE FUNCTION fn_mov_saldo();

-- [TRG-03] RF12, RP09: lote vencido não recebe entrada, reserva, venda nem devolução;
-- só admite perda, liberação de reserva e ajuste. A comparação usa a data da própria
-- movimentação, para que a carga de movimentações antigas não seja recusada.
CREATE FUNCTION fn_mov_validade() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_validade DATE;
BEGIN
    IF NEW.tipo IN ('entrada', 'reserva', 'venda', 'devolucao') THEN
        SELECT data_validade INTO v_validade FROM lote WHERE id_lote = NEW.id_lote;
        IF v_validade IS NOT NULL AND v_validade < CAST(NEW.data_hora AS DATE) THEN
            RAISE EXCEPTION 'Lote % vencido em % (RF12): % nao permitida.', NEW.id_lote, v_validade, NEW.tipo;
        END IF;
    END IF;
    RETURN NEW;
END; $$;

CREATE TRIGGER trg03_mov_validade BEFORE INSERT ON movimentacao_estoque
    FOR EACH ROW EXECUTE FUNCTION fn_mov_validade();

-- [TRG-08] RN23, RF36: a soma dos pagamentos de uma parcela não passa do valor dela,
-- e parcela cancelada não recebe pagamento. Depois de cada pagamento, o status da
-- parcela passa a 'paga_parcialmente' ou 'paga'.
CREATE FUNCTION fn_pagconta_valida() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_valor  NUMERIC(12,2);
    v_status VARCHAR(20);
    v_pago   NUMERIC(12,2);
BEGIN
    SELECT valor, status INTO v_valor, v_status
    FROM conta_pagar WHERE id_conta_pagar = NEW.id_conta_pagar FOR UPDATE;

    IF v_status = 'cancelada' THEN
        RAISE EXCEPTION 'A parcela % esta cancelada e nao pode receber pagamento (RN23).', NEW.id_conta_pagar;
    END IF;

    SELECT COALESCE(SUM(valor_pago), 0) INTO v_pago
    FROM pagamento_conta WHERE id_conta_pagar = NEW.id_conta_pagar;

    IF v_pago + NEW.valor_pago > v_valor THEN
        RAISE EXCEPTION 'Pagamento acima do valor da parcela % (RN23): ja pago %, novo %, valor %.',
            NEW.id_conta_pagar, v_pago, NEW.valor_pago, v_valor;
    END IF;
    RETURN NEW;
END; $$;

CREATE FUNCTION fn_pagconta_status() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE conta_pagar cp
    SET status = CASE WHEN s.pago >= cp.valor THEN 'paga' ELSE 'paga_parcialmente' END
    FROM (SELECT SUM(valor_pago) AS pago FROM pagamento_conta
          WHERE id_conta_pagar = NEW.id_conta_pagar) s
    WHERE cp.id_conta_pagar = NEW.id_conta_pagar;
    RETURN NULL;
END; $$;

CREATE TRIGGER trg08_pagconta_valida BEFORE INSERT ON pagamento_conta
    FOR EACH ROW EXECUTE FUNCTION fn_pagconta_valida();

CREATE TRIGGER trg08_pagconta_status AFTER INSERT ON pagamento_conta
    FOR EACH ROW EXECUTE FUNCTION fn_pagconta_status();
