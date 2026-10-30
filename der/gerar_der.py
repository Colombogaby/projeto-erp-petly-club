"""
Gera o DER do Projeto ERP Petly Club (notação de Peter Chen) em PDF A3.
Página 1: visão geral. Página 2: com atributos.
Uso: python gerar_der.py  -> cria DER.pdf na mesma pasta
Requer: reportlab (pip install reportlab)
"""
import math
import os
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A3, landscape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

AQUI = os.path.dirname(os.path.abspath(__file__))
FONTES = '/usr/share/fonts/truetype/dejavu/'
pdfmetrics.registerFont(TTFont('DJ', FONTES + 'DejaVuSans.ttf'))
pdfmetrics.registerFont(TTFont('DJB', FONTES + 'DejaVuSans-Bold.ttf'))
pdfmetrics.registerFont(TTFont('DJI', FONTES + 'DejaVuSans-Oblique.ttf'))

W, H = landscape(A3)
K = W / 2000.0  # coordenadas abaixo estão numa grade de 2000 x 1414


def P(x, y):
    return x * K, H - y * K


AZUL, LARANJA, VERDE = '#e3eef2', '#fde8d7', '#e8f3e0'
LOSANGO, LOSANGO_NOVO, BORDA_NOVA = '#fdf3d6', '#d4ecd0', '#2e7d32'
VERMELHO, CINZA = '#8b1a1a', '#555555'

# ---------------------------------------------------------------- entidades
# nome: (x, y, cor, atributos). '*' = identificador, '~' = derivado,
# '+' = composto (lista de partes na tupla seguinte)
E = {
    'PRODUTO': (1016, 212, AZUL, ['*id_produto', 'nome', 'descricao', 'marca', 'codigo_barras', 'preco',
                                  'estoque_minimo', 'controla_validade']),
    'CATEGORIA': (1390, 212, AZUL, ['*id_categoria', 'nome', 'descricao']),
    'CLIENTE': (378, 437, AZUL, ['*id_cliente', 'nome', 'cpf', 'telefone', 'email']),
    'LOTE': (1016, 437, LARANJA, ['*id_lote', 'codigo_lote', 'data_validade', 'data_entrada',
                                  '~saldo_fisico', '~quantidade_reservada', '~quantidade_disponivel']),
    'FORNECEDOR': (1724, 437, AZUL, ['*id_fornecedor', 'razao_social', 'cnpj', 'telefone', 'email']),
    'PEDIDO': (378, 678, AZUL, ['*id_pedido', 'data_pedido', 'canal_venda', 'tipo_recebimento', 'status',
                                'desconto', '~valor_total']),
    'MOVIMENTACAO_ESTOQUE': (1016, 678, LARANJA, ['*id_movimentacao', 'tipo', 'quantidade', 'data_hora',
                                                  'motivo']),
    'COMPRA': (1724, 678, AZUL, ['*id_compra', 'data_compra', 'status', '~valor_total']),
    'ENTREGA': (165, 1000, AZUL, ['*id_entrega', ('endereco_entrega (composto):',
                                                  ['logradouro, numero,', 'complemento, bairro,',
                                                   'cidade, uf, cep']),
                                  'data_prevista', 'data_entrega', 'status']),
    'PAGAMENTO': (345, 985, AZUL, ['*id_pagamento', 'forma_pagamento', 'valor', 'numero_parcelas',
                                    'data_autorizacao', 'status']),
    'CONTA_RECEBER': (345, 1212, LARANJA, ['*id_conta_receber', 'numero_parcela', 'valor_bruto',
                                           'valor_liquido', 'data_prevista', 'data_recebimento', 'status']),
    'FUNCIONÁRIO': (810, 915, AZUL, ['*id_funcionario', 'nome', 'cpf', 'cargo', 'login', 'senha']),
    'CONTA_PAGAR': (1724, 980, AZUL, ['*id_conta_pagar', 'numero_parcela', 'valor', 'data_vencimento',
                                      '~valor_pago', 'status']),
    'PAGAMENTO_CONTA': (1724, 1215, LARANJA, ['*id_pagamento_conta', 'valor_pago', 'data_pagamento',
                                              'forma_pagamento']),
}
# entidades associativas: nome -> (x, y, losango interno, regra, atributos)
A = {
    'ITEM_PEDIDO': (646, 678, 'contém', 'RN03, RN13', ['quantidade', 'preco_unitario', '~subtotal']),
    'ITEM_COMPRA': (1395, 678, 'repõe', 'RN10', ['quantidade_comprada', 'custo_unitario',
                                                 '~quantidade_recebida']),
}

# ------------------------------------------------------------ relacionamentos
# (nome, x, y, regra, (entidade1, card1), (entidade2, card2), novo?)
R = [
    ('classifica', 1203, 212, 'RN04', ('PRODUTO', '(1,1)'), ('CATEGORIA', '(0,N)'), False),
    ('possui', 1016, 324, 'RN11', ('PRODUTO', '(0,N)'), ('LOTE', '(1,1)'), False),
    ('sofre', 1016, 557, 'RN19', ('LOTE', '(1,N)'), ('MOVIMENTACAO_ESTOQUE', '(1,1)'), False),
    ('realiza', 378, 557, 'RN01, RN02', ('CLIENTE', '(0,N)'), ('PEDIDO', '(1,1)'), False),
    ('origina', 831, 678, 'RN20, RN21, RN22', ('ITEM_PEDIDO', '(1,N)'), ('MOVIMENTACAO_ESTOQUE', '(0,1)'), False),
    ('origina', 1205, 678, 'RN25', ('MOVIMENTACAO_ESTOQUE', '(0,1)'), ('ITEM_COMPRA', '(0,N)'), False),
    ('atende', 1724, 557, 'RN10', ('FORNECEDOR', '(0,N)'), ('COMPRA', '(1,1)'), False),
    ('gera', 1724, 834, 'RN12', ('COMPRA', '(1,N)'), ('CONTA_PAGAR', '(1,1)'), False),
    ('quita', 1724, 1100, 'RN23', ('CONTA_PAGAR', '(0,N)'), ('PAGAMENTO_CONTA', '(1,1)'), False),
    ('gera', 230, 840, 'RN17', ('PEDIDO', '(0,1)'), ('ENTREGA', '(1,1)'), False),
    ('possui', 345, 840, 'RN15', ('PEDIDO', '(1,N)'), ('PAGAMENTO', '(1,1)'), False),
    ('gera', 345, 1100, 'RN24', ('PAGAMENTO', '(0,N)'), ('CONTA_RECEBER', '(1,1)'), False),
    ('registra', 650, 782, 'RN14', ('PEDIDO', '(0,1)'), ('FUNCIONÁRIO', '(0,N)'), False),
    ('autoriza desconto', 625, 890, 'RP05, RF32 [A3]', ('PEDIDO', '(0,1)'), ('FUNCIONÁRIO', '(0,N)'), True),
    ('autoriza cancelamento', 525, 1000, 'RP07, RF16 [A3]', ('PEDIDO', '(0,1)'), ('FUNCIONÁRIO', '(0,N)'), True),
    ('registra', 940, 810, 'RN19', ('MOVIMENTACAO_ESTOQUE', '(0,1)'), ('FUNCIONÁRIO', '(0,N)'), False),
    ('autoriza', 1080, 880, 'RP11, RF35 [A2]', ('MOVIMENTACAO_ESTOQUE', '(0,1)'), ('FUNCIONÁRIO', '(0,N)'), True),
]
# ligações diretas produto -> associativas (o losango fica dentro da associativa)
DIRETAS = [
    (('PRODUTO', '(0,N)'), ('ITEM_PEDIDO', None)),
    (('PRODUTO', '(0,N)'), ('ITEM_COMPRA', None)),
    (('PEDIDO', '(1,N)'), ('ITEM_PEDIDO', None)),
    (('ITEM_COMPRA', None), ('COMPRA', '(1,N)')),
]

# (índice do relacionamento em R, entidade) -> distância do rótulo ao longo da linha
DIST_CARD = {(12, 'PEDIDO'): 16, (13, 'PEDIDO'): 34, (14, 'PEDIDO'): 52, (15, 'FUNCIONÁRIO'): 30,
             (11, 'CONTA_RECEBER'): 5, (1, 'LOTE'): 5}

FS_NOME, FS_ATR, FS_CARD, FS_REGRA, FS_LOS = 7.0, 5.6, 5.4, 4.8, 5.8


def caixa(nome, com_atributos):
    """Retorna (largura, altura) da caixa em pontos."""
    if nome in A:
        x, y, los, regra, atrs = A[nome]
        if not com_atributos:
            return 88, 54
        linhas = len(atrs)
        larg = max(pdfmetrics.stringWidth('○ ' + a.strip('*~') + (' (derivado)' if a.startswith('~') else ''),
                                          'DJ', FS_ATR) for a in atrs) + 12
        return max(88, larg), 48 + linhas * 7.6
    x, y, cor, atrs = E[nome]
    wn = pdfmetrics.stringWidth(nome, 'DJB', FS_NOME) + 22
    if not com_atributos:
        return max(62, wn), 24
    linhas = 0
    larg = wn
    for a in atrs:
        if isinstance(a, tuple):
            linhas += 1 + len(a[1])
            larg = max(larg, pdfmetrics.stringWidth('○ ' + a[0], 'DJ', FS_ATR) + 12)
        else:
            t = '● ' + a[1:] if a.startswith('*') else '○ ' + a.strip('~') + (' (derivado)' if a.startswith('~') else '')
            larg = max(larg, pdfmetrics.stringWidth(t, 'DJ', FS_ATR) + 12)
            linhas += 1
    return larg, 14 + linhas * 7.6 + 4


def centro(nome):
    d = E.get(nome) or A.get(nome)
    return P(d[0], d[1])


def tam_losango(texto):
    return max(50, pdfmetrics.stringWidth(texto, 'DJ', FS_LOS) + 22), 24


def corte_caixa(cx, cy, w, h, dx, dy):
    """Ponto da borda de uma caixa centrada em (cx,cy) na direção (dx,dy)."""
    tx = (w / 2) / abs(dx) if dx else 1e9
    ty = (h / 2) / abs(dy) if dy else 1e9
    t = min(tx, ty)
    return cx + dx * t, cy + dy * t


def corte_losango(cx, cy, w, h, dx, dy):
    t = 1 / (abs(dx) / (w / 2) + abs(dy) / (h / 2))
    return cx + dx * t, cy + dy * t


def borda(no, alvo, com_atr):
    """no: ('E', nome) ou ('R', idx). Retorna ponto da borda na direção do alvo."""
    cx, cy = no_centro(no)
    tx, ty = alvo
    dx, dy = tx - cx, ty - cy
    n = math.hypot(dx, dy)
    dx, dy = dx / n, dy / n
    if no[0] == 'E':
        w, h = caixa(no[1], com_atr)
        return corte_caixa(cx, cy, w, h, dx, dy)
    w, h = tam_losango(R[no[1]][0])
    return corte_losango(cx, cy, w, h, dx, dy)


def no_centro(no):
    if no[0] == 'E':
        return centro(no[1])
    r = R[no[1]]
    return P(r[1], r[2])


def cardinalidade(c, p_borda, outro, card, dist=12):
    """Escreve a cardinalidade perto da entidade, ao lado da linha."""
    dx, dy = outro[0] - p_borda[0], outro[1] - p_borda[1]
    n = math.hypot(dx, dy)
    dx, dy = dx / n, dy / n
    px, py = -dy, dx
    if px < 0 or (abs(px) < 1e-6 and py < 0):
        px, py = -px, -py
    x = p_borda[0] + dx * dist + px * 14
    y = p_borda[1] + dy * dist + py * 14 - 2
    c.setFont('DJB', FS_CARD)
    c.setFillColor(VERMELHO)
    c.drawCentredString(x, y, card)


