-- Petly Club — Grupo 7 — Recorte da Aula 9 (venda)
-- CLIENTE -> PEDIDO -> ITEM_PEDIDO (associativa N:N) <- PRODUTO
-- SGBD: PostgreSQL 16

CREATE DATABASE petly_club;
\c petly_club

-- 1. TABELAS INDEPENDENTES

CREATE TABLE categoria (
    id_categoria   SERIAL        PRIMARY KEY,
    nome           VARCHAR(60)   NOT NULL UNIQUE,
    descricao      VARCHAR(255)
);

CREATE TABLE cliente (
    id_cliente     SERIAL        PRIMARY KEY,
    nome           VARCHAR(120)  NOT NULL,
    cpf            CHAR(11)      NOT NULL UNIQUE,                 -- RN18
    telefone       VARCHAR(15),
    email          VARCHAR(120),
    CONSTRAINT ck_cliente_cpf CHECK (cpf ~ '^[0-9]{11}$')
);

CREATE TABLE funcionario (
    id_funcionario SERIAL        PRIMARY KEY,
    nome           VARCHAR(120)  NOT NULL,
    cpf            CHAR(11)      NOT NULL UNIQUE,
    cargo          VARCHAR(30)   NOT NULL,
    login          VARCHAR(40)   NOT NULL UNIQUE,
    senha_hash     VARCHAR(255)  NOT NULL,                       -- RNF02
    CONSTRAINT ck_funcionario_cargo CHECK
        (cargo IN ('atendente', 'operador de caixa', 'estoquista', 'gerente'))  -- RP08
);

-- 2. TABELAS DEPENDENTES E ASSOCIATIVAS (N:N)

CREATE TABLE produto (
    id_produto        SERIAL        PRIMARY KEY,
    nome              VARCHAR(120)  NOT NULL,
    descricao         VARCHAR(255),
    marca             VARCHAR(60)   NOT NULL,
    codigo_barras     VARCHAR(14)   UNIQUE,                       -- RNF05
    preco             NUMERIC(10,2) NOT NULL,
    estoque_minimo    INTEGER       NOT NULL DEFAULT 0,           -- RP03
    controla_validade BOOLEAN       NOT NULL DEFAULT FALSE,       -- RN11
    id_categoria      INTEGER       NOT NULL,                     -- RN04
    CONSTRAINT ck_produto_preco   CHECK (preco > 0),
    CONSTRAINT ck_produto_minimo  CHECK (estoque_minimo >= 0),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
);

CREATE TABLE pedido (
    id_pedido        SERIAL        PRIMARY KEY,
    data_pedido      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canal_venda      VARCHAR(15)   NOT NULL,                      -- RN05
    tipo_recebimento VARCHAR(20)   NOT NULL,                      -- RN17
    status           VARCHAR(20)   NOT NULL DEFAULT 'pendente',   -- RN16
    desconto         NUMERIC(10,2) NOT NULL DEFAULT 0,
    id_cliente       INTEGER       NOT NULL,                      -- RN01, RP02
    id_funcionario   INTEGER,                                     -- RN14
    CONSTRAINT ck_pedido_canal  CHECK (canal_venda IN ('loja fisica', 'loja virtual')),
    CONSTRAINT ck_pedido_receb  CHECK (tipo_recebimento IN ('balcao', 'retirada na loja', 'entrega')),
    CONSTRAINT ck_pedido_status CHECK (status IN ('pendente', 'pago', 'em preparacao',
                                       'enviado', 'entregue', 'retirado', 'cancelado')),
    CONSTRAINT ck_pedido_desconto CHECK (desconto >= 0),
    -- venda no balcão só existe na loja física, e a loja física sempre tem funcionário
    CONSTRAINT ck_pedido_balcao CHECK (tipo_recebimento <> 'balcao' OR canal_venda = 'loja fisica'),
    CONSTRAINT ck_pedido_func   CHECK (canal_venda <> 'loja fisica' OR id_funcionario IS NOT NULL),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente),
    CONSTRAINT fk_pedido_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario)
);

CREATE TABLE item_pedido (
    id_pedido      INTEGER       NOT NULL,
    id_produto     INTEGER       NOT NULL,
    quantidade     INTEGER       NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL,                        -- RN13
    CONSTRAINT pk_item_pedido PRIMARY KEY (id_pedido, id_produto),
    CONSTRAINT ck_item_qtd    CHECK (quantidade > 0),
    CONSTRAINT ck_item_preco  CHECK (preco_unitario > 0),
    CONSTRAINT fk_item_pedido  FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_item_produto FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto)
);

-- 3. DADOS VÁLIDOS PARA OS TESTES

INSERT INTO categoria (nome, descricao) VALUES
    ('Alimentacao', 'Racoes e petiscos'),
    ('Higiene', 'Shampoos, tapetes higienicos e areias');

INSERT INTO cliente (nome, cpf, telefone, email) VALUES
    ('Maria Souza', '12345678901', '11988887777', 'maria@email.com'),
    ('Joao Lima',   '98765432100', NULL,          'joao@email.com');

INSERT INTO funcionario (nome, cpf, cargo, login, senha_hash) VALUES
    ('Ana Caixa', '11122233344', 'operador de caixa', 'ana.caixa', '$2b$12$exemplohash');

INSERT INTO produto (nome, marca, codigo_barras, preco, estoque_minimo, controla_validade, id_categoria) VALUES
    ('Racao para Cao 15 kg', 'Marca A', '7890000000011', 189.90, 5, TRUE,  1),
    ('Shampoo Neutro 500 ml', 'Marca B', '7890000000028',  29.90, 10, TRUE, 2);

INSERT INTO pedido (canal_venda, tipo_recebimento, status, id_cliente, id_funcionario) VALUES
    ('loja fisica',  'balcao',  'pago',     1, 1),
    ('loja virtual', 'entrega', 'pendente', 2, NULL);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
    (1, 1, 2, 189.90),
    (1, 2, 1,  29.90),
    (2, 1, 1, 189.90);
