# Projeto ERP — Petly Club

Primeira entrega do Projeto Integrador da disciplina **Modelagem de Banco de Dados** (UNICID, 2026/2): do problema real ao modelo conceitual de dados.

## Sumário

1. [Identificação da equipe](#1-identificação-da-equipe)
2. [Caracterização da empresa](#2-caracterização-da-empresa)
3. [Justificativa da escolha](#3-justificativa-da-escolha)
4. [Problemas identificados](#4-problemas-identificados)
5. [Processos de negócio](#5-processos-de-negócio)
6. [Requisitos funcionais](#6-requisitos-funcionais)
7. [Requisitos não funcionais](#7-requisitos-não-funcionais)
8. [Regras de negócio](#8-regras-de-negócio)
9. [Restrições e políticas organizacionais](#9-restrições-e-políticas-organizacionais)
10. [Fluxogramas](#10-fluxogramas)
11. [Entidades](#11-entidades)
12. [Atributos](#12-atributos)
13. [Relacionamentos](#13-relacionamentos)
14. [Cardinalidades](#14-cardinalidades)
15. [Dicionário de dados conceitual](#15-dicionário-de-dados-conceitual)
16. [DER](#16-der)
17. [Justificativas técnicas](#17-justificativas-técnicas)
18. [Conclusão](#18-conclusão)
- [Uso de Inteligência Artificial](#uso-de-inteligência-artificial)

## 1. Identificação da equipe

**Grupo:** 7  
**Empresa:** Petly Club, pet shop fictício de pequeno porte inspirado na Cobasi e no Sam's Club

**Gerente do grupo:** Nicolas Da Silva Santos

| Integrante | RGM |
|---|---|
| Amin Brayan Illanes Callata | 48214051 |
| Carolina Da Silva Burrego | 47793431 |
| Gabriela Colombo Martins Blach | 47132281 |
| João Paulo de Lima Rodrigues | 47850876 |
| Murilo Queiroz Braga | 48091251 |
| Nicolas Da Silva Santos (gerente do grupo) | 47889756 |
| Nicolas Miguel Tavares | 47658037 |
| Ryan Everton Andrade Simões | 47647663 |
| Vinicius Ferreira da Silva | 47432691 |
| Yasmin America Mollinedo Alba | 47071303 |

## 2. Caracterização da empresa

**Nome:** Petly Club

**Segmento:** Pet shop — comércio de produtos para animais de estimação

**Porte:** Pequena empresa, com uma loja física e uma loja virtual

**Inspiração:** Cobasi e Sam's Club

A Petly Club é um pet shop fictício de pequeno porte, com operação simulada para o escopo da disciplina. O modelo de negócio foi inspirado em duas empresas reais: da **Cobasi**, vêm os produtos, a mecânica de compras e a venda de rações e demais itens para animais; do **Sam's Club**, vem o modelo de clube de compras, em que o cliente precisa obrigatoriamente ter cadastro para comprar.

A empresa atua exclusivamente na venda de produtos para animais de estimação, por dois canais: uma loja física, com atendimento presencial e caixa, e uma loja virtual, na qual o cliente realiza o pedido pela internet e escolhe entre receber em casa ou retirar na loja.

### O que a empresa vende

- **Alimentação:** rações secas e úmidas, petiscos e suplementos;
- **Higiene e limpeza:** areia sanitária, tapetes higiênicos e shampoos;
- **Acessórios:** coleiras, guias, camas, comedouros, bebedouros e brinquedos;
- **Produtos para outras espécies:** gaiolas, aquários, filtros e alimentos para aves, peixes e roedores.

A empresa **não** oferece serviços de banho e tosa, atendimento veterinário ou venda de animais. Toda a sua operação gira em torno da comercialização de produtos.

### Principais clientes

Os clientes são tutores de animais de estimação (pessoas físicas). Parte das compras é recorrente, como ração e areia sanitária, e parte é ocasional, como acessórios e brinquedos. Na loja física predominam clientes da região, que buscam compra imediata; na loja virtual, clientes que valorizam a conveniência da entrega, principalmente em compras volumosas e recorrentes.

Inspirada no modelo de clube de compras do Sam's Club, a Petly Club só vende para clientes cadastrados, tanto na loja física quanto na loja virtual. Quem ainda não tem cadastro pode fazê-lo no momento da primeira compra.

### Principais setores

- **Vendas — loja física:** atendimento ao cliente e operação do caixa;
- **Vendas — loja virtual:** recebimento dos pedidos online, separação e expedição;
- **Estoque:** recebimento, conferência e armazenamento das mercadorias, incluindo o acompanhamento da validade dos produtos alimentícios;
- **Compras:** relacionamento com fornecedores e reposição de mercadorias;
- **Financeiro:** contas a pagar e a receber, controle dos pagamentos e fechamento de caixa;
- **Gerência:** definição de preços e promoções e acompanhamento dos resultados.

### Como a empresa funciona atualmente

Os dois canais de venda funcionam de forma separada. A loja física registra suas vendas no sistema do caixa, enquanto a loja virtual utiliza uma plataforma de comércio eletrônico própria. No entanto, as mercadorias ficam em um único estoque, compartilhado pelos dois canais e controlado em planilha atualizada manualmente.

Produtos e clientes são cadastrados separadamente em cada canal. As compras são decididas pela gerência com base na conferência das prateleiras e em listas de fornecedores mantidas em planilha. O financeiro consolida manualmente, ao final do dia, os valores do caixa e das vendas online.

Com isso, a empresa possui as informações de que precisa, mas elas estão espalhadas em sistemas e planilhas que não se comunicam.

### Informações importantes para o negócio

- Clientes e endereços de entrega dos pedidos da loja virtual;
- Produtos, categorias e preços;
- Quantidade disponível em estoque e validade dos produtos alimentícios;
- Vendas de cada canal e os produtos vendidos em cada uma;
- Formas de pagamento;
- Fornecedores e compras realizadas;
- Contas a pagar e a receber.

## 3. Justificativa da escolha

A Petly Club foi escolhida por reunir, em um negócio de fácil compreensão, as características necessárias para um projeto de modelagem de dados e de ERP.

**Processos que podem ser analisados.** A empresa possui uma cadeia completa de processos comerciais: venda presencial, venda online, entrega ou retirada, reposição de mercadorias, recebimento de fornecedores e controle financeiro. Cada um deles gera informações que precisam ser registradas e consultadas.

**Problemas de organização das informações.** Os dois canais de venda utilizam o mesmo estoque, mas registram suas operações em sistemas separados, e o estoque é controlado manualmente. Esse cenário gera cadastros duplicados, informações desatualizadas e dificuldade de acompanhar os resultados, situação típica que um banco de dados único e bem modelado resolve.

**Necessidade de integração.** Na Petly Club, os setores dependem uns dos outros: uma venda, em qualquer canal, reduz o estoque; a queda do estoque exige uma compra; a compra gera uma conta a pagar; e a venda gera uma conta a receber. Essa dependência evidencia a necessidade de um sistema integrado, e não de controles isolados por setor.

**Aplicação de um ERP, BI e IA.** Com os dados organizados, a empresa poderá responder a perguntas estratégicas, como: quais produtos têm maior giro em cada canal, quando um produto precisa ser reposto e quando um cliente provavelmente voltará a comprar ração. Como boa parte das compras do segmento é recorrente, os dados históricos são especialmente úteis para análises e previsões.

**Cadastro obrigatório dos clientes.** Como toda compra exige o cadastro do cliente, modelo inspirado no Sam's Club, a empresa passa a ter o histórico de compras de todos os seus clientes. Isso permite identificar padrões de recompra e oferecer um atendimento mais personalizado, o que não seria possível se parte das vendas fosse feita sem identificação.

**Delimitação do escopo.** A equipe optou por excluir serviços (banho e tosa e atendimento veterinário) e a venda de animais. Os serviços exigiriam controlar agendamentos, profissionais, animais atendidos e histórico clínico, o que pertence a outro domínio de negócio; a venda de animais envolve exigências sanitárias e legais específicas. Com esse recorte, a equipe pode concentrar a modelagem nos processos de comercialização de produtos e tratá-los com maior profundidade.

## 4. Problemas identificados

| Problema | Consequência | Necessidade |
|---|---|---|
| Produtos e clientes são cadastrados separadamente no sistema da loja física e na plataforma da loja virtual | Gera cadastros duplicados | Cadastro único de clientes e produtos para os dois canais |
| O estoque, que é compartilhado pelos dois canais, é controlado em uma planilha atualizada manualmente | Gera informações desatualizadas e risco de vender produtos sem estoque | Estoque único atualizado automaticamente a cada venda e recebimento |
| As vendas da loja física e virtual funcionam de forma separada e não se comunicam com as outras planilhas | Informações necessárias ao negócio ficam espalhadas e isoladas | Registro de todas as vendas em um único sistema, identificando o canal |
| O setor financeiro realiza a consolidação dos valores do caixa e das vendas online de forma manual ao final do dia | Retrabalho diário devido à ausência de um sistema integrado e dependência de controles isolados | Integração entre vendas, pagamentos e contas a pagar, com fechamento de caixa automático |
| As decisões de compras são baseadas na conferência manual das prateleiras e em planilhas de fornecedores | Sem automatização, exigindo controle manual para identificar a necessidade de reposição de mercadorias | Alerta de estoque mínimo e registro das compras por fornecedor |
| A validade dos produtos alimentícios não é controlada de forma sistemática | Risco de manter produtos vencidos disponíveis para venda | Registro de lote e validade na entrada e bloqueio da venda de produtos vencidos |
| Informações espalhadas em sistemas separados e operadas com controles isolados por cada setor | Dificuldade de acompanhar os resultados financeiros e o desempenho das vendas | Relatórios integrados de vendas por produto, categoria e canal |

## 5. Processos de negócio

### 1. Venda na loja física

Cliente → Verificar o cadastro → Escolhe produtos → Atendente registra o pedido → Caixa recebe o pagamento (por Pix, cartão de crédito/débito ou dinheiro) → Atualização do estoque

- **Quem participa** - Cliente, atendente ou operador de caixa e funcionário do estoque.
- **O que inicia o processo** - O cliente escolhe um ou mais produtos na loja física.
- **O que acontece** - Verifica-se se o cliente possui cadastro; se tiver, segue para a compra, e se não tiver, o cliente é cadastrado na hora (RP02). Os produtos e suas quantidades são registrados no pedido pelo funcionário responsável (RN14), o pagamento é realizado e a quantidade disponível é reduzida no estoque.
- **Qual informação é gerada** - Cliente, funcionário responsável, pedido, produtos vendidos, quantidades, preços praticados, forma de pagamento e canal de venda.
- **Qual é o resultado** - Venda registrada, pagamento recebido e estoque atualizado.

### 2. Venda na loja virtual

Cliente → Cadastra → Acessa a loja virtual → Seleciona produtos → Realiza o pedido → Efetua o pagamento (por Pix ou cartão de crédito/débito) → Pagamento confirmado (pagamento não confirmado resulta em cancelamento da compra) → Baixa no estoque → Pedido é separado

- **Quem participa** - Cliente, funcionário responsável pelos pedidos virtuais, estoque e financeiro.
- **O que inicia o processo** - O cliente acessa a loja virtual e seleciona os produtos.
- **O que acontece** - O cliente realiza o pedido, escolhe a forma de recebimento (entrega ou retirada), informa o endereço quando escolhe entrega e efetua o pagamento. Com o pagamento confirmado, o estoque é atualizado e os produtos são separados. Se o pagamento não for confirmado, o pedido é cancelado.
- **Qual informação é gerada** - Dados do cliente, endereço de entrega, pedido, itens, quantidades, preços, pagamento, status e canal de venda.
- **Qual é o resultado** - Pedido online registrado, pago e preparado para entrega ou retirada.

### 3. Entrega do pedido

Pedido online → Produtos são separados → Pedido é conferido → Pedido é enviado → Entrega é confirmada

- **Quem participa** - Funcionário da loja virtual, funcionário do estoque, responsável pela entrega e cliente.
- **O que inicia o processo** - A confirmação de um pedido online com entrega em domicílio.
- **O que acontece** - Os produtos são separados, conferidos e encaminhados para entrega. Quando o cliente recebe, a entrega é confirmada.
- **Qual informação é gerada** - Endereço de entrega, data prevista, data da entrega e status do pedido e da entrega.
- **Qual é o resultado** - Produtos entregues ao cliente e pedido finalizado.

### 4. Retirada do pedido na loja

Pedido online → Produtos são separados → Pedido fica disponível → Cliente vai à loja → Funcionário confere o código do pedido → Funcionário entrega o pedido

- **Quem participa** - Cliente, funcionário da loja virtual, atendente e estoquista.
- **O que inicia o processo** - O cliente escolhe a opção de retirada na loja.
- **O que acontece** - Os produtos são separados e o pedido fica disponível para retirada. O cliente comparece à loja, o funcionário confere o código do pedido e entrega os produtos.
- **Qual informação é gerada** - Pedido, código do pedido, produtos separados, opção de retirada e status do pedido.
- **Qual é o resultado** - Pedido retirado pelo cliente e processo de venda concluído.

### 5. Controle de estoque

Venda ou recebimento de mercadoria → Estoque é movimentado → Quantidade é conferida → Validade dos lotes é acompanhada → Saldo é atualizado

- **Quem participa** - Estoquista, atendente, funcionário da loja virtual e gerência.
- **O que inicia o processo** - Uma venda, o recebimento de produtos ou uma conferência do estoque.
- **O que acontece** - As entradas e saídas são registradas, as quantidades são conferidas e a validade dos lotes dos produtos com controle de validade é acompanhada. Produtos vencidos são retirados da venda (RP09).
- **Qual informação é gerada** - Produto, lote, quantidade disponível e validade.
- **Qual é o resultado** - Estoque atualizado e produtos disponíveis para os dois canais de venda.

### 6. Reposição de mercadorias

Estoque atinge o nível mínimo → Gerência identifica a necessidade → Fornecedor é consultado → Compra é realizada → Contas a pagar são geradas → Mercadorias são recebidas

- **Quem participa** - Estoquista, gerência, setor de compras, financeiro e fornecedor.
- **O que inicia o processo** - A quantidade de um produto atinge o estoque mínimo definido pela gerência (RP03).
- **O que acontece** - A necessidade de reposição é verificada, o fornecedor é consultado e uma compra é realizada. O valor da compra gera uma ou mais contas a pagar, podendo ser dividido em parcelas (RN12).
- **Qual informação é gerada** - Produto necessário, quantidade da compra, custo unitário, fornecedor, dados da compra e parcelas a pagar.
- **Qual é o resultado** - Mercadorias solicitadas ao fornecedor para recompor o estoque e contas a pagar registradas.

### 7. Recebimento de mercadorias

Fornecedor entrega mercadorias → Funcionário autorizado recebe → Produtos são conferidos → Verificar registro do lote e validade → Produtos são armazenados → Estoque é atualizado

- **Quem participa** - Fornecedor, funcionário autorizado do estoque e setor de compras.
- **O que inicia o processo** - A chegada das mercadorias entregues pelo fornecedor.
- **O que acontece** - Os produtos recebidos são conferidos com a compra e armazenados. Somente funcionários autorizados registram a entrada (RP06). Para produtos com controle de validade, o lote e a data de validade são registrados (RN11).
- **Qual informação é gerada** - Fornecedor, compra, produtos recebidos, quantidades, lote, validade e data de entrada.
- **Qual é o resultado** - Mercadorias armazenadas e saldo do estoque atualizado.

### 8. Pagamento da venda

Pedido registrado → Cliente escolhe a forma de pagamento (por Pix, cartão de crédito/débito ou dinheiro) → Pagamento é processado → Valor é registrado → Venda é confirmada

- **Quem participa** - Cliente, operador de caixa ou plataforma da loja virtual e financeiro.
- **O que inicia o processo** - A finalização de um pedido na loja física ou virtual.
- **O que acontece** - O cliente escolhe uma ou mais formas de pagamento (RN15), o valor é processado e a venda é confirmada. Descontos acima do limite precisam de autorização da gerência (RP05).
- **Qual informação é gerada** - Forma de pagamento, valor recebido, desconto, pedido relacionado e status do pagamento.
- **Qual é o resultado** - Pagamento registrado e venda confirmada.

### 9. Controle financeiro

Vendas e compras são registradas → Valores são conferidos → Contas a receber e a pagar são controladas → Caixa é fechado → Resultado é consolidado

- **Quem participa** - Financeiro, operador de caixa e gerência.
- **O que inicia o processo** - O registro de uma venda, compra ou pagamento.
- **O que acontece** - O financeiro controla os valores recebidos das vendas e as parcelas devidas aos fornecedores, e consolida as vendas da loja física e da loja virtual.
- **Qual informação é gerada** - Contas a pagar, pagamentos recebidos e pendentes, valores do caixa e valores das vendas online.
- **Qual é o resultado** - Fechamento do caixa e informações financeiras consolidadas.

### 10. Cadastro de produtos

Novo produto → Funcionário cadastra informações → Categoria e preço são definidos → Estoque mínimo e controle de validade são definidos → Produto fica disponível para venda

- **Quem participa** - Funcionário responsável pelo cadastro, estoque e gerência.
- **O que inicia o processo** - A inclusão de um novo produto no catálogo da empresa.
- **O que acontece** - São cadastrados o nome, a descrição, a marca, o código de barras, a categoria, o preço atual, o estoque mínimo e se o produto exige controle de validade. Somente a gerência define e altera preços (RP04).
- **Qual informação é gerada** - Identificador, nome, descrição, marca, código de barras, categoria, preço, estoque mínimo e controle de validade.
- **Qual é o resultado** - Produto cadastrado e disponível para utilização nos pedidos.

### 11. Cadastro de clientes

Cliente realiza uma compra → Dados são informados → Cadastro é realizado → Cliente é vinculado ao pedido

- **Quem participa** - Cliente e funcionário responsável pelo atendimento ou sistema da loja virtual.
- **O que inicia o processo** - Uma compra, já que toda venda exige a identificação do cliente (RP02).
- **O que acontece** - São registrados os dados do cliente. O CPF não pode ser cadastrado mais de uma vez (RN18). O endereço de entrega não faz parte do cadastro: ele é informado em cada pedido da loja virtual com entrega.
- **Qual informação é gerada** - Nome, CPF, telefone e e-mail.
- **Qual é o resultado** - Cliente cadastrado e relacionado ao pedido realizado.

### 12. Cancelamento de pedido

Solicitação de cancelamento → Verificação da regra de cancelamento → Autorização (quando necessária) → Pedido é cancelado → Produtos voltam ao estoque

- **Quem participa** - Cliente, atendente ou operador de caixa, gerência e funcionário da loja virtual.
- **O que inicia o processo** - O pedido do cliente para cancelar uma compra ou a falta de confirmação do pagamento online.
- **O que acontece** - Pedidos da loja virtual só podem ser cancelados antes do envio; cancelamentos na loja física precisam de autorização da gerência (RP07). Os produtos do pedido cancelado voltam ao estoque.
- **Qual informação é gerada** - Pedido cancelado, funcionário que autorizou, status do pedido e do pagamento e quantidades devolvidas ao estoque.
- **Qual é o resultado** - Pedido cancelado e estoque atualizado.

## 6. Requisitos funcionais

### Cadastros Básicos

- **RF01:** O sistema deverá permitir o cadastro completo de produtos, incluindo nome, descrição, categoria, marca, código de barras, preço de venda e estoque mínimo.
- **RF02:** O sistema deverá ter uma opção para marcar se o produto necessita de acompanhamento de lote e data de validade.
- **RF03:** O sistema deverá cadastrar os clientes, com nome, CPF, telefone e e-mail.
- **RF04:** O sistema deverá manter o registro de fornecedores da loja.
- **RF05:** O sistema deverá cadastrar os funcionários e definir o perfil de acesso de cada um de acordo com o cargo.
- **RF28:** O sistema deverá cadastrar as categorias de produtos.

### Estoque Único e Validade

- **RF06:** O sistema deverá centralizar a contagem do estoque em um saldo único, atendendo ao mesmo tempo as vendas da loja virtual e da loja física.
- **RF07:** O sistema deverá registrar as compras de reposição feitas aos fornecedores e a entrada das mercadorias recebidas no estoque.
- **RF08:** O sistema deverá gravar a data de validade e o lote de cada produto com controle de validade no momento do recebimento.
- **RF09:** O sistema deverá dar baixa no saldo do estoque automaticamente assim que qualquer venda for concluída.
- **RF10:** O sistema deverá impedir a venda de uma quantidade maior do que a disponível em estoque.
- **RF11:** O sistema deverá sugerir a saída prioritária dos lotes que estiverem mais próximos de vencer.
- **RF12:** O sistema deverá bloquear a saída e a venda de produtos cuja data de validade já tenha expirado.
- **RF13:** O sistema deverá emitir um alerta quando o saldo em estoque de um produto atingir o estoque mínimo definido para ele.

### Operação de Vendas no Caixa (PDV)

- **RF14:** O sistema deverá registrar as vendas realizadas no balcão da loja física, vinculando o cliente e o funcionário responsável.
- **RF15:** O sistema deverá aceitar pagamentos em dinheiro, PIX e cartões de débito ou crédito, e permitir mais de uma forma de pagamento no mesmo pedido.
- **RF16:** O sistema deverá permitir cancelar itens ou vendas no caixa somente quando o gerente autorizar com sua senha.
- **RF30:** O sistema deverá permitir cadastrar o cliente no momento da venda no caixa.
- **RF32:** O sistema deverá permitir aplicar desconto no pedido, exigindo autorização da gerência quando o desconto ultrapassar o limite definido.

### Loja Virtual e Pedidos Online

- **RF17:** O sistema deverá mostrar no catálogo da loja virtual apenas os produtos que possuem saldo disponível em estoque.
- **RF18:** O sistema deverá permitir que o cliente opte por receber os produtos em casa ou retirar presencialmente na loja física.
- **RF19:** O sistema deverá registrar os pedidos feitos através da loja virtual.
- **RF20:** O sistema deverá dar baixa no estoque dos pedidos da loja virtual assim que o pagamento for confirmado.
- **RF21:** O sistema deverá cancelar o pedido da loja virtual caso o pagamento não seja confirmado e devolver ao estoque os produtos de pedidos cancelados.
- **RF22:** O sistema deverá registrar o envio e a confirmação de entrega para os pedidos com opção de entrega em domicílio.
- **RF23:** O sistema deverá confirmar a retirada do pedido da loja virtual mediante a conferência do código do pedido no balcão.
- **RF29:** O sistema deverá registrar e atualizar o status de cada pedido.

### Financeiro e Consultas

- **RF24:** O sistema deverá registrar as contas a pagar geradas pelas compras de reposição, permitindo dividir o valor em parcelas com datas de vencimento.
- **RF25:** O sistema deverá registrar os valores a receber provenientes das vendas da loja física e da loja virtual.
- **RF26:** O sistema deverá fazer o fechamento diário do caixa acumulando todas as entradas do dia.
- **RF27:** O sistema deverá permitir a busca pelo histórico de pedidos de cada cliente.
- **RF31:** O sistema deverá emitir relatórios de vendas por produto, categoria e canal de venda.

## 7. Requisitos não funcionais

### Segurança e Acessos

- **RNF01:** O sistema deverá restringir os acessos a módulos e telas de acordo com o perfil de acesso do cargo de cada funcionário.
- **RNF02:** O sistema deverá armazenar as senhas dos funcionários utilizando algoritmo de hash.
- **RNF03:** O sistema deverá guardar um histórico das ações realizadas no sistema pelos funcionários, especialmente alterações diretas no estoque.
- **RNF09:** O sistema deverá proteger os dados pessoais dos clientes, como CPF, telefone e e-mail, de acordo com a LGPD.

### Desempenho e Facilidade de Uso

- **RNF04:** O sistema deverá atualizar as informações de saldo do estoque em tempo adequado para que a loja física e a loja virtual fiquem sempre em sintonia.
- **RNF05:** O sistema deverá permitir a leitura e busca rápida de produtos no caixa via código de barras.
- **RNF06:** O sistema deverá oferecer telas de operação do caixa com visual claro e navegação simples para o funcionário.

### Funcionamento e Cópia de Segurança

- **RNF07:** O sistema deverá manter a loja virtual funcionando continuamente para acesso público.
- **RNF08:** O sistema deverá realizar backups do banco de dados diariamente de forma automática.

## 8. Regras de negócio

**RN01.** Um cliente pode fazer vários pedidos e todo pedido precisa estar ligado a um cliente.

**RN02.** Um cliente pode estar cadastrado mesmo sem ter feito nenhum pedido.

**RN03.** Todo pedido precisa ter pelo menos um produto e um produto pode estar em vários pedidos.

**RN04.** Todo produto precisa pertencer a uma categoria.

**RN05.** Todo pedido precisa ter um canal, podendo ser loja física ou loja virtual.

**RN06.** Quando um produto é vendido, a quantidade no estoque diminui.

**RN07.** Não pode vender uma quantidade maior do que a disponível no estoque.

**RN08.** Quando chegam novos produtos de um fornecedor, a quantidade no estoque aumenta.

**RN09.** Um produto pode ter vários fornecedores e um fornecedor pode fornecer vários produtos.

**RN10.** Toda compra de reposição precisa estar ligada a um fornecedor e ter pelo menos um produto.

**RN11.** Os produtos com controle de validade devem ter o lote e a data de validade registrados na entrada no estoque.

**RN12.** Toda compra de reposição gera pelo menos uma conta a pagar, e o valor da compra pode ser dividido em parcelas com datas de vencimento.

**RN13.** O preço registrado no pedido deve ser o preço do produto no momento da venda.

**RN14.** Toda venda feita na loja física deve ser registrada por um funcionário.

**RN15.** Todo pedido deve ter pelo menos um pagamento registrado, e um mesmo pedido pode ser pago com uma ou mais formas de pagamento. Na loja virtual, o pagamento pode ficar pendente até a confirmação.

**RN16.** Todo pedido precisa ter um status, como pendente, pago, cancelado, em preparação, enviado, entregue ou retirado.

**RN17.** Nos pedidos da loja virtual, o cliente pode escolher receber em casa ou retirar na loja. Cada pedido pode ter no máximo uma entrega.

**RN18.** O CPF de um cliente não pode ser cadastrado mais de uma vez.

## 9. Restrições e políticas organizacionais

**RP01.** O estoque da loja física e da loja virtual é o mesmo.

**Justificativa:** Evita que a loja física e a loja virtual vendam o mesmo produto sem saber o saldo real, problema que a empresa tem hoje com o controle em planilha.

**RP02.** Toda venda precisa estar ligada a um cliente cadastrado, inclusive as vendas feitas no caixa da loja física.

**Justificativa:** Modelo de clube de compras inspirado no Sam's Club: garante que toda venda tenha um cliente identificado e que a empresa tenha o histórico de compras de todos os clientes.

**RP03.** Quando o estoque chegar ao nível mínimo definido pela gerência, deve ser feita a reposição.

**Justificativa:** Evita a falta de produtos e substitui a decisão de compra baseada na conferência manual das prateleiras por um critério definido pela gerência.

**RP04.** Somente a gerência pode alterar os preços dos produtos.

**Justificativa:** O preço afeta diretamente a margem da empresa e precisa ser o mesmo nos dois canais; limitar a alteração à gerência evita mudanças indevidas.

**RP05.** Descontos acima do limite definido pela empresa precisam de autorização da gerência.

**Justificativa:** Protege a margem da empresa: descontos altos passam por quem responde pelo resultado da loja.

**RP06.** Somente funcionários autorizados podem registrar a entrada de mercadorias no estoque.

**Justificativa:** Garante que as mercadorias sejam conferidas com a compra e que o lote e a validade sejam registrados corretamente na entrada.

**RP07.** Pedidos da loja virtual só podem ser cancelados antes do envio. Cancelamentos na loja física precisam de autorização da gerência.

**Justificativa:** Depois do envio, os produtos já saíram do estoque e estão em transporte; na loja física, a autorização evita cancelamentos indevidos no caixa.

**RP08.** Cada funcionário deve ter acesso ao sistema de acordo com seu cargo.

**Justificativa:** Protege os dados dos clientes e evita que funcionários alterem informações que não fazem parte da sua função.

**RP09.** Produtos vencidos devem ser retirados da venda.

**Justificativa:** Protege a saúde dos animais e a confiança dos clientes na loja.

**RP10.** A empresa não trabalha com banho e tosa, atendimento veterinário ou venda de animais.

**Justificativa:** Delimita o escopo da empresa: serviços e venda de animais exigiriam processos, cadastros e regras próprios.

## 10. Fluxogramas

Os fluxogramas representam os 12 processos de negócio da seção 5, na mesma numeração. Legenda: oval = início e fim · retângulo = atividade · losango = decisão · retângulo tracejado = ligação com outro processo.

**Integração entre os processos:** a venda na loja virtual (2) segue para a entrega (3) ou para a retirada (4); toda venda baixa o estoque (5); o estoque mínimo inicia a reposição (6), que gera as contas a pagar e aguarda o recebimento (7); pagamentos (8) e contas a pagar alimentam o controle financeiro (9).

### 10.1 Venda na loja física

![Fluxograma — Venda na loja física](fluxogramas/01_venda_loja_fisica.png)

### 10.2 Venda na loja virtual

![Fluxograma — Venda na loja virtual](fluxogramas/02_venda_loja_virtual.png)

### 10.3 Entrega do pedido

![Fluxograma — Entrega do pedido](fluxogramas/03_entrega_pedido.png)

### 10.4 Retirada do pedido na loja

![Fluxograma — Retirada do pedido na loja](fluxogramas/04_retirada_loja.png)

### 10.5 Controle de estoque

![Fluxograma — Controle de estoque](fluxogramas/05_controle_estoque.png)

### 10.6 Reposição de mercadorias

![Fluxograma — Reposição de mercadorias](fluxogramas/06_reposicao.png)

### 10.7 Recebimento de mercadorias

![Fluxograma — Recebimento de mercadorias](fluxogramas/07_recebimento.png)

### 10.8 Pagamento da venda

![Fluxograma — Pagamento da venda](fluxogramas/08_pagamento.png)

### 10.9 Controle financeiro

![Fluxograma — Controle financeiro](fluxogramas/09_controle_financeiro.png)

### 10.10 Cadastro de produtos

![Fluxograma — Cadastro de produtos](fluxogramas/10_cadastro_produtos.png)

### 10.11 Cadastro de clientes

![Fluxograma — Cadastro de clientes](fluxogramas/11_cadastro_clientes.png)

### 10.12 Cancelamento de pedido

![Fluxograma — Cancelamento de pedido](fluxogramas/12_cancelamento.png)

## 11. Entidades

### Entidades relacionadas aos clientes

**Cliente** (*Para cadastrar e identificar as pessoas que compram na loja física ou na loja virtual. Toda venda é vinculada a um cliente (RP02)*)

- ID do cliente;
- Nome;
- CPF;
- Telefone;
- E-mail;

### Entidades relacionadas aos produtos

**Produto** (*Para cadastrar os itens vendidos pela loja e seus preços*)

- ID do produto;
- Nome;
- Descrição;
- Marca;
- Código de barras;
- Preço;
- Estoque mínimo;
- Controla validade (sim ou não);
- Categoria;

**Categoria** (*Para organizar os produtos por tipo, sem repetir as informações da categoria em cada produto (RN04). Ex.: ração, petiscos, higiene, acessórios, brinquedos*)

- ID da categoria;
- Nome;
- Descrição;

**Estoque** (*Para saber quanto de cada produto está armazenado, por lote, no estoque único das duas lojas (RP01, RN11)*)

- ID do estoque;
- Produto;
- Lote;
- Quantidade disponível;
- Data de validade, quando aplicável;
- Data de entrada;

### Entidades relacionadas aos fornecedores e compras

**Fornecedor** (*Para a Petly Club saber de qual empresa compra seus produtos*)

- ID do fornecedor;
- Razão social;
- CNPJ;
- Telefone;
- E-mail;

**Compra** (*Para registrar as compras de reposição feitas a um fornecedor (RN10)*)

- ID da compra;
- Fornecedor;
- Data da compra;
- Status;
- Valor total (derivado);

**Item da compra** (*Para registrar quais produtos vieram em cada compra, com quantidade e custo. Resolve o N:N entre Compra e Produto*)

- Compra;
- Produto;
- Quantidade;
- Custo unitário;

**Conta a pagar** (*Para registrar as parcelas que a empresa deve aos fornecedores por cada compra (RN12)*)

- ID da conta;
- Compra;
- Número da parcela;
- Valor;
- Data de vencimento;
- Data de pagamento;
- Status;

### Entidades relacionadas aos funcionários

**Funcionário** (*Para identificar quem trabalha na Petly Club, quem registra as vendas da loja física (RN14) e o acesso de cada um ao sistema (RP08)*)

- ID do funcionário;
- Nome;
- CPF;
- Cargo;
- Login;
- Senha;

### Entidades relacionadas às vendas

**Pedido** (*Para registrar cada venda, feita na loja física ou na loja virtual (RN05)*)

- ID do pedido;
- Cliente;
- Funcionário (vendas da loja física);
- Data e hora;
- Canal de venda;
- Tipo de recebimento (balcão, retirada ou entrega);
- Status;
- Desconto;
- Valor total (derivado);

**Item do pedido** (*Para identificar quais produtos foram vendidos em cada pedido, com quantidade e preço praticado. Resolve o N:N entre Pedido e Produto (RN03, RN13)*)

- Pedido;
- Produto;
- Quantidade;
- Preço unitário;
- Subtotal (derivado);

**Pagamento** (*Para registrar como cada pedido foi pago; um pedido pode ter mais de uma forma de pagamento (RN15)*)

- ID do pagamento;
- Pedido;
- Forma de pagamento;
- Valor;
- Data;
- Status;

### Entidades relacionadas às entregas

**Entrega** (*Para controlar os pedidos da loja virtual enviados para a casa do cliente (RN17)*)

- ID da entrega;
- Pedido;
- Endereço de entrega (logradouro, número, complemento, bairro, cidade, UF, CEP);
- Data prevista;
- Data da entrega;
- Status;

### Itens analisados que não viraram entidades

**Pet, Cadastro do pet, Serviço, Agendamento, Atendimento, Tabela de preços, Veterinário, Consulta, Prontuário, Vacinação e Prescrição:** A empresa não oferece banho e tosa, atendimento veterinário nem venda de animais (RP10). O sistema contempla apenas a comercialização de produtos.

**Endereço:** Só é necessário quando o pedido é entregue; foi registrado como atributo composto de Entrega.

**Forma de pagamento:** É um valor fixo (dinheiro, Pix, cartão de débito ou crédito); foi registrada como atributo de Pagamento.

**Cargo e Perfil de acesso:** O cargo define o acesso ao sistema (RP08); foi registrado como atributo de Funcionário.

**Usuário e Permissão:** O acesso é feito pelo próprio funcionário, com login e senha registrados em Funcionário.

**Histórico do cliente:** É obtido pela consulta aos pedidos do cliente; não precisa ser armazenado separadamente.

**Movimentação de estoque:** As entradas vêm das compras e as saídas vêm dos pedidos; a quantidade de cada lote fica em Estoque.

**Produto do fornecedor:** O vínculo entre fornecedor e produto já fica registrado por meio de Compra e Item da compra.

**Nota fiscal:** A compra de reposição já registra fornecedor, data, produtos e valores.

**Conta a receber:** Os valores a receber são os pagamentos pendentes dos pedidos, registrados em Pagamento.

**Entregador, Escala, Comissão e Log do sistema:** Não fazem parte do escopo desta etapa do projeto; não há regras de negócio que exijam essas informações.

## 12. Atributos

| Entidade | Atributos | PK | FK |
|---|---|---|---|
| CLIENTE | id_cliente, nome, cpf, telefone, email | id_cliente | nenhuma |
| FUNCIONÁRIO | id_funcionario, nome, cpf, cargo, login, senha | id_funcionario | nenhuma |
| CATEGORIA | id_categoria, nome, descricao | id_categoria | nenhuma |
| PRODUTO | id_produto, nome, descricao, marca, codigo_barras, preco, estoque_minimo, controla_validade, id_categoria | id_produto | id_categoria → CATEGORIA |
| FORNECEDOR | id_fornecedor, razao_social, cnpj, telefone, email | id_fornecedor | nenhuma |
| PEDIDO | id_pedido, data_pedido, canal_venda, tipo_recebimento, status, desconto, valor_total (derivado: soma dos subtotais dos itens menos o desconto), id_cliente, id_funcionario | id_pedido | id_cliente → CLIENTE; id_funcionario → FUNCIONÁRIO (opcional nos pedidos da loja virtual) |
| ITEM_PEDIDO | id_pedido, id_produto, quantidade, preco_unitario, subtotal (derivado: quantidade × preco_unitario) | id_pedido + id_produto (composta) | id_pedido → PEDIDO; id_produto → PRODUTO |
| PAGAMENTO | id_pagamento, forma_pagamento, valor, data_pagamento, status, id_pedido | id_pagamento | id_pedido → PEDIDO |
| ENTREGA | id_entrega, endereco_entrega (composto: logradouro, numero, complemento, bairro, cidade, uf, cep), data_prevista, data_entrega, status, id_pedido | id_entrega | id_pedido → PEDIDO (não se repete) |
| ESTOQUE | id_estoque, lote, data_entrada, data_validade, quantidade, id_produto | id_estoque | id_produto → PRODUTO |
| COMPRA | id_compra, data_compra, status, valor_total (derivado: soma de quantidade × custo_unitario dos itens), id_fornecedor | id_compra | id_fornecedor → FORNECEDOR |
| ITEM_COMPRA | id_compra, id_produto, quantidade, custo_unitario | id_compra + id_produto (composta) | id_compra → COMPRA; id_produto → PRODUTO |
| CONTA_PAGAR | id_conta_pagar, numero_parcela, valor, data_vencimento, data_pagamento, status, id_compra | id_conta_pagar | id_compra → COMPRA |

## 13. Relacionamentos

| Relacionamento | Cardinalidade | Implementação |
|---|---|---|
| CLIENTE — REALIZA — PEDIDO | 1:N | id_cliente migra para PEDIDO como FK. |
| FUNCIONÁRIO — REGISTRA — PEDIDO | 1:N | id_funcionario migra para PEDIDO como FK (opcional nos pedidos da loja virtual). |
| PEDIDO — CONTÉM — PRODUTO | N:N | Resolvido pela associativa ITEM_PEDIDO (quantidade, preco_unitario). |
| PEDIDO — POSSUI — PAGAMENTO | 1:N | id_pedido migra para PAGAMENTO como FK. |
| PEDIDO — GERA — ENTREGA | 1:1 opcional | id_pedido migra para ENTREGA como FK e não se repete (no máximo uma entrega por pedido). |
| CATEGORIA — CLASSIFICA — PRODUTO | 1:N | id_categoria migra para PRODUTO como FK. |
| PRODUTO — POSSUI — ESTOQUE | 1:N | id_produto migra para ESTOQUE como FK; cada lote é um registro. |
| FORNECEDOR — ATENDE — COMPRA | 1:N | id_fornecedor migra para COMPRA como FK. |
| COMPRA — REPÕE — PRODUTO | N:N | Resolvido pela associativa ITEM_COMPRA (quantidade, custo_unitario). |
| FORNECEDOR — FORNECE — PRODUTO | N:N | Resolvido por COMPRA e ITEM_COMPRA, sem ligação direta entre FORNECEDOR e PRODUTO. |
| COMPRA — GERA — CONTA_PAGAR | 1:N | id_compra migra para CONTA_PAGAR como FK; cada parcela é um registro. |

### 13.1 Verificação de atributos nos relacionamentos

**Relacionamento:** CLIENTE — REALIZA — PEDIDO

**Tipo:** 1:N

**Regra:** RN01, RN02, RP02

**Possui atributos próprios?** Não

**Resultado:** FK id_cliente em PEDIDO

**Relacionamento:** FUNCIONÁRIO — REGISTRA — PEDIDO

**Tipo:** 1:N

**Regra:** RN14

**Possui atributos próprios?** Não

**Resultado:** FK id_funcionario em PEDIDO

**Relacionamento:** PEDIDO — POSSUI — PAGAMENTO

**Tipo:** 1:N

**Regra:** RN15

**Possui atributos próprios?** Não

**Resultado:** FK id_pedido em PAGAMENTO

**Relacionamento:** PEDIDO — GERA — ENTREGA

**Tipo:** 1:1 opcional

**Regra:** RN17

**Possui atributos próprios?** Não

**Resultado:** FK id_pedido em ENTREGA

**Relacionamento:** CATEGORIA — CLASSIFICA — PRODUTO

**Tipo:** 1:N

**Regra:** RN04

**Possui atributos próprios?** Não

**Resultado:** FK id_categoria em PRODUTO

**Relacionamento:** PRODUTO — POSSUI — ESTOQUE (por lote)

**Tipo:** 1:N

**Regra:** RN11

**Possui atributos próprios?** Não

**Resultado:** FK id_produto em ESTOQUE

**Relacionamento:** FORNECEDOR — ATENDE — COMPRA

**Tipo:** 1:N

**Regra:** RN10

**Possui atributos próprios?** Não

**Resultado:** FK id_fornecedor em COMPRA

**Relacionamento:** COMPRA — GERA — CONTA_PAGAR

**Tipo:** 1:N

**Regra:** RN12

**Possui atributos próprios?** Não

**Resultado:** FK id_compra em CONTA_PAGAR

**Relacionamento:** PEDIDO — CONTÉM — PRODUTO

**Tipo:** N:N

**Regra:** RN03, RN13

**Possui atributos próprios?** Sim

**Resultado:** ITEM_PEDIDO

**Relacionamento:** COMPRA — REPÕE — PRODUTO

**Tipo:** N:N

**Regra:** RN10

**Possui atributos próprios?** Sim

**Resultado:** ITEM_COMPRA

**Relacionamento:** FORNECEDOR — FORNECE — PRODUTO

**Tipo:** N:N

**Regra:** RN09

**Possui atributos próprios?** Não (resolvido por Compra)

**Resultado:** Sem linha direta no DER

#### Relacionamentos sem atributos próprios

**Cliente — Pedido:** data_pedido, canal_venda, tipo_recebimento e status descrevem o pedido, não a ligação com o cliente.

**Funcionário — Pedido:** o funcionário só aparece como responsável pelo registro da venda; o momento do registro coincide com a data do pedido.

**Pedido — Pagamento:** valor, forma de pagamento, data e status descrevem o pagamento. A forma de pagamento é atributo de PAGAMENTO, não entidade própria. Como um pedido pode ter vários pagamentos (RN15), a relação é 1:N e PAGAMENTO é uma entidade normal, não associativa.

**Pedido — Entrega:** o endereço de entrega (logradouro, número, complemento, bairro, cidade, UF e CEP) é atributo composto de ENTREGA. Não existe entidade Endereço. A relação é 1:1 opcional porque vendas no balcão e pedidos da loja virtual retirados na loja não geram entrega (RN17).

**Categoria — Produto:** o nome e a descrição da categoria pertencem à categoria, e o produto guarda só o id_categoria.

**Produto — Estoque:** o estoque é controlado por lote, então um produto tem vários registros de estoque. lote, data_validade, quantidade e data_entrada descrevem o registro de estoque, não o par Produto+Estoque.

**Fornecedor — Compra:** data, valor_total e status descrevem a compra.

**Compra — Conta_Pagar:** número da parcela, valor, vencimento e status descrevem cada conta a pagar, não a ligação com a compra (RN12).

#### Relacionamentos com atributos

#### PEDIDO — CONTÉM — PRODUTO → ITEM_PEDIDO (RN03)

**Por que é N:N:** um pedido contém vários produtos, e um produto aparece em vários pedidos.

**Atributos do relacionamento:** quantidade e preco_unitario.

**Por que pertencem à relação:** a quantidade só existe quando se sabe qual produto foi vendido em qual pedido. Em PEDIDO seria preciso repetir campos (produto1, produto2…), e em PRODUTO não daria para saber a quantidade de cada venda.

**Por que preco_unitario não fica só em Produto:** o preço do produto pode mudar, mas o valor cobrado naquela venda precisa ficar registrado (RN13).

**Subtotal:** não é armazenado, por ser derivado (quantidade × preco_unitario).

**Identificação:** PK composta id_pedido + id_produto.

#### COMPRA — REPÕE — PRODUTO → ITEM_COMPRA (RN10)

**Por que é N:N:** uma compra de reposição traz vários produtos, e um produto é comprado em várias compras.

**Atributos do relacionamento:** quantidade e custo_unitario.

**Por que pertencem à relação:** o custo varia a cada compra, então não pode ficar só em PRODUTO. Isso preserva o histórico de custos e permite calcular margem.

**Lote e validade:** ficam em ESTOQUE, no momento da entrada (RN11), e não em ITEM_COMPRA.

**Identificação:** PK composta id_compra + id_produto.

#### FORNECEDOR — FORNECE — PRODUTO (RN09): N:N resolvido por Compra

Um produto pode ter vários fornecedores, e um fornecedor fornece vários produtos, então a relação é N:N. Ela não vira entidade associativa própria porque já é resolvida por COMPRA e ITEM_COMPRA. No DER o caminho é Fornecedor → Compra → Item_Compra ← Produto, sem linha direta entre Fornecedor e Produto.

Por isso não existe Produto_Fornecedor. O preço que cada fornecedor cobra fica registrado no custo_unitario de ITEM_COMPRA. Atributos como prazo_entrega e codigo_produto_fornecedor só seriam necessários se o grupo decidisse guardar um catálogo de fornecedores, o que não está no escopo.

## 14. Cardinalidades

Nós adotamos a notação (mínimo e máximo) ao lado de cada entidade, indicando em quantas ocorrências de um relacionamento uma ocorrência daquela entidade pode participar.

| Relacionamento | Cardinalidade | Justificativa (regra de negócio) |
|---|---|---|
| Cliente – Pedido | 1:N. Cliente (0,N), Pedido (1,1) | Um cliente pode fazer vários pedidos ou nenhum, caso esteja apenas cadastrado (RN01, RN02). Todo pedido pertence a exatamente um cliente, pois o CPF identifica o tutor, inclusive na loja física (RP02). |
| Funcionário – Pedido | 1:N. Funcionário (0,N), Pedido (0,1) | Um funcionário registra vários pedidos (RN14). Na loja virtual a compra é feita pelo próprio cliente, sem atendente, por isso o mínimo do lado do pedido é 0. |
| Pedido – Pagamento | 1:N. Pedido (1,N), Pagamento (1,1) | Um pedido pode ser pago de mais de uma forma, então pode ter vários pagamentos, e todo pedido tem ao menos um pagamento associado (RN15). Cada pagamento refere-se a um único pedido. |
| Pedido – Entrega | 1:1 opcional. Pedido (0,1), Entrega (1,1) | Um pedido tem no máximo uma entrega (RN17). Vendas no balcão e pedidos da loja virtual retirados na loja não têm entrega, por isso o mínimo do lado do pedido é 0. Toda entrega pertence a exatamente um pedido. |
| Categoria – Produto | 1:N. Categoria (0,N), Produto (1,1) | Uma categoria pode agrupar vários produtos ou ainda não ter nenhum. Cada produto pertence a uma única categoria (RN04). |
| Pedido – Item_Pedido | 1:N. Pedido (1,N), Item_Pedido (1,1) | Um pedido só existe com pelo menos um item (RN03). Cada item pertence a um único pedido. |
| Produto – Item_Pedido | 1:N. Produto (0,N), Item_Pedido (1,1) | Um produto pode aparecer em vários itens de pedido, ou em nenhum se nunca foi vendido (RN03). Cada item refere-se a um único produto. |
| Produto – Estoque | 1:N. Produto (0,N), Estoque (1,1) | O estoque é único para as duas lojas (RP01) e controla lotes com validade (RN11). Um produto pode ter vários lotes, ou nenhum se ainda não foi recebido. Cada lote pertence a um único produto. |
| Fornecedor – Compra | 1:N. Fornecedor (0,N), Compra (1,1) | Um fornecedor pode atender várias compras, ou nenhuma se acabou de ser cadastrado. Cada compra é feita a um único fornecedor (RN10). |
| Compra – Item_Compra | 1:N. Compra (1,N), Item_Compra (1,1) | Toda compra tem ao menos um item (RN10). Cada item pertence a uma única compra. |
| Produto – Item_Compra | 1:N. Produto (0,N), Item_Compra (1,1) | Um produto pode ser reposto em várias compras, ou em nenhuma se ainda não foi comprado. Cada item de compra refere-se a um único produto (RN10). |
| Compra – Conta_Pagar | 1:N. Compra (1,N), Conta_Pagar (1,1) | Toda compra gera pelo menos uma conta a pagar, podendo ser dividida em parcelas (RN12). Cada conta pertence a uma única compra. |

Nos relacionamentos 1:N, a chave primária do lado 1 migra como chave estrangeira (FK) para o lado N. Em Funcionário–Pedido, a FK id_funcionario em PEDIDO é opcional (aceita nulo), por causa dos pedidos da loja virtual. No 1:1 Pedido–Entrega, a FK id_pedido fica em ENTREGA, que é o lado de participação obrigatória, com restrição de unicidade (UNIQUE), garantindo no máximo uma entrega por pedido.

Em Pedido–Pagamento, a cardinalidade mínima do lado do pedido é 1: todo pedido possui ao menos um pagamento associado desde o seu registro (RN15). Na loja virtual, o pagamento pode ficar com status pendente até a confirmação, mas o registro do pagamento existe. Assim, a situação “aguardando pagamento” é controlada pelo status do próprio pagamento, e não pela ausência dele.

O endereço de entrega foi registrado como atributo composto da entidade Entrega (logradouro, número, complemento, bairro, cidade, UF e CEP), pois só é necessário quando o pedido é entregue na casa do cliente. Por isso, não foi criada uma entidade Endereço.

### 14.1 Relacionamentos N:N

Analisamos cada par de entidades verificando se ocorre “muitos” nos dois sentidos. Foram encontrados três relacionamentos N:N, apresentados com a cardinalidade mínima e máxima de cada lado:

| Relacionamento N:N | Cardinalidade | Regra que sustenta |
|---|---|---|
| Pedido – Produto | Pedido (1,N) — contém — Produto (0,N) | Um pedido contém no mínimo um produto e pode conter vários. Um produto pode não estar em nenhum pedido (nunca vendido) ou estar em vários (RN03). |
| Compra – Produto | Compra (1,N) — repõe — Produto (0,N) | Uma compra traz no mínimo um produto e pode trazer vários. Um produto pode nunca ter sido comprado ou ter sido reposto em várias compras (RN10). |
| Fornecedor – Produto | Fornecedor (0,N) — fornece — Produto (0,N) | Um fornecedor recém-cadastrado pode não ter fornecido nada, e pode fornecer vários produtos. Um produto pode não ter fornecedor registrado e pode ser fornecido por vários (RN09). |

**Pedido × Produto.** Um pedido contém vários produtos, e um produto pode estar em vários pedidos. O N:N foi resolvido pela entidade associativa **Item_Pedido**, com chave primária composta por id_pedido e id_produto (ambas também FKs). Os atributos do relacionamento são quantidade e preco_unitario, este último guardando o preço praticado na data da venda, para que uma alteração posterior no preço do produto não modifique pedidos antigos (RN13). O subtotal não é armazenado, pois é derivado (quantidade × preco_unitario). Após a resolução, o relacionamento passa a ser Pedido (1,N) – Item_Pedido (1,1) e Produto (0,N) – Item_Pedido (1,1), como mostra a seção 13.

**Compra × Produto.** Uma compra de reposição traz vários produtos, e um produto é reposto em várias compras. O N:N foi resolvido pela entidade associativa **Item_Compra**, com os atributos quantidade e custo_unitario. A chave primária é composta por id_compra e id_produto (ambas também FKs), pois cada produto aparece uma única vez em cada compra, com a quantidade total adquirida. Lote e validade não pertencem ao Item_Compra: ficam registrados na entidade Estoque, que controla os lotes de cada produto (RN11). Por isso não é necessário incluir o lote na chave, e a PK composta está definida.

**Fornecedor × Produto.** Conceitualmente, um fornecedor pode fornecer vários produtos e um produto pode ser fornecido por vários fornecedores (RN09). Em vez de criar uma associativa direta entre as duas entidades, o grupo decidiu representar o vínculo pelo processo de Compra, que registra a situação definitiva: a empresa comprou determinados produtos de determinado fornecedor. O caminho fica:

```
FORNECEDOR ──1:N──► COMPRA ──1:N──► ITEM_COMPRA ◄──N:1── PRODUTO
```

Exemplo: o Fornecedor X vende Ração A, Ração B e Petisco C. Na Compra nº 125, feita a esse fornecedor, os itens registrados são 50 × Ração A, 30 × Ração B e 20 × Petisco C. Assim, o vínculo entre produto e fornecedor fica documentado com data, quantidade e custo unitário, informações que uma tabela de ligação simples não guardaria. Uma tabela Produto_Fornecedor duplicaria essa informação e só se justificaria se a loja passasse a manter um cadastro de fornecedores habilitados por produto, com preço de tabela e prazo de entrega, o que fica como possível evolução do modelo.

Os demais relacionamentos (Cliente–Pedido, Funcionário–Pedido, Pedido–Pagamento, Pedido–Entrega, Categoria–Produto, Fornecedor–Compra, Produto–Estoque e Compra–Conta_Pagar) não são N:N e não exigem entidade associativa. Pedido–Pagamento e Compra–Conta_Pagar são 1:N, e Pedido–Entrega é 1:1 opcional.

## 15. Dicionário de dados conceitual

| Entidade | Descrição | Principais atributos |
|---|---|---|
| Cliente | Pessoa física (tutor) que realiza compras na loja física ou virtual. | id_cliente, nome, CPF, telefone, e-mail |
| Funcionário | Colaborador que registra vendas e movimentações de mercadorias. | id_funcionario, nome, CPF, cargo, login, senha |
| Categoria | Classificação dos produtos vendidos. | id_categoria, nome, descrição |
| Produto | Produto comercializado pela empresa. | id_produto, nome, descrição, marca, código de barras, preço, estoque_minimo, controla_validade |
| Estoque | Lotes de cada produto no estoque único das duas lojas. | id_estoque, lote, quantidade, data_validade, data_entrada |
| Pedido | Venda realizada na loja física ou na loja virtual. | id_pedido, data, canal_venda, tipo_recebimento, status, desconto, valor_total |
| Item_Pedido | Produtos que fazem parte de um pedido. | id_pedido, id_produto, quantidade, preço_unitario, subtotal |
| Pagamento | Registro do pagamento relacionado a um pedido. | id_pagamento, forma, valor, data, status |
| Entrega | Informações da entrega dos pedidos da loja virtual. | id_entrega, endereço_entrega, data_prevista, data_entrega, status |
| Fornecedor | Empresa que abastece a loja com mercadorias. | id_fornecedor, razão social, CNPJ, telefone, e-mail |
| Compra | Compra de reposição feita a um fornecedor. | id_compra, data, status, valor_total |
| Item_Compra | Produtos que fazem parte de uma compra. | id_compra, id_produto, quantidade, custo_unitario |
| Conta_Pagar | Parcela a pagar gerada por uma compra. | id_conta_pagar, número da parcela, valor, vencimento, status |

Observação: o dicionário é preliminar, portanto os atributos podem ser ajustados durante as etapas de modelo lógico, normalização e validação. Atributos marcados como **derivados** são calculados a partir de outros dados e não precisam ser armazenados.

### Cliente

Pessoa física (tutor de animal) que compra na loja física ou na loja virtual.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_cliente | Identificador do cliente | Identificação única |
| nome | Nome completo do cliente | Obrigatório |
| cpf | Documento do cliente | Obrigatório; não pode se repetir (RN18) |
| telefone | Telefone de contato | Pode ser informado posteriormente |
| email | E-mail de contato | Obrigatório para compras na loja virtual |

### Funcionário

Colaborador que registra vendas e movimentações de mercadorias.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_funcionario | Identificador do funcionário | Identificação única |
| nome | Nome completo | Obrigatório |
| cpf | Documento do funcionário | Obrigatório; não pode se repetir |
| cargo | Função exercida | Ex.: atendente, operador de caixa, estoquista, gerente; define o acesso ao sistema (RP08) |
| login | Nome de acesso ao sistema | Obrigatório; não pode se repetir |
| senha | Senha de acesso ao sistema | Obrigatória; armazenada com algoritmo de hash (RNF02) |

### Categoria

Classificação dos produtos vendidos (alimentação, higiene, acessórios etc.).

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_categoria | Identificador da categoria | Identificação única |
| nome | Nome da categoria | Obrigatório; não pode se repetir |
| descricao | Descrição da categoria | Opcional |

### Produto

Produto comercializado pela empresa.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_produto | Identificador do produto | Identificação única |
| nome | Nome comercial do produto | Obrigatório |
| descricao | Detalhes do produto (peso, sabor, espécie indicada) | Opcional |
| marca | Marca ou fabricante | Obrigatório |
| codigo_barras | Código de barras do produto | Não pode se repetir; usado para localizar o produto no caixa (RNF05) |
| preco | Preço atual de venda | Obrigatório; maior que zero; só a gerência pode alterar (RP04) |
| estoque_minimo | Quantidade mínima desejada em estoque | Ao ser atingida, deve ser feita a reposição (RP03) |
| controla_validade | Indica se o produto exige controle de lote e validade | Sim ou não; quando sim, lote e validade são obrigatórios no estoque (RN11) |
| id_categoria | Categoria à qual o produto pertence | Obrigatório; todo produto pertence a uma categoria (RN04) |

### Estoque

Quantidade disponível de cada produto, por lote, no estoque único compartilhado pela loja física e pela loja virtual (RP01).

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_estoque | Identificador do registro de estoque | Identificação única |
| id_produto | Produto armazenado | Obrigatório |
| lote | Lote do produto | Obrigatório para produtos com controle de validade (RN11) |
| quantidade | Quantidade disponível | Não pode ser negativa; diminui a cada venda e aumenta a cada recebimento (RN06, RN08) |
| data_validade | Data de validade do lote | Obrigatória para produtos com controle de validade; lotes vencidos saem da venda (RP09) |
| data_entrada | Data de entrada do lote no estoque | Obrigatória |

### Pedido

Venda realizada na loja física ou na loja virtual.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_pedido | Identificador do pedido | Identificação única; não muda ao longo do tempo |
| id_cliente | Cliente que realizou o pedido | Obrigatório; cada pedido pertence a um único cliente (RN01, RP02) |
| id_funcionario | Funcionário que registrou a venda | Obrigatório nas vendas da loja física (RN14) |
| data_pedido | Data e hora do pedido | Obrigatória |
| canal_venda | Canal em que o pedido foi feito | Valores: loja física ou loja virtual (RN05) |
| tipo_recebimento | Como o cliente recebe os produtos | Valores: balcão, retirada na loja ou entrega (RN17) |
| status | Situação do pedido | Ex.: pendente, pago, em preparação, enviado, entregue, retirado, cancelado (RN16) |
| desconto | Valor de desconto concedido no pedido | Pode ser zero; acima do limite definido, exige autorização da gerência (RP05) |
| valor_total | Valor final do pedido | **Derivado:** soma de quantidade × preco_unitario dos itens, menos o desconto |

### Item_Pedido (entidade associativa entre Pedido e Produto)

Cada produto vendido dentro de um pedido.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_pedido | Pedido ao qual o item pertence | Compõe a identificação do item |
| id_produto | Produto vendido | Compõe a identificação do item; o mesmo produto não se repete no pedido |
| quantidade | Quantidade vendida do produto | Obrigatória; maior que zero; não pode superar o estoque disponível (RN07) |
| preco_unitario | Preço praticado no momento da venda | Obrigatório; preserva o valor original mesmo que o preço do produto mude (RN13) |
| subtotal | Valor do item | **Derivado:** quantidade × preco_unitario |

### Pagamento

Registro do pagamento de um pedido.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_pagamento | Identificador do pagamento | Identificação única |
| id_pedido | Pedido pago | Obrigatório; todo pedido tem ao menos um pagamento (RN15) |
| forma_pagamento | Forma utilizada | Ex.: dinheiro, cartão de débito, cartão de crédito, Pix |
| valor | Valor pago | Obrigatório; maior que zero |
| data_pagamento | Data do pagamento | Obrigatória quando o pagamento for confirmado |
| status | Situação do pagamento | Ex.: pendente, aprovado, recusado, estornado |

### Entrega

Informações da entrega de pedidos da loja virtual enviados para a casa do cliente.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_entrega | Identificador da entrega | Identificação única |
| id_pedido | Pedido entregue | Não pode se repetir; só existe para pedidos com tipo_recebimento = entrega (RN17) |
| endereco_entrega | Endereço de entrega | **Composto:** logradouro, número, complemento, bairro, cidade, UF, CEP |
| data_prevista | Data prevista de entrega | Obrigatória |
| data_entrega | Data em que a entrega foi realizada | Preenchida ao concluir a entrega |
| status | Situação da entrega | Ex.: em separação, enviado, entregue |

### Fornecedor

Empresa que abastece a loja com mercadorias.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_fornecedor | Identificador do fornecedor | Identificação única |
| razao_social | Nome empresarial do fornecedor | Obrigatório |
| cnpj | Documento do fornecedor | Obrigatório; não pode se repetir |
| telefone | Telefone de contato | Obrigatório |
| email | E-mail de contato | Opcional |

### Compra

Compra de reposição feita a um fornecedor.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_compra | Identificador da compra | Identificação única |
| id_fornecedor | Fornecedor da compra | Obrigatório; toda compra pertence a um fornecedor (RN10) |
| data_compra | Data da compra | Obrigatória |
| status | Situação da compra | Ex.: solicitada, recebida, cancelada |
| valor_total | Valor total da compra | **Derivado:** soma de quantidade × custo_unitario dos itens |

### Item_Compra (entidade associativa entre Compra e Produto)

Cada produto incluído em uma compra.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_compra | Compra à qual o item pertence | Compõe a identificação do item |
| id_produto | Produto comprado | Compõe a identificação do item |
| quantidade | Quantidade comprada | Obrigatória; maior que zero |
| custo_unitario | Custo pago ao fornecedor por unidade | Obrigatório; preserva o custo daquela compra |

### Conta_Pagar

Parcela a pagar gerada por uma compra de reposição.

| Atributo | Descrição | Regra/Observação |
|---|---|---|
| id_conta_pagar | Identificador da conta | Identificação única |
| id_compra | Compra que gerou a conta | Obrigatório; toda compra gera ao menos uma conta (RN12) |
| numero_parcela | Número da parcela | Ex.: 1 de 3 |
| valor | Valor da parcela | Obrigatório; maior que zero |
| data_vencimento | Data limite para pagamento | Obrigatória |
| data_pagamento | Data em que a conta foi paga | Preenchida quando a conta é paga |
| status | Situação da conta | Ex.: pendente, paga, cancelada |

## 16. DER

Diagrama em notação de Peter Chen. Retângulo = entidade · losango = relacionamento · retângulo com losango = entidade associativa. A cardinalidade (mínimo, máximo) junto a cada entidade indica em quantas ocorrências do relacionamento uma ocorrência dessa entidade participa, na mesma notação do manual. Ex.: CLIENTE (0,N) — realiza — (1,1) PEDIDO: um cliente realiza de 0 a N pedidos, e cada pedido é realizado por exatamente um cliente. Abaixo de cada relacionamento aparece a regra de negócio que o sustenta.

### Visão geral

![DER — visão geral](der/DER_visao_geral.png)

### Com atributos

![DER — com atributos](der/DER_com_atributos.png)

Legenda dos atributos: ● identificador (sublinhado) · ○ atributo simples · (composto) atributo formado por partes · (derivado) calculado, não armazenado. Fornecedor × Produto (N:N, RN09) é representado por meio de COMPRA e ITEM_COMPRA, sem ligação direta entre as duas entidades. Versão em PDF: [`der/DER.pdf`](der/DER.pdf).

## 17. Justificativas técnicas

**Separação entre Cliente e Pedido:** Um cliente pode realizar vários pedidos ao longo do tempo (RN01). Por isso, os dados do cliente ficam em uma entidade própria e não são repetidos em cada compra, evitando duplicidade e risco de inconsistência.

**Cardinalidade Cliente–Pedido: Cliente (0,N) — Pedido (1,1):** Um cliente cadastrado pode ainda não ter realizado nenhuma compra ou ter realizado várias (RN02), e cada pedido pertence a um único cliente, tanto na loja física quanto na loja virtual. Para isso, inspirada no modelo de clube de compras do Sam's Club, a empresa só vende para clientes cadastrados, inclusive no caixa da loja física (RP02), o que permite manter o histórico de compras de todos os clientes.

**Criação da entidade Item_Pedido:** Um pedido pode conter vários produtos e um produto pode aparecer em vários pedidos (RN03), caracterizando um relacionamento N:N. A entidade associativa Item_Pedido resolve essa relação e armazena as informações que pertencem ao relacionamento: a quantidade e o preço praticado. Sem ela, seria necessário repetir o pedido para cada produto ou criar campos como produto1, produto2 e produto3, e a quantidade não teria onde ser armazenada.

**Preço unitário no Item_Pedido:** O preço dos produtos muda ao longo do tempo. Guardar o preço praticado no item preserva o valor original de cada venda (RN13), enquanto o atributo preco de Produto representa apenas o preço atual.

**Atributos derivados:** Subtotal e valor total são calculados a partir da quantidade, do preço dos itens e do desconto. Por isso, foram identificados como atributos derivados: armazená-los criaria o risco de o total gravado divergir da soma real dos itens.

**Separação entre Produto e Categoria:** Cada produto pertence a uma categoria, e uma categoria agrupa vários produtos (RN04). A separação evita repetir as informações da categoria em cada produto e permite relatórios por categoria.

**Estoque como entidade própria:** A empresa possui um único estoque, compartilhado pela loja física e pela loja virtual (RP01), e precisa controlar a validade dos produtos. Como um mesmo produto pode ter lotes com validades diferentes, a quantidade e a validade foram registradas por lote na entidade Estoque (RN11). Toda venda, em qualquer canal, reduz o estoque (RN06), e não é permitido vender acima do disponível (RN07).

**Canal de venda no Pedido:** O modelo mantém uma única estrutura de clientes, produtos e pedidos para os dois canais, evitando os cadastros duplicados que a empresa tem hoje. O atributo canal_venda diferencia a origem de cada pedido (RN05) e permite comparar o desempenho da loja física e da loja virtual.

**Separação entre Pedido e Pagamento:** O pedido representa a venda; o pagamento representa a forma e a situação financeira dessa venda. A separação permite registrar pagamentos pendentes, recusados ou estornados e mais de uma forma de pagamento no mesmo pedido (RN15).

**Entrega opcional: Pedido (0,1) — Entrega (1,1):** Somente pedidos da loja virtual com entrega em casa geram uma entrega; vendas no balcão e retiradas na loja não geram (RN17). Por isso, a entrega é opcional para o pedido e possui atributos próprios, como endereço, datas e status.

**Endereço registrado na Entrega:** O endereço só é necessário quando o pedido é entregue na casa do cliente. Por isso, ele foi registrado na entidade Entrega, como atributo composto, permitindo que cada entrega tenha seu próprio endereço sem obrigar clientes da loja física a informá-lo.

**Funcionário no Pedido: Funcionário (0,N) — Pedido (0,1):** O funcionário registra as vendas da loja física, e um mesmo funcionário registra vários pedidos (RN14). Pedidos da loja virtual são feitos pelo próprio cliente e não precisam de um funcionário responsável.

**Compra e Item_Compra:** Um produto pode ser comprado de vários fornecedores, e um fornecedor pode fornecer vários produtos (RN09). As entidades Compra e Item_Compra registram essa relação e o custo pago em cada compra (RN10), integrando a reposição ao controle de estoque (RN08).

**Conta_Pagar como entidade própria:** Uma compra de reposição pode ser paga em parcelas, cada uma com valor, vencimento e situação próprios (RN12). Por isso, as contas a pagar foram separadas da compra, assim como os pagamentos foram separados do pedido, integrando o processo de compras ao financeiro.

**Cliente e Funcionário separados:** Foi considerada a generalização Pessoa, mas as duas entidades têm finalidades e atributos diferentes: o cliente realiza pedidos e precisa de e-mail para a loja virtual; o funcionário registra vendas e possui cargo, login e senha. Os dados em comum se limitam a nome e CPF, e um funcionário que compra na loja é cadastrado também como cliente. A separação mantém o modelo mais simples, e a generalização fica como possível evolução.

**Atributos de controle:** Os atributos estoque_minimo e controla_validade, em Produto, sustentam a reposição no nível mínimo (RP03) e o controle de validade por lote (RN11). O desconto, em Pedido, registra o valor concedido, que acima do limite exige autorização da gerência (RP05). Login e senha, em Funcionário, permitem o acesso ao sistema de acordo com o cargo (RP08). O código de barras, em Produto, permite a leitura e a busca rápida dos produtos no caixa (RNF05).

**Identificação única das entidades:** Cada entidade possui um identificador próprio, como id_cliente, id_produto e id_pedido, que não muda ao longo do tempo e diferencia cada registro, sem depender de dados que podem se repetir, como nome ou data.

**Limitação do escopo:** O modelo contempla somente a comercialização de produtos para animais. Não foram incluídos banho e tosa, serviços veterinários ou venda de animais (RP10), pois pertencem a outro domínio de negócio e exigiriam entidades como agendamento, profissional e animal atendido.

**Loja física e virtual:** O modelo foi pensado para atender vendas realizadas nos dois canais, mantendo a estrutura de produtos, clientes e pedidos independente do canal utilizado e com um único estoque (RP01).

Essas decisões buscam evitar duplicidade de informações, representar corretamente os relacionamentos entre os dados e integrar vendas, estoque, compras e financeiro, mantendo o modelo preparado para as próximas etapas, como modelo lógico, normalização e implementação do banco de dados.

## 18. Conclusão

Esta primeira entrega transformou a situação da Petly Club, um pet shop de pequeno porte inspirado na Cobasi e no Sam's Club, em um modelo conceitual de dados. O ponto de partida foi o problema real da empresa: duas lojas, uma física e uma virtual, que compartilham o mesmo estoque, mas registram vendas, clientes e produtos em sistemas e planilhas que não se comunicam, gerando cadastros duplicados, estoque desatualizado e retrabalho no financeiro.

Seguindo o caminho proposto no manual, a equipe partiu da caracterização da empresa e dos processos de negócio, identificou os problemas e necessidades, levantou os requisitos, as regras de negócio e as políticas organizacionais e só então definiu as entidades, os atributos, os relacionamentos e as cardinalidades. Cada decisão de modelagem foi apoiada em uma regra de negócio numerada, o que permite responder, para cada elemento do DER, de onde veio aquela decisão.

O modelo resultante possui 13 entidades e integra os quatro processos centrais da empresa: vendas nos dois canais, controle de estoque por lote e validade, compras de reposição com fornecedores e controle financeiro. Os relacionamentos N:N entre Pedido e Produto e entre Compra e Produto foram resolvidos pelas entidades associativas Item_Pedido e Item_Compra, que guardam as informações próprias de cada relação, como a quantidade, o preço praticado e o custo de cada compra. A delimitação do escopo, restrito à comercialização de produtos, permitiu tratar esses processos com profundidade.

Esse modelo é a base para as próximas etapas do projeto: o modelo lógico, a normalização, o modelo físico e a implementação do banco de dados, que darão suporte às análises de BI e IA previstas para o ERP.

## Uso de Inteligência Artificial

**Ferramentas:** Claude (Anthropic), ChatGPT (OpenAI) e Gemini (Google)

**Finalidades:**

- Revisão das partes do projeto, verificando se estavam coerentes entre si e de acordo com o modelo pedido pelo professor;
- Apoio na formação e na formatação deste README;
- Verificação do checklist do manual, para conferir se todos os pontos do trabalho foram atendidos;
- Apoio para juntar as partes feitas pelos integrantes em um único documento.

**Como a equipe validou os resultados:** comparamos os resultados de diferentes ferramentas de IA antes de fazer as mudanças no projeto.

---

### Documentos do repositório

Cada etapa também está disponível em PDF na pasta [`docs/`](docs/).
