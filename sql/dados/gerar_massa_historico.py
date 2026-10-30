"""
Gera sql/dados/Massa_Historico_Vendas_ERP_Petly_Club.sql
Histórico de vendas de 01/08/2026 a 19/10/2026 para o ERP Petly Club (PostgreSQL 16).

Roda DEPOIS de Massa_de_Dados_Completa_-_ERP_Petly_Club.sql e não altera nada dela:
- usa faixas de id próprias (pedido >= 1001, lote >= 101, compra >= 201, ...);
- os lotes históricos dos produtos 1, 2, 4, 5 e 6 vencem ANTES dos lotes da massa principal
  e são esgotados até 19/10, então a regra FEFO (RN20) continua valendo nos cenários de 20/10 em diante;
- o antipulgas (produto 3) só vende em outubro, do lote 5: o lote 4 venceu em 30/09 sem vender,
  como no cenário 3 do README;
- os status financeiros seguem a data de referência dos testes, 27/10/2026.

Uso: python gerar_massa_historico.py   (a semente é fixa: o resultado é sempre o mesmo)
"""
import os
import random
from datetime import date, datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

random.seed(20261027)
AQUI = os.path.dirname(os.path.abspath(__file__))
SAIDA = os.path.join(AQUI, 'Massa_Historico_Vendas_ERP_Petly_Club.sql')
REF = date(2026, 10, 27)          # data de referência dos testes
INICIO, FIM = date(2026, 8, 1), date(2026, 10, 19)
GERENTE, CAIXA, ESTOQUISTA, ATENDENTE = 1, 2, 3, 4


def D(v):
    return Decimal(str(v)).quantize(Decimal('0.01'), ROUND_HALF_UP)


def q(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'TRUE' if v else 'FALSE'
    if isinstance(v, (int, Decimal)):
        return str(v)
    if isinstance(v, datetime):
        return "'" + v.strftime('%Y-%m-%d %H:%M:%S') + "'"
    if isinstance(v, date):
        return "'" + v.isoformat() + "'"
    return "'" + str(v).replace("'", "''") + "'"


# ------------------------------------------------------------------ produtos
# id: (nome, marca, preco, categoria, controla_validade, estoque_minimo, fornecedor, custo, peso de venda)
PROD = {
    1: ('Racao Premium Caes Adultos 15kg', 'NutriPet', D('189.90'), 1, True, 5, 1, D('100.00'), 9),
    2: ('Shampoo Neutro 500ml', 'PetClean', D('29.90'), 2, True, 10, 2, D('15.00'), 7),
    3: ('Antipulgas e Carrapatos 10-20kg', 'PharmaVet', D('89.90'), 3, True, 8, 2, D('45.00'), 0),
    4: ('Bolinha de Borracha Interativa', 'PetStyle', D('19.90'), 4, False, 15, 3, D('8.00'), 5),
    5: ('Racao Gatos Castrados 3kg', 'NutriPet', D('74.90'), 1, True, 6, 1, D('40.00'), 7),
    6: ('Petisco Dental Caes 200g', 'NutriPet', D('24.90'), 1, True, 5, 1, D('12.00'), 5),
}
NOVOS = {
    7: ('Areia Higienica Gatos 4kg', 'Areia de silica para caixa sanitaria', 'PetClean', D('32.90'), 2, False, 10, 2, D('16.00'), 7, '7890000000073'),
    8: ('Tapete Higienico 30 unidades', 'Tapete absorvente para caes', 'PetClean', D('59.90'), 2, False, 8, 2, D('30.00'), 5, '7890000000080'),
    9: ('Vermifugo Caes 4 comprimidos', 'Vermifugo de amplo espectro', 'PharmaVet', D('39.90'), 3, True, 6, 2, D('19.00'), 4, '7890000000097'),
    10: ('Coleira Ajustavel Media', 'Coleira de nylon com fivela', 'PetStyle', D('34.90'), 4, False, 5, 3, D('14.00'), 3, '7890000000103'),
    11: ('Arranhador para Gatos', 'Arranhador de sisal com base', 'PetStyle', D('89.90'), 4, False, 3, 3, D('42.00'), 2, '7890000000110'),
    12: ('Sache Gatos Salmao 85g', 'Alimento umido para gatos adultos', 'NutriPet', D('3.99'), 1, True, 40, 1, D('1.80'), 8, '7890000000127'),
    13: ('Racao Filhotes Caes 3kg', 'Racao seca para caes filhotes', 'NutriPet', D('69.90'), 1, True, 6, 1, D('36.00'), 5, '7890000000134'),
    14: ('Caminha Pet Media', 'Caminha acolchoada lavavel', 'PetStyle', D('129.90'), 4, False, 2, 3, D('60.00'), 1, '7890000000141'),
}
for k, v in NOVOS.items():
    PROD[k] = (v[0], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9])

