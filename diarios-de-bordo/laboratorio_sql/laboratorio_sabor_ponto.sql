-- ============================================================================
-- LABORATÓRIO PRÁTICO INTEGRADO — Cafeteria & Grãos Artesanais "Sabor & Ponto"
-- Grupo 7 | SGBD: PostgreSQL 16
-- Como rodar: psql -U postgres -f laboratorio_sabor_ponto.sql
-- ============================================================================

DROP DATABASE IF EXISTS sabor_ponto;
CREATE DATABASE sabor_ponto;
\c sabor_ponto

-- ------------------------------------------------------------- BLOCO 3: DDL
CREATE TABLE categoria (
    id_categoria  INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome          VARCHAR(60)  NOT NULL UNIQUE
);

CREATE TABLE fornecedor (
    id_fornecedor INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    cnpj          CHAR(14)     NOT NULL UNIQUE CHECK (cnpj ~ '^[0-9]{14}$')
);

CREATE TABLE produto (
    id_produto    INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome          VARCHAR(120)  NOT NULL,
    preco         NUMERIC(10,2) NOT NULL CHECK (preco > 0),
    id_categoria  INTEGER       NOT NULL REFERENCES categoria (id_categoria),
    id_fornecedor INTEGER       NOT NULL REFERENCES fornecedor (id_fornecedor)
);

CREATE TABLE cliente (
    id_cliente    INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    cpf           CHAR(11)     NOT NULL UNIQUE CHECK (cpf ~ '^[0-9]{11}$'),
    telefone      VARCHAR(20),
    email         VARCHAR(120)
);

CREATE TABLE pedido (
    id_pedido     INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data_pedido   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente    INTEGER       REFERENCES cliente (id_cliente)   -- NULL: venda sem fidelidade
);

CREATE TABLE item_pedido (
    id_pedido      INTEGER       NOT NULL REFERENCES pedido (id_pedido),
    id_produto     INTEGER       NOT NULL REFERENCES produto (id_produto),
    quantidade     INTEGER       NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario > 0),
    PRIMARY KEY (id_pedido, id_produto)
);

-- valor total do pedido: derivado dos itens (3FN), por isso é uma visão e não uma coluna
CREATE VIEW v_pedido_total AS
SELECT p.id_pedido, p.data_pedido, p.id_cliente,
       COALESCE(SUM(i.quantidade * i.preco_unitario), 0) AS valor_total
FROM pedido p LEFT JOIN item_pedido i ON i.id_pedido = p.id_pedido
GROUP BY p.id_pedido, p.data_pedido, p.id_cliente;

-- ------------------------------------------------------------- BLOCO 3: DML
INSERT INTO categoria (nome) VALUES ('Grãos'), ('Lanches'), ('Bebidas Quentes'), ('Métodos de Extração');

INSERT INTO fornecedor (nome, cnpj) VALUES
('Fazenda Alta Mogiana Cafés Especiais', '11222333000144'),
('Padaria Artesanal Trigo Bom', '55666777000188'),
('Barista Utensílios LTDA', '99888777000166');

INSERT INTO produto (nome, preco, id_categoria, id_fornecedor) VALUES
('Café Etiópia 250g', 54.90, 1, 1),
('Café Bourbon Amarelo 250g', 42.00, 1, 1),
('Pão de Queijo Recheado', 9.50, 2, 2),
('Croissant de Amêndoas', 16.00, 2, 2),
('Espresso Duplo', 11.00, 3, 1),
('Cappuccino Artesanal', 15.50, 3, 1),
('Prensa Francesa 350ml', 129.90, 4, 3);

INSERT INTO cliente (nome, cpf, telefone, email) VALUES
('Juliana Prado', '12312312300', '11987654321', 'juliana.prado@email.com'),
('Marcos Vinicius Teles', '45645645600', '11976543210', 'marcos.teles@email.com');

INSERT INTO pedido (data_pedido, id_cliente) VALUES
('2026-10-26 08:15', 1),
('2026-10-26 09:40', 2),
('2026-10-27 16:05', 1),
('2026-10-27 17:30', NULL);      -- cliente sem cadastro de fidelidade

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 54.90), (1, 5, 1, 11.00),
(2, 6, 2, 15.50), (2, 3, 2, 9.50),
(3, 7, 1, 129.90), (3, 2, 1, 42.00),
(4, 4, 1, 16.00);

-- ------------------------------------------- testes de integridade (devem falhar)
\set ON_ERROR_STOP off
\echo '[T1] preço negativo (CHECK)'
INSERT INTO produto (nome, preco, id_categoria, id_fornecedor) VALUES ('Teste', -5.00, 1, 1);
\echo '[T2] item com produto inexistente (FK)'
INSERT INTO item_pedido VALUES (1, 99, 1, 10.00);
\echo '[T3] mesmo produto duas vezes no pedido (PK composta)'
INSERT INTO item_pedido VALUES (1, 1, 2, 54.90);
\echo '[T4] CPF repetido (UNIQUE)'
INSERT INTO cliente (nome, cpf) VALUES ('Outra Juliana', '12312312300');
\echo '[T5] quantidade zero (CHECK)'
INSERT INTO item_pedido VALUES (4, 5, 0, 11.00);

-- ------------------------------------------------------- BLOCO 4: CONSULTAS
\echo '[C1] Produtos acima de R$ 15,00, do mais caro para o mais barato'
SELECT nome, preco
FROM produto
WHERE preco > 15.00
ORDER BY preco DESC;

\echo '[C2] Produto e categoria (INNER JOIN)'
SELECT p.nome AS produto, c.nome AS categoria
FROM produto p
INNER JOIN categoria c ON c.id_categoria = p.id_categoria
ORDER BY c.nome, p.nome;

\echo '[C3] Pedido, data, cliente e valor total'
SELECT t.id_pedido, t.data_pedido, c.nome AS cliente, t.valor_total
FROM v_pedido_total t
INNER JOIN cliente c ON c.id_cliente = t.id_cliente
ORDER BY t.id_pedido;

\echo '[C3b] Variação com LEFT JOIN: inclui a venda sem cadastro de fidelidade'
SELECT t.id_pedido, t.data_pedido, COALESCE(c.nome, '(sem cadastro)') AS cliente, t.valor_total
FROM v_pedido_total t
LEFT JOIN cliente c ON c.id_cliente = t.id_cliente
ORDER BY t.id_pedido;
