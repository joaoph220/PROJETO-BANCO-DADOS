-- =====================================================================
-- PARTE 1 - UPDATE
-- Regra: todo UPDATE tem WHERE. Sem ele, o comando altera a tabela inteira.
-- =====================================================================

-- ---------------------------------------------------------------------
-- UPDATE 1: reajuste de preco por categoria
-- Situacao: o fornecedor repassou 5% de aumento nos detergentes, e o
-- preco de venda precisa acompanhar. A categoria e achada pelo nome,
-- com uma subconsulta, sem digitar o id.
-- Esperado: 2 linhas (Perol Solar 40 5L e Master Star 5L).
-- ---------------------------------------------------------------------
-- Antes:
SELECT id_produto, nome, preco_venda
  FROM produto
 WHERE id_categoria = (SELECT id_categoria FROM categoria WHERE nome = 'Detergente')
 ORDER BY id_produto;

UPDATE produto
   SET preco_venda = ROUND(preco_venda * 1.05, 2)   -- 5% a mais, com 2 casas decimais
 WHERE id_categoria = (SELECT id_categoria FROM categoria WHERE nome = 'Detergente');

-- Depois (130.00 vira 136.50 e 98.00 vira 102.90):
SELECT id_produto, nome, preco_venda
  FROM produto
 WHERE id_categoria = (SELECT id_categoria FROM categoria WHERE nome = 'Detergente')
 ORDER BY id_produto;

-- ---------------------------------------------------------------------
-- UPDATE 2: ajuste do estoque minimo
-- Situacao: o Saco de Lixo 100L P4 vende bastante, entao o estoque minimo
-- sobe de 10 para 14 para a reposicao ser avisada mais cedo.
-- Esperado: 1 linha.
-- ---------------------------------------------------------------------
-- Antes:
SELECT id_produto, nome, estoque_atual, estoque_minimo
  FROM produto
 WHERE nome = 'Saco de Lixo 100L P4';

UPDATE produto
   SET estoque_minimo = 14
 WHERE nome = 'Saco de Lixo 100L P4';

-- Depois:
SELECT id_produto, nome, estoque_atual, estoque_minimo
  FROM produto
 WHERE nome = 'Saco de Lixo 100L P4';

-- ---------------------------------------------------------------------
-- UPDATE 3: cancelamento de compra aberta
-- Situacao: o pedido aberto com a Inoven foi desfeito. A compra NAO e
-- apagada: muda para CANCELADA, e o historico fica preservado.
-- O WHERE tem status = 'ABERTA' para nunca cancelar uma compra que
-- ja foi recebida.
-- Esperado: 1 linha.
-- ---------------------------------------------------------------------
-- Antes (duas compras abertas: Indaial e Inoven):
SELECT c.id_compra, f.razao_social, c.data, c.status
  FROM compra c
  JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
 WHERE c.status = 'ABERTA'
 ORDER BY c.id_compra;

UPDATE compra
   SET status = 'CANCELADA'
 WHERE status = 'ABERTA'
   AND id_fornecedor = (SELECT id_fornecedor FROM fornecedor WHERE razao_social = 'Inoven');

-- Depois (sobra so a da Indaial):
SELECT c.id_compra, f.razao_social, c.data, c.status
  FROM compra c
  JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
 WHERE c.status = 'ABERTA'
 ORDER BY c.id_compra;

-- ---------------------------------------------------------------------
-- UPDATE 4: exclusao logica de produto
-- Situacao: o Rodo Duplo 45cm deixou de ser vendido. Em vez de apagar
-- o produto (o que poderia quebrar o historico de compras e
-- movimentacoes por causa das chaves estrangeiras), ele e marcado
-- como inativo (ativo = 'N').
-- Esperado: 1 linha.
-- ---------------------------------------------------------------------
-- Antes:
SELECT id_produto, nome, ativo
  FROM produto
 WHERE nome = 'Rodo Duplo 45cm Sem Cabo';

UPDATE produto
   SET ativo = 'N'
 WHERE nome = 'Rodo Duplo 45cm Sem Cabo';

-- Depois:
SELECT id_produto, nome, ativo
  FROM produto
 WHERE nome = 'Rodo Duplo 45cm Sem Cabo';

-- =====================================================================
-- PARTE 2 - INSERT
-- A carga inicial esta no 02. Aqui ficam dois cadastros novos do dia a dia.
-- =====================================================================

-- ---------------------------------------------------------------------
-- INSERT 1: cadastro de um fornecedor novo
-- O id e gerado sozinho (IDENTITY). telefone e email sao opcionais.
-- Os dados sao ficticios.
-- ---------------------------------------------------------------------
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('Distribuidora Teste', '80000000000001', '(11) 4000-0008', 'contato@teste.example.com');

SELECT id_fornecedor, razao_social, cnpj
  FROM fornecedor
 WHERE razao_social = 'Distribuidora Teste';