# sobra desejada no fim do histórico (só produtos novos; os demais esgotam os lotes históricos)
SOBRA = {7: 18, 8: 6, 9: 14, 10: 9, 11: 2, 12: 70, 13: 11, 14: 3}

# --------------------------------------------------------------- clientes
NOMES = ['Ana Carolina Ribeiro', 'Bruno Henrique Alves', 'Carla Fernandes', 'Daniel Moreira', 'Eduarda Castro',
         'Felipe Nogueira', 'Gabriela Teixeira', 'Henrique Barbosa', 'Isabela Martins', 'Jorge Pereira',
         'Karina Duarte', 'Leonardo Cardoso', 'Mariana Lopes', 'Nathalia Freitas', 'Otavio Ramos',
         'Paula Cristina Dias', 'Rafael Monteiro', 'Sabrina Azevedo', 'Thiago Correia', 'Vanessa Pinto',
         'Wagner Batista', 'Yara Campos', 'Andre Luiz Farias', 'Bianca Moura', 'Caio Vieira',
         'Debora Santana', 'Eduardo Machado', 'Fabiana Rezende', 'Gustavo Peixoto', 'Helena Cavalcanti']
CLIENTES = []
for i, nome in enumerate(NOMES):
    idc = 7 + i
    cpf = f'{random.randint(100000000, 999999999)}{random.randint(10, 99)}'
    login = nome.lower().split()[0] + '.' + nome.lower().split()[-1]
    CLIENTES.append((idc, nome, cpf, f'1192{1000000 + idc * 731:07d}', f'{login}@email.com'))
TODOS_CLIENTES = list(range(1, 7)) + [c[0] for c in CLIENTES]
# alguns clientes compram com mais frequência (base para o indicador de recompra)
PESO_CLIENTE = {c: (6 if c in (1, 2, 9, 14, 21, 30) else 3 if c % 4 == 0 else 1) for c in TODOS_CLIENTES}

ENDERECOS = [('Rua Augusta', 'Consolacao', '01305000'), ('Avenida Paulista', 'Bela Vista', '01311000'),
             ('Rua Vergueiro', 'Vila Mariana', '04101000'), ('Rua Domingos de Morais', 'Vila Mariana', '04010000'),
             ('Avenida Ibirapuera', 'Moema', '04029000'), ('Rua Teodoro Sampaio', 'Pinheiros', '05405000'),
             ('Rua Tuiuti', 'Tatuape', '03081000'), ('Avenida Santo Amaro', 'Brooklin', '04506000')]

# ------------------------------------------------------------ pedidos
pedidos = []          # dicts
pid = 1001
dia = INICIO
while dia <= FIM:
    progresso = (dia - INICIO).days / (FIM - INICIO).days     # 0 -> 1 ao longo do período
    base = 3.0 + 2.0 * progresso                                # as vendas crescem no período
    if dia.weekday() >= 5:
        base += 2.0                                             # fim de semana vende mais
    n = max(1, int(random.gauss(base, 1.0)))
    for _ in range(n):
        virtual = random.random() < 0.30 + 0.20 * progresso     # a loja virtual ganha espaço
        hora = datetime(dia.year, dia.month, dia.day, random.randint(9, 19), random.choice([0, 10, 20, 30, 40, 50]))
        prods = [p for p in PROD if PROD[p][8] > 0]
        pesos = [PROD[p][8] for p in prods]
        if dia >= date(2026, 10, 1):                            # antipulgas só em outubro (lote 5)
            prods.append(3)
            pesos.append(3)
        k = random.choices([1, 2, 3], weights=[55, 32, 13])[0]
        itens = {}
        while len(itens) < k:
            p = random.choices(prods, weights=pesos)[0]
            if p in itens:
                continue
            qt = random.choice([3, 6, 6, 12]) if p == 12 else random.choices([1, 2, 3], weights=[75, 20, 5])[0]
            itens[p] = qt
        pedidos.append({'id': pid, 'data': hora, 'virtual': virtual, 'itens': itens,
                        'cliente': random.choices(TODOS_CLIENTES, weights=[PESO_CLIENTE[c] for c in TODOS_CLIENTES])[0]})
        pid += 1
    dia += timedelta(days=1)
pedidos.sort(key=lambda p: p['data'])
for i, p in enumerate(pedidos):
    p['id'] = 1001 + i
limite_antipulgas = 12                                           # o lote 5 tem 25 un.; o pedido 5 (27/10) usa 1
for p in pedidos:
    if 3 in p['itens']:
        if limite_antipulgas - p['itens'][3] < 0:
            del p['itens'][3]
        else:
            limite_antipulgas -= p['itens'][3]
pedidos = [p for p in pedidos if p['itens']]

# detalhes de cada pedido
for p in pedidos:
    t = p['data']
    if p['virtual']:
        p['canal'] = 'loja_virtual'
        p['receb'] = 'entrega' if random.random() < 0.7 else 'retirada'
        p['func'] = None if p['receb'] == 'entrega' else CAIXA
        p['cancelado'] = random.random() < 0.04
        p['forma'] = 'pix' if random.random() < 0.45 else 'cartao_credito'
        if p['cancelado']:
            p['forma'] = 'pix'
        p['status'] = 'cancelado' if p['cancelado'] else ('entregue' if p['receb'] == 'entrega' else 'retirado')
        p['t_venda'] = (t + timedelta(days=1)).replace(hour=9 if p['receb'] == 'entrega' else 16, minute=0)
    else:
        p['canal'] = 'loja_fisica'
        p['receb'] = 'balcao'
        p['func'] = random.choice([CAIXA, CAIXA, CAIXA, ATENDENTE])
        p['cancelado'] = False
        p['forma'] = random.choices(['dinheiro', 'pix', 'cartao_debito', 'cartao_credito'], weights=[18, 34, 22, 26])[0]
        p['status'] = 'pago'
        p['t_venda'] = t
    valor_itens = sum(PROD[i][2] * qt for i, qt in p['itens'].items())
    p['desconto'] = D('0')
    p['aut_desc'] = None
    if not p['virtual'] and valor_itens >= 150 and random.random() < 0.15:
        p['desconto'] = D(valor_itens * Decimal('0.05'))      # desconto acima do limite, autorizado (RP05)
        p['aut_desc'] = GERENTE
    p['total'] = valor_itens - p['desconto']
    p['parcelas'] = 1
    if p['forma'] == 'cartao_credito' and p['total'] >= 100:
        p['parcelas'] = random.choice([1, 2, 3, 3])

# ------------------------------------------------------- estoque (simulação)
# lotes históricos: (produto, código, entrada, validade); A = julho, B = setembro
LOTES_H = {}
lid = 101
VALIDADE_H = {   # validade de A e B: vencem antes dos lotes da massa principal (FEFO)
    1: (date(2026, 10, 15), date(2026, 11, 10)), 2: (date(2027, 6, 30), date(2027, 9, 30)),
    4: (None, None), 5: (date(2026, 12, 1), date(2027, 2, 1)), 6: (date(2026, 9, 30), date(2026, 11, 5)),
    7: (None, None), 8: (None, None), 9: (date(2027, 6, 30), date(2027, 9, 30)), 10: (None, None),
    11: (None, None), 12: (date(2027, 1, 31), date(2027, 4, 30)), 13: (date(2027, 3, 31), date(2027, 6, 30)),
    14: (None, None),
}
ENTRADA_A, ENTRADA_B = date(2026, 7, 20), date(2026, 9, 5)
CORTE = datetime(2026, 9, 8)      # até aqui a demanda sai do lote A; depois, do lote B

# 1) demanda por produto, separada pelo corte (momento em que a unidade é retirada do disponível)
dem = {p: [0, 0] for p in PROD}
for p in pedidos:
    if p['cancelado']:             # a reserva do pedido cancelado é liberada: não consome estoque
        continue
    tt = p['data']                 # loja física: venda; loja virtual: reserva
    for i, qt in p['itens'].items():
        if i == 3:
            continue
        dem[i][0 if tt < CORTE else 1] += qt
# perdas por avaria (consomem estoque, com autorizador da gerência - RP11)
PERDAS = [(12, datetime(2026, 8, 18, 17, 0), 6, 'Caixa de saches amassada no recebimento'),
          (7, datetime(2026, 9, 22, 18, 0), 2, 'Saco de areia rasgado na prateleira'),
          (13, datetime(2026, 10, 9, 17, 30), 1, 'Embalagem furada durante a reposicao')]
for prod, t, qt, _ in PERDAS:
    dem[prod][0 if t < CORTE else 1] += qt

for prod in VALIDADE_H:
    va, vb = VALIDADE_H[prod]
    qa, qb = dem[prod]
    qb += SOBRA.get(prod, 0)
    sig = {1: 'RAC', 2: 'SHA', 4: 'BRQ', 5: 'GAT', 6: 'PET', 7: 'ARE', 8: 'TAP', 9: 'VRM', 10: 'COL',
           11: 'ARR', 12: 'SAC', 13: 'FIL', 14: 'CAM'}[prod]
    LOTES_H[prod] = []
    for letra, ent, val, qtd in (('A', ENTRADA_A, va, qa), ('B', ENTRADA_B, vb, qb)):
        if qtd <= 0:
            continue
        LOTES_H[prod].append({'id': lid, 'prod': prod, 'cod': f'LOTE-{sig}-HIST-{letra}', 'entrada': ent,
                              'validade': val, 'qtd': qtd, 'saldo': 0, 'res': 0, 'letra': letra})
        lid += 1
# antipulgas: vende do lote 5 da massa principal (25 un., validade 01/07/2027)
LOTE5 = {'id': 5, 'prod': 3, 'validade': date(2027, 7, 1), 'entrada': date(2026, 7, 1), 'saldo': 25, 'res': 0}

# 2) compras: uma por fornecedor em julho e outra em setembro
compras, itens_compra, movs, contas_pagar, pags_conta = [], [], [], [], []
cid, mid, cpid, pcid = 201, 1001, 201, 201
for letra, data_compra, ent in (('A', date(2026, 7, 13), ENTRADA_A), ('B', date(2026, 8, 31), ENTRADA_B)):
    for forn in (1, 2, 3):
        lotes = [l for prod in LOTES_H for l in LOTES_H[prod] if l['letra'] == letra and PROD[prod][6] == forn]
        if not lotes:
            continue
        total = D('0')
        for l in lotes:
            itens_compra.append((cid, l['prod'], l['qtd'], PROD[l['prod']][7]))
            total += PROD[l['prod']][7] * l['qtd']
            l['compra'] = cid
            movs.append({'id': mid, 'tipo': 'entrada', 'qt': l['qtd'],
                         't': datetime(ent.year, ent.month, ent.day, 8 + forn, 0),
                         'motivo': f'Recebimento compra {cid}', 'lote': l['id'], 'func': ESTOQUISTA, 'aut': None,
                         'prod': l['prod'], 'compra': cid, 'pedido': None})
            mid += 1
            l['saldo'] = l['qtd']
        compras.append((cid, data_compra, 'recebida', forn))
        p1 = D(total / 2)
        for n, val in ((1, p1), (2, total - p1)):
            venc = data_compra + timedelta(days=30 * n)
            contas_pagar.append((cpid, cid, n, val, venc))
            if venc <= REF:
                pags_conta.append((pcid, cpid, val, venc, 'boleto'))
                pcid += 1
            cpid += 1
        cid += 1


def lotes_do(prod):
    if prod == 3:
        return [LOTE5]
    return LOTES_H[prod]


def aloca(prod, qt, t):
    """FEFO: lote que vence primeiro (sem validade: o que entrou primeiro), só com disponível."""
    cand = [l for l in lotes_do(prod) if l['entrada'] <= t.date()
            and (l['validade'] is None or l['validade'] >= t.date())]
    cand.sort(key=lambda l: (l['validade'] or date(9999, 1, 1), l['entrada']))
    saida = []
    for l in cand:
        disp = l['saldo'] - l['res']
        if disp <= 0:
            continue
        x = min(disp, qt)
        saida.append((l, x))
        qt -= x
        if qt == 0:
            return saida
    raise RuntimeError(f'estoque insuficiente produto {prod} em {t}')


# 3) eventos em ordem cronológica: reserva / venda / perda
eventos = []
for p in pedidos:
    if p['virtual']:
        eventos.append((p['data'], 0, 'reserva', p))
        eventos.append((p['data'] + timedelta(minutes=50) if p['cancelado'] else p['t_venda'], 1,
                        'libera' if p['cancelado'] else 'venda_v', p))
    else:
        eventos.append((p['data'], 0, 'venda_f', p))
for prod, t, qt, motivo in PERDAS:
    eventos.append((t, 2, 'perda', (prod, qt, motivo)))
eventos.sort(key=lambda e: (e[0], e[1]))

for t, _, tipo, obj in eventos:
    if tipo == 'perda':
        prod, qt, motivo = obj
        for l, x in aloca(prod, qt, t):
            l['saldo'] -= x
            movs.append({'id': mid, 'tipo': 'perda', 'qt': x, 't': t, 'motivo': motivo, 'lote': l['id'],
                         'func': ESTOQUISTA, 'aut': GERENTE, 'prod': prod, 'compra': None, 'pedido': None})
            mid += 1
        continue
    p = obj
    if tipo in ('reserva', 'venda_f'):
        p['aloc'] = {}
        for prod, qt in p['itens'].items():
            p['aloc'][prod] = aloca(prod, qt, t)
            for l, x in p['aloc'][prod]:
                if tipo == 'reserva':
                    l['res'] += x
                    movs.append({'id': mid, 'tipo': 'reserva', 'qt': x, 't': t, 'motivo': f'Reserva pedido {p["id"]}',
                                 'lote': l['id'], 'func': None, 'aut': None, 'prod': prod, 'compra': None, 'pedido': p['id']})
                else:
                    l['saldo'] -= x
                    movs.append({'id': mid, 'tipo': 'venda', 'qt': x, 't': t, 'motivo': f'Venda balcao pedido {p["id"]}',
                                 'lote': l['id'], 'func': p['func'], 'aut': None, 'prod': prod, 'compra': None, 'pedido': p['id']})
                mid += 1
    else:
        for prod, aloc in p['aloc'].items():
            for l, x in aloc:
                l['res'] -= x
                if tipo == 'venda_v':
                    l['saldo'] -= x
                    resp = ESTOQUISTA if p['receb'] == 'entrega' else CAIXA
                    mot = f'Baixa no envio do pedido {p["id"]}' if p['receb'] == 'entrega' else f'Baixa na retirada do pedido {p["id"]}'
                    movs.append({'id': mid, 'tipo': 'venda', 'qt': x, 't': t, 'motivo': mot, 'lote': l['id'],
                                 'func': resp, 'aut': None, 'prod': prod, 'compra': None, 'pedido': p['id']})
                else:
                    movs.append({'id': mid, 'tipo': 'liberacao_reserva', 'qt': x, 't': t,
                                 'motivo': f'PIX nao pago - cancelamento do pedido {p["id"]}', 'lote': l['id'],
                                 'func': None, 'aut': None, 'prod': prod, 'compra': None, 'pedido': p['id']})
                mid += 1

# conferências da simulação
for prod, lotes in LOTES_H.items():
    for l in lotes:
        assert l['res'] == 0, l
        esperado = SOBRA.get(prod, 0) if l['letra'] == 'B' else 0
        assert l['saldo'] == esperado, (prod, l['cod'], l['saldo'], esperado)
assert LOTE5['res'] == 0 and LOTE5['saldo'] >= 13

# ------------------------------------------------- pagamentos e financeiro
pagamentos, contas_receber, entregas = [], [], []
gid, crid, eid = 1001, 1001, 101
TAXA = {'dinheiro': Decimal('0'), 'pix': Decimal('0'), 'cartao_debito': Decimal('0.0199'), 'cartao_credito': Decimal('0.05')}
for p in pedidos:
    t = p['data']
    if p['cancelado']:
        pagamentos.append((gid, p['id'], 'pix', p['total'], 1, None, 'recusado'))
        gid += 1
        continue
    pagamentos.append((gid, p['id'], p['forma'], p['total'], p['parcelas'], t, 'autorizado'))
    n = p['parcelas']
    base = D(p['total'] / n)
    for k in range(1, n + 1):
        bruto = base if k < n else p['total'] - base * (n - 1)
        liquido = D(bruto * (1 - TAXA[p['forma']]))
        if p['forma'] == 'cartao_credito':
            prev = t.date() + timedelta(days=30 * k)
        elif p['forma'] == 'cartao_debito':
            prev = t.date() + timedelta(days=1)
        else:
            prev = t.date()
        rec = prev if prev <= REF else None
        contas_receber.append((crid, gid, k, bruto, liquido, prev, rec, 'recebida' if rec else 'pendente'))
        crid += 1
    gid += 1
    if p['receb'] == 'entrega' and not p['cancelado']:
        rua, bairro, cep = random.choice(ENDERECOS)
        prev = t.date() + timedelta(days=3)
        ent = t.date() + timedelta(days=random.choice([2, 2, 3]))
        entregas.append((eid, p['id'], rua, str(random.randint(10, 2500)), None, bairro, 'Sao Paulo', 'SP', cep,
                         prev, ent, 'entregue'))
        eid += 1
    elif p['receb'] == 'entrega':
        pass

# ----------------------------------------------------------------- SQL
L = []
w = L.append
w('-- ============================================================================')
w('-- PROJETO ERP PETLY CLUB - MASSA DE DADOS HISTÓRICA (VENDAS DE 01/08 A 19/10/2026)')
w('-- ============================================================================')
w('-- Grupo 7 | SGBD: PostgreSQL 16 | Data de referência dos testes: 27/10/2026')
w('-- Pré-requisito: petly_club_ddl_limpo.sql + Massa_de_Dados_Completa_-_ERP_Petly_Club.sql')
w('-- Como rodar:    psql -d petly_club -f Massa_Historico_Vendas_ERP_Petly_Club.sql')
w('--')
w('-- Objetivo: dar ao banco alguns meses de histórico para as consultas gerenciais, os indicadores')
w('-- e a proposta de BI (evolução das vendas, ticket médio, recompra, giro). A massa principal cobre')
w('-- os cenários da seção 17.1; esta cobre o volume. Nenhum registro da massa principal é alterado.')
w('--')
w('-- Como foi gerada: script gerar_massa_historico.py (nesta pasta), escrito com auxílio de IA')
w('-- (Claude) e validado pela equipe. O script simula o estoque dia a dia e só grava o que o banco aceita:')
w('-- - toda saída usa FEFO (RN20): o lote que vence primeiro; os lotes históricos dos produtos 1, 2, 4, 5')
w('--   e 6 vencem antes dos lotes da massa principal e terminam com saldo zero em 19/10;')
w('-- - o antipulgas só vende em outubro, do lote 5, porque o lote 4 venceu em 30/09 (cenário 3);')
w('-- - loja virtual: reserva no pedido e venda no envio ou na retirada (RN21); cancelado libera a reserva;')
w('-- - todo pagamento autorizado gera contas a receber que somam o seu valor (RN24); crédito em até 3x,')
w('--   com taxa de 5%; débito 1,99%; parcela com data prevista até 27/10 está recebida, depois, pendente;')
w('-- - toda compra tem as entradas de tudo que foi comprado e duas parcelas a pagar que somam o total;')
w('-- - desconto só com autorizador (RP05); perda só com motivo e autorizador gerente (RP11).')
w('-- Validação: depois desta carga, os testes de integridade dão o resultado esperado e as 10 consultas')
w('-- de auditoria continuam retornando 0 linhas.')
w('--')
w(f'-- Conteúdo: {len(CLIENTES)} clientes, {len(NOVOS)} produtos, {len(compras)} compras, '
  f'{sum(len(v) for v in LOTES_H.values())} lotes, {len(pedidos)} pedidos, {len(movs)} movimentações de estoque,')
w(f'-- {len(pagamentos)} pagamentos, {len(contas_receber)} contas a receber, {len(entregas)} entregas, '
  f'{len(contas_pagar)} contas a pagar e {len(pags_conta)} pagamentos de contas.')
w('-- Faixas de id próprias (pedido >= 1001, lote >= 101, compra >= 201...), sem conflito com a massa')
w('-- principal nem com os ids usados nos testes.')
w('-- ============================================================================')
w('')
w('BEGIN;')
w('')


def ins(tabela, colunas, linhas, override=True, comentario=None):
    if comentario:
        w(f'-- {comentario}')
    for i in range(0, len(linhas), 200):
        bloco = linhas[i:i + 200]
        w(f'INSERT INTO {tabela} ({", ".join(colunas)})' + (' OVERRIDING SYSTEM VALUE' if override else '') + ' VALUES')
        w(',\n'.join('(' + ', '.join(q(v) for v in r) + ')' for r in bloco) + ';')
    w('')


ins('cliente', ['id_cliente', 'nome', 'cpf', 'telefone', 'email'], CLIENTES, comentario='1. Novos clientes (RF03)')
ins('produto', ['id_produto', 'nome', 'descricao', 'marca', 'codigo_barras', 'preco', 'estoque_minimo',
                'controla_validade', 'id_categoria'],
    [(k, v[0], v[1], v[2], v[10], v[3], v[6], v[5], v[4]) for k, v in NOVOS.items()],
    comentario='2. Novos produtos (RF01, RF02)')
ins('compra', ['id_compra', 'data_compra', 'status', 'id_fornecedor'], compras,
    comentario='3. Compras de julho e setembro, todas recebidas (RN10, RN25)')
ins('item_compra', ['id_compra', 'id_produto', 'quantidade_comprada', 'custo_unitario'], itens_compra, override=False)
lotes_sql = [(l['id'], l['cod'], l['entrada'], l['validade'], l['prod']) for v in LOTES_H.values() for l in v]
ins('lote', ['id_lote', 'codigo_lote', 'data_entrada', 'data_validade', 'id_produto'], lotes_sql,
    comentario='4. Lotes históricos: A (entrada 20/07) e B (entrada 05/09)')
ins('conta_pagar', ['id_conta_pagar', 'id_compra', 'numero_parcela', 'valor', 'data_vencimento'], contas_pagar,
    comentario='5. Contas a pagar: 2 parcelas por compra (30 e 60 dias). O status é atualizado pelo gatilho [TRG-08]')
ins('pagamento_conta', ['id_pagamento_conta', 'id_conta_pagar', 'valor_pago', 'data_pagamento', 'forma_pagamento'],
    pags_conta, comentario='   Parcelas vencidas até 27/10 foram pagas no vencimento')
ins('pedido', ['id_pedido', 'data_pedido', 'canal_venda', 'tipo_recebimento', 'status', 'desconto', 'id_cliente',
               'id_funcionario', 'id_autorizador_desconto'],
    [(p['id'], p['data'], p['canal'], p['receb'], p['status'], p['desconto'], p['cliente'], p['func'], p['aut_desc'])
     for p in pedidos], comentario='6. Pedidos de 01/08 a 19/10/2026 (loja física e loja virtual)')
ins('item_pedido', ['id_pedido', 'id_produto', 'quantidade', 'preco_unitario'],
    [(p['id'], i, qt, PROD[i][2]) for p in pedidos for i, qt in p['itens'].items()], override=False,
    comentario='   Preço praticado = preço de catálogo no momento da venda (RN13)')
movs.sort(key=lambda m: (m['t'], m['id']))
ins('movimentacao_estoque', ['id_movimentacao', 'tipo', 'quantidade', 'data_hora', 'motivo', 'id_lote',
                             'id_funcionario', 'id_autorizador', 'id_produto', 'id_compra', 'id_pedido'],
    [(m['id'], m['tipo'], m['qt'], m['t'], m['motivo'], m['lote'], m['func'], m['aut'], m['prod'], m['compra'],
      m['pedido']) for m in movs],
    comentario='7. Movimentações em ordem cronológica (entradas, reservas, vendas, liberações e perdas)')
ins('pagamento', ['id_pagamento', 'id_pedido', 'forma_pagamento', 'valor', 'numero_parcelas', 'data_autorizacao',
                  'status'], pagamentos, comentario='8. Pagamentos (PIX não pago = recusado, sem conta a receber)')
ins('conta_receber', ['id_conta_receber', 'id_pagamento', 'numero_parcela', 'valor_bruto', 'valor_liquido',
                      'data_prevista', 'data_recebimento', 'status'], contas_receber,
    comentario='9. Contas a receber (RN24): autorizado não é recebido')
ins('entrega', ['id_entrega', 'id_pedido', 'logradouro', 'numero', 'complemento', 'bairro', 'cidade', 'uf', 'cep',
                'data_prevista', 'data_entrega', 'status'], entregas, comentario='10. Entregas concluídas')
w('-- 11. Reajuste das sequences')
for tab, col in (('cliente', 'id_cliente'), ('produto', 'id_produto'), ('lote', 'id_lote'), ('compra', 'id_compra'),
                 ('pedido', 'id_pedido'), ('movimentacao_estoque', 'id_movimentacao'), ('entrega', 'id_entrega'),
                 ('pagamento', 'id_pagamento'), ('conta_receber', 'id_conta_receber'),
                 ('conta_pagar', 'id_conta_pagar'), ('pagamento_conta', 'id_pagamento_conta')):
    w(f"SELECT setval(pg_get_serial_sequence('{tab}', '{col}'), (SELECT MAX({col}) FROM {tab}));")
w('')
w('COMMIT;')
with open(SAIDA, 'w', encoding='utf-8') as f:
    f.write('\n'.join(L) + '\n')
print(SAIDA)
print(f'{len(pedidos)} pedidos, {len(movs)} movimentações, {len(contas_receber)} contas a receber')
