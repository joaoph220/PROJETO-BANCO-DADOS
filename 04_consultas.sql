-- ---------------------------------------------------------------------
-- CONSULTA 1: SELECT simples com filtro e ordenacao
-- PERGUNTA DE NEGOCIO: Quais produtos ativos custam mais de R$ 20,
-- do mais caro ao mais barato?
-- ---------------------------------------------------------------------
SELECT nome,
       preco_venda,
       estoque_atual
  FROM produto
 WHERE ativo = 'S'
   AND preco_venda > 20
 ORDER BY preco_venda DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 2: JOIN entre duas tabelas
-- PERGUNTA DE NEGOCIO: Qual o nome e a categoria de cada produto?
-- ---------------------------------------------------------------------
SELECT c.nome AS categoria,
       p.nome AS produto,
       p.preco_venda
  FROM produto p
  JOIN categoria c ON c.id_categoria = p.id_categoria
 ORDER BY c.nome, p.nome;


-- ---------------------------------------------------------------------
-- CONSULTA 3: JOIN de tres tabelas
-- PERGUNTA DE NEGOCIO: Quais produtos cada fornecedor vende, a que
-- preco de referencia e em quantos dias entrega?
-- ---------------------------------------------------------------------
SELECT f.razao_social   AS fornecedor,
       p.nome           AS produto,
       pf.preco_referencia,
       pf.prazo_entrega AS prazo_dias
  FROM produto_fornecedor pf
  JOIN fornecedor f ON f.id_fornecedor = pf.id_fornecedor
  JOIN produto    p ON p.id_produto    = pf.id_produto
 ORDER BY f.razao_social, p.nome;


-- ---------------------------------------------------------------------
-- CONSULTA 4: agregacao com GROUP BY
-- PERGUNTA DE NEGOCIO: Quanto gastei com cada fornecedor e quantas
-- compras fiz com ele?
-- ---------------------------------------------------------------------
SELECT f.razao_social                          AS fornecedor,
       COUNT(DISTINCT c.id_compra)             AS qtd_compras,
       SUM(ic.quantidade * ic.preco_unitario)  AS total_gasto
  FROM compra c
  JOIN item_compra ic ON ic.id_compra    = c.id_compra
  JOIN fornecedor  f  ON f.id_fornecedor = c.id_fornecedor
 WHERE c.status = 'RECEBIDA'
 GROUP BY f.razao_social
 ORDER BY total_gasto DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 5: GROUP BY com HAVING
-- PERGUNTA DE NEGOCIO: Quais categorias concentram os maiores gastos,
-- acima de R$ 3.000 em compras recebidas?
-- (Com os dados da carga, so Descartaveis e Detergente passam do corte.
--  Com R$ 1.000, quase todas passariam e o HAVING nao mostraria nada.)
-- ---------------------------------------------------------------------
SELECT cat.nome                                AS categoria,
       SUM(ic.quantidade * ic.preco_unitario)  AS total_gasto
  FROM compra c
  JOIN item_compra ic  ON ic.id_compra      = c.id_compra
  JOIN produto     p   ON p.id_produto      = ic.id_produto
  JOIN categoria   cat ON cat.id_categoria  = p.id_categoria
 WHERE c.status = 'RECEBIDA'
 GROUP BY cat.nome
HAVING SUM(ic.quantidade * ic.preco_unitario) > 3000
 ORDER BY total_gasto DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 6: subconsulta (NOT EXISTS)
-- PERGUNTA DE NEGOCIO: Quais produtos ativos nunca tiveram saida?
-- (estoque parado: candidatos a promocao ou a sair do catalogo)
-- ---------------------------------------------------------------------
SELECT p.nome,
       p.estoque_atual,
       p.preco_venda
  FROM produto p
 WHERE p.ativo = 'S'
   AND NOT EXISTS (SELECT 1
                     FROM movimentacao m
                    WHERE m.id_produto = p.id_produto
                      AND m.tipo = 'SAIDA')
 ORDER BY p.nome;