-- ---------------------------------------------------------------------
-- INSERT 2: cadastro de um produto novo, sem informar ativo nem
-- estoque_atual. O banco usa os DEFAULTs: ativo = 'S' e estoque_atual = 0.
-- ---------------------------------------------------------------------
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_minimo)
VALUES ('Produto Teste',
        (SELECT id_categoria FROM categoria WHERE nome = 'Descartáveis'),
        10.00,
        5);

SELECT id_produto, nome, ativo, estoque_atual
  FROM produto
 WHERE nome = 'Produto Teste';

-- =====================================================================
-- PARTE 3 - DELETE
-- Com chave estrangeira, se apaga o FILHO antes do PAI.
-- =====================================================================

-- ---------------------------------------------------------------------
-- DELETE 1: remover o produto cadastrado so para teste
-- Situacao: o produto foi cadastrado por engano e nunca teve compra
-- nem movimentacao, entao pode ser apagado sem violar nenhuma FK.
-- Esperado: 1 linha.
-- ---------------------------------------------------------------------
DELETE FROM produto
 WHERE nome = 'Produto Teste';

-- ---------------------------------------------------------------------
-- DELETE 2: remover o fornecedor cadastrado por engano
-- Situacao: nunca teve compra nem produto vinculado.
-- Esperado: 1 linha.
-- ---------------------------------------------------------------------
DELETE FROM fornecedor
 WHERE razao_social = 'Distribuidora Teste';

-- ---------------------------------------------------------------------
-- DELETE 3: apagar uma compra e seus itens
-- Situacao: a compra cancelada da M.A. Plas foi lancada em duplicidade e
-- nao gerou nenhuma movimentacao, entao pode ser apagada.
-- Ordem: primeiro os itens (filho: item_compra), depois a compra (pai).
-- Se a ordem fosse invertida, o Oracle recusaria com erro de chave
-- estrangeira (ORA-02292).
-- A compra cancelada da Inoven (UPDATE 3) NAO e apagada: fica no historico.
-- Esperado: 1 linha em item_compra e 1 linha em compra.
-- ---------------------------------------------------------------------
-- Antes (duas compras canceladas: M.A. Plas e Inoven):
SELECT c.id_compra, f.razao_social, c.data, c.status
  FROM compra c
  JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
 WHERE c.status = 'CANCELADA'
 ORDER BY c.id_compra;

-- 1) apaga os itens da compra cancelada da M.A. Plas
DELETE FROM item_compra
 WHERE id_compra IN (SELECT c.id_compra
                       FROM compra c
                      WHERE c.status = 'CANCELADA'
                        AND c.id_fornecedor = (SELECT id_fornecedor
                                                 FROM fornecedor
                                                WHERE razao_social = 'M.A. Plas'));

-- 2) apaga a compra
DELETE FROM compra
 WHERE status = 'CANCELADA'
   AND id_fornecedor = (SELECT id_fornecedor FROM fornecedor WHERE razao_social = 'M.A. Plas');

-- Depois (sobra so a da Inoven):
SELECT c.id_compra, f.razao_social, c.data, c.status
  FROM compra c
  JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
 WHERE c.status = 'CANCELADA'
 ORDER BY c.id_compra;

-- =====================================================================
-- Confirma as alteracoes acima de forma definitiva.
-- =====================================================================
COMMIT;

-- =====================================================================
-- PARTE 4 - TRANSACAO: UPDATE desfeito com ROLLBACK
-- Situacao: o telefone da Perol foi alterado com um numero errado.
-- Antes de confirmar, percebe-se o erro e a alteracao e desfeita.
-- Observacao: se a ferramenta estiver com autocommit ligado, o ROLLBACK
-- nao desfaz (e so o telefone, que nao afeta nenhuma consulta).
-- =====================================================================
-- Antes:
SELECT id_fornecedor, razao_social, telefone
  FROM fornecedor
 WHERE razao_social = 'Perol';

UPDATE fornecedor
   SET telefone = '(00) 0000-0000'
 WHERE razao_social = 'Perol';

-- Dentro da transacao, o valor novo aparece:
SELECT id_fornecedor, razao_social, telefone
  FROM fornecedor
 WHERE razao_social = 'Perol';

ROLLBACK;

-- Depois do ROLLBACK, o telefone original volta:
SELECT id_fornecedor, razao_social, telefone
  FROM fornecedor
 WHERE razao_social = 'Perol';

-- =====================================================================
-- CONFERENCIA FINAL: linhas por tabela depois de todas as operacoes
-- Esperado: fornecedor 7, produto 25, compra 12, item_compra 36,
--           movimentacao 65
-- =====================================================================
SELECT 'fornecedor' AS tabela, COUNT(*) AS linhas FROM fornecedor
UNION ALL SELECT 'produto', COUNT(*) FROM produto
UNION ALL SELECT 'compra', COUNT(*) FROM compra
UNION ALL SELECT 'item_compra', COUNT(*) FROM item_compra
UNION ALL SELECT 'movimentacao', COUNT(*) FROM movimentacao;