def linha(c, a, b):
    c.setStrokeColor('#222222')
    c.setLineWidth(0.6)
    c.line(a[0], a[1], b[0], b[1])


def desenha_entidade(c, nome, com_atr):
    cx, cy = centro(nome)
    w, h = caixa(nome, com_atr)
    x0, y0 = cx - w / 2, cy - h / 2
    if nome in A:
        _, _, los, regra, atrs = A[nome]
        c.setFillColor(VERDE)
        c.setStrokeColor('#222222')
        c.setLineWidth(0.7)
        c.rect(x0, y0, w, h, fill=1, stroke=1)
        topo = cy + h / 2
        lw, lh = tam_losango(los)
        losango(c, cx, topo - 14, lw, lh - 4, los, LOSANGO, '#222222')
        c.setFillColor('black')
        c.setFont('DJB', FS_NOME)
        c.drawCentredString(cx, topo - 33, nome)
        if com_atr:
            c.setLineWidth(0.5)
            c.line(x0, topo - 38, x0 + w, topo - 38)
            yy = topo - 46
            for a in atrs:
                deriv = a.startswith('~')
                c.setFont('DJI' if deriv else 'DJ', FS_ATR)
                c.drawString(x0 + 5, yy, '○ ' + a.strip('~') + (' (derivado)' if deriv else ''))
                yy -= 7.6
        else:
            c.setFont('DJI', FS_REGRA)
            c.setFillColor(CINZA)
            c.drawCentredString(cx, topo - 41, regra)
        return
    cor = E[nome][2]
    c.setFillColor(cor)
    c.setStrokeColor('#222222')
    c.setLineWidth(0.8)
    c.rect(x0, y0, w, h, fill=1, stroke=1)
    c.setFillColor('black')
    if not com_atr:
        c.setFont('DJB', FS_NOME)
        c.drawCentredString(cx, cy - 2.5, nome)
        return
    topo = cy + h / 2
    c.setFont('DJB', FS_NOME * 0.9)
    c.drawCentredString(cx, topo - 9, nome)
    c.setLineWidth(0.5)
    c.line(x0, topo - 12.5, x0 + w, topo - 12.5)
    yy = topo - 20
    for a in E[nome][3]:
        if isinstance(a, tuple):
            c.setFont('DJ', FS_ATR)
            c.drawString(x0 + 5, yy, '○ ' + a[0])
            yy -= 7.6
            c.setFillColor(CINZA)
            c.setFont('DJ', FS_ATR * 0.9)
            for parte in a[1]:
                c.drawString(x0 + 14, yy, parte)
                yy -= 7.6
            c.setFillColor('black')
        elif a.startswith('*'):
            c.setFont('DJB', FS_ATR)
            t = a[1:]
            c.drawString(x0 + 5, yy, '● ' + t)
            tw = pdfmetrics.stringWidth('● ', 'DJB', FS_ATR)
            c.setLineWidth(0.4)
            c.line(x0 + 5 + tw, yy - 1, x0 + 5 + tw + pdfmetrics.stringWidth(t, 'DJB', FS_ATR), yy - 1)
            yy -= 7.6
        else:
            deriv = a.startswith('~')
            c.setFont('DJI' if deriv else 'DJ', FS_ATR)
            c.drawString(x0 + 5, yy, '○ ' + a.strip('~') + (' (derivado)' if deriv else ''))
            yy -= 7.6


def losango(c, cx, cy, w, h, texto, cor, borda_cor, lw=0.6):
    p = c.beginPath()
    p.moveTo(cx - w / 2, cy)
    p.lineTo(cx, cy + h / 2)
    p.lineTo(cx + w / 2, cy)
    p.lineTo(cx, cy - h / 2)
    p.close()
    c.setFillColor(cor)
    c.setStrokeColor(borda_cor)
    c.setLineWidth(lw)
    c.drawPath(p, fill=1, stroke=1)
    c.setFillColor('black')
    c.setFont('DJ', FS_LOS)
    c.drawCentredString(cx, cy - 2, texto)


def pagina(c, com_atr):
    c.setFillColor('white')
    c.rect(0, 0, W, H, fill=1, stroke=0)
    tit = 'Com atributos' if com_atr else 'Visão geral'
    c.setFillColor('black')
    c.setFont('DJB', 17)
    c.drawString(*P(60, 66), 'Diagrama Entidade-Relacionamento (DER) — ' + tit)
    c.setFont('DJ', 9.5)
    c.setFillColor(CINZA)
    c.drawString(*P(60, 96), "Projeto ERP Petly Club (inspirado na Cobasi e no Sam's Club) · Grupo 7 · "
                             "Versão da entrega final (revisada após a devolutiva, com os ajustes [A2] e [A3])")

    # ligações dos relacionamentos (cardinalidades são escritas por último, por cima de tudo)
    cards = []
    for i, (nome, x, y, regra, (e1, c1), (e2, c2), novo) in enumerate(R):
        for ent, card in ((e1, c1), (e2, c2)):
            pe = borda(('E', ent), P(x, y), com_atr)
            pr = borda(('R', i), centro(ent), com_atr)
            linha(c, pe, pr)
            cards.append((pe, pr, card, DIST_CARD.get((i, ent), 12)))
    for (a, ca), (b, cb) in DIRETAS:
        pa = borda(('E', a), centro(b), com_atr)
        pb = borda(('E', b), centro(a), com_atr)
        linha(c, pa, pb)
        if ca:
            cards.append((pa, pb, ca, 12))
        if cb:
            cards.append((pb, pa, cb, 12))

    for i, (nome, x, y, regra, _, _, novo) in enumerate(R):
        cx, cy = P(x, y)
        w, h = tam_losango(nome)
        losango(c, cx, cy, w, h, nome, LOSANGO_NOVO if novo else LOSANGO,
                BORDA_NOVA if novo else '#222222', 0.9 if novo else 0.6)
        c.setFont('DJI', FS_REGRA)
        c.setFillColor(BORDA_NOVA if novo else CINZA)
        c.drawCentredString(cx, cy - h / 2 - 6, regra)

    for nome in list(E) + list(A):
        desenha_entidade(c, nome, com_atr)
    for pe, pr, card, dist in cards:
        cardinalidade(c, pe, pr, card, dist)

    notas = [
        'Notação de Peter Chen: retângulo = entidade · losango = relacionamento · retângulo com losango = entidade '
        'associativa (resolve um N:N) · em laranja, as entidades criadas após a devolutiva.',
        'Cardinalidade (mínimo, máximo) junto a cada entidade = em quantas ocorrências do relacionamento uma '
        'ocorrência dessa entidade participa (notação do manual). Abaixo de cada losango, a regra que o sustenta.',
        'Em verde, os relacionamentos incluídos na entrega final ([A2] e [A3]): o funcionário da gerência que '
        'autoriza perdas e ajustes de estoque, descontos acima do limite e cancelamentos no caixa.',
    ]
    if com_atr:
        notas.append('Atributos: ● identificador (sublinhado) · ○ atributo simples · (composto) atributo formado '
                     'por partes · (derivado) calculado, não armazenado. Chaves estrangeiras não aparecem no DER.')
    else:
        notas.append('Fornecedor × Produto (N:N, RN09) é representado por COMPRA e ITEM_COMPRA; o lote de cada '
                     'venda (RN20) é registrado em MOVIMENTACAO_ESTOQUE, ligada ao ITEM_PEDIDO e ao LOTE.')
    c.setFillColor('black')
    c.setFont('DJ', 8)
    for k, t in enumerate(notas):
        c.drawString(*P(60, 1314 + k * 22), t)
    c.showPage()


def gerar(destino=os.path.join(AQUI, 'DER.pdf')):
    c = canvas.Canvas(destino, pagesize=(W, H))
    c.setTitle('DER — ERP Petly Club')
    c.setAuthor('')
    pagina(c, False)
    pagina(c, True)
    c.save()
    return destino


if __name__ == '__main__':
    print(gerar())
