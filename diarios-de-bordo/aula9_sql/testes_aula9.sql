\c petly_club
\echo '[TESTE 01] CPF repetido (UNIQUE)'
INSERT INTO cliente (nome, cpf, email) VALUES ('Maria S. Copia', '12345678901', 'outra@email.com');
\echo '[TESTE 02] Pedido de cliente inexistente (FOREIGN KEY)'
INSERT INTO pedido (canal_venda, tipo_recebimento, id_cliente) VALUES ('loja virtual', 'entrega', 999);
\echo '[TESTE 03a] Produto com preco zero (CHECK)'
INSERT INTO produto (nome, marca, preco, id_categoria) VALUES ('Petisco Dental', 'Marca C', 0, 1);
\echo '[TESTE 03b] Venda na loja fisica sem funcionario (CHECK)'
INSERT INTO pedido (canal_venda, tipo_recebimento, id_cliente) VALUES ('loja fisica', 'balcao', 1);
\echo '[TESTE 03c] Produto sem categoria (NOT NULL)'
INSERT INTO produto (nome, marca, preco) VALUES ('Coleira P', 'Marca D', 39.90);
\echo '[TESTE 04] Mesmo produto duas vezes no mesmo pedido (PK composta)'
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES (1, 1, 3, 189.90);
\echo '[CONFERENCIA] Nada foi gravado pelos testes'
SELECT (SELECT count(*) FROM cliente) AS clientes, (SELECT count(*) FROM pedido) AS pedidos,
       (SELECT count(*) FROM produto) AS produtos, (SELECT count(*) FROM item_pedido) AS itens;