-- CONSULTA 6B: subconsulta escalar (media)
-- PERGUNTA DE NEGOCIO: Quais produtos estao com estoque abaixo da
-- media geral de estoque da loja?
SELECT nome,
       estoque_atual
  FROM produto
 WHERE estoque_atual < (SELECT AVG(estoque_atual) FROM produto)
 ORDER BY estoque_atual;


-- ---------------------------------------------------------------------
-- CONSULTA 7: UNION
-- PERGUNTA DE NEGOCIO: Qual o historico unificado de cada produto,
-- com as entradas vindas de compras recebidas e as saidas (venda ou
-- ajuste de inventario), em ordem cronologica?
-- Para ver um produto so, acrescentar nos dois SELECTs:
--   AND p.nome = 'NOME DO PRODUTO'
-- ---------------------------------------------------------------------
SELECT p.nome           AS produto,
       c.data           AS data_evento,
       'ENTRADA'        AS tipo_evento,
       f.razao_social   AS origem,
       ic.quantidade    AS quantidade
  FROM item_compra ic
  JOIN compra     c ON c.id_compra     = ic.id_compra
  JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
  JOIN produto    p ON p.id_produto    = ic.id_produto
 WHERE c.status = 'RECEBIDA'
UNION
SELECT p.nome,
       m.data,
       'SAIDA',
       m.motivo,
       m.quantidade
  FROM movimentacao m
  JOIN produto p ON p.id_produto = m.id_produto
 WHERE m.tipo = 'SAIDA'
 ORDER BY produto, data_evento;


-- ---------------------------------------------------------------------
-- CONSULTA 8: consulta de reposicao (a mais importante para o usuario)
-- Combina JOIN, LEFT JOIN, subconsulta correlacionada e ordenacao.
-- PERGUNTA DE NEGOCIO: O que preciso comprar agora, de qual fornecedor
-- (o de menor preco de referencia) e em quanto tempo ele entrega?
-- Produtos sem fornecedor cadastrado aparecem com o fornecedor vazio.
-- ---------------------------------------------------------------------
SELECT p.nome              AS produto,
       cat.nome            AS categoria,
       p.estoque_atual,
       p.estoque_minimo,
       f.razao_social      AS fornecedor_sugerido,
       pf.preco_referencia,
       pf.prazo_entrega    AS prazo_dias
  FROM produto p
  JOIN categoria cat ON cat.id_categoria = p.id_categoria
  LEFT JOIN produto_fornecedor pf ON pf.id_produto = p.id_produto
  LEFT JOIN fornecedor f ON f.id_fornecedor = pf.id_fornecedor
 WHERE p.ativo = 'S'
   AND p.estoque_atual <= p.estoque_minimo
   AND (pf.id_produto IS NULL
        OR pf.preco_referencia = (SELECT MIN(pf2.preco_referencia)
                                    FROM produto_fornecedor pf2
                                   WHERE pf2.id_produto = p.id_produto))
 ORDER BY (p.estoque_minimo - p.estoque_atual) DESC, p.nome;


-- ---------------------------------------------------------------------
-- CONSULTA 9: compras em aberto
-- Combina JOIN, GROUP BY e funcoes de agregacao.
-- PERGUNTA DE NEGOCIO: Quais compras estao abertas (ainda nao
-- recebidas), com qual fornecedor, quantos itens e qual o valor previsto?
-- ---------------------------------------------------------------------
SELECT c.id_compra,
       f.razao_social                          AS fornecedor,
       c.data                                  AS data_pedido,
       COUNT(*)                                AS qtd_itens,
       SUM(ic.quantidade * ic.preco_unitario)  AS valor_previsto
  FROM compra c
  JOIN fornecedor  f  ON f.id_fornecedor = c.id_fornecedor
  JOIN item_compra ic ON ic.id_compra    = c.id_compra
 WHERE c.status = 'ABERTA'
 GROUP BY c.id_compra, f.razao_social, c.data
 ORDER BY c.data;