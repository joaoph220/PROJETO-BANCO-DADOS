-- RN1 e RN2: CNPJ unico e com 14 digitos numericos
-- =====================================================================
-- PASSA: CNPJ novo com 14 digitos
INSERT INTO fornecedor (razao_social, cnpj)
VALUES ('Fornecedor Novo', '90000000000009');

-- DEVE FALHAR (RN1): CNPJ repetido -> ORA-00001 (unique constraint)
INSERT INTO fornecedor (razao_social, cnpj)
VALUES ('Outro Fornecedor', '90000000000009');

-- DEVE FALHAR (RN2): CNPJ com 13 digitos -> ORA-02290 (check ck_fornecedor_cnpj)
INSERT INTO fornecedor (razao_social, cnpj)
VALUES ('CNPJ Curto', '1234567890123');

-- DEVE FALHAR (RN2): CNPJ com letra -> ORA-02290 (check ck_fornecedor_cnpj)
INSERT INTO fornecedor (razao_social, cnpj)
VALUES ('CNPJ Com Letra', '1234567890123A');

ROLLBACK;


-- =====================================================================
-- RN3: nome de categoria unico
-- =====================================================================
-- PASSA
INSERT INTO categoria (nome) VALUES ('Ferramentas');

-- DEVE FALHAR: categoria repetida -> ORA-00001 (unique constraint)
INSERT INTO categoria (nome) VALUES ('Detergente');

ROLLBACK;


-- =====================================================================
-- RN4: precos nao podem ser negativos
-- =====================================================================
-- PASSA
UPDATE produto SET preco_venda = 99.90 WHERE nome = 'Rust 5L';

-- DEVE FALHAR: preco negativo -> ORA-02290 (check ck_produto_preco)
UPDATE produto SET preco_venda = -1 WHERE nome = 'Rust 5L';

ROLLBACK;


-- =====================================================================
-- RN5: quantidade maior que zero
-- =====================================================================
-- PASSA: item novo na compra 1 (produto 4 ainda nao esta nela)
INSERT INTO item_compra (id_compra, id_produto, quantidade, preco_unitario)
VALUES (1, 4, 3, 220.00);

-- DEVE FALHAR: quantidade zero -> ORA-02290 (check ck_ic_qtd)
INSERT INTO item_compra (id_compra, id_produto, quantidade, preco_unitario)
VALUES (1, 5, 0, 106.00);

ROLLBACK;


-- =====================================================================
-- RN6: integridade referencial e campos obrigatorios
-- =====================================================================
-- PASSA: produto com categoria existente
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_minimo)
VALUES ('Produto de Teste',
        (SELECT id_categoria FROM categoria WHERE nome = 'Detergente'),
        10.00, 5);

-- DEVE FALHAR: categoria inexistente -> ORA-02291 (parent key not found)
INSERT INTO produto (nome, id_categoria, preco_venda)
VALUES ('Produto Orfao', 999, 10.00);

-- DEVE FALHAR: nome obrigatorio vazio -> ORA-01400 (cannot insert NULL)
INSERT INTO produto (id_categoria, preco_venda)
VALUES ((SELECT id_categoria FROM categoria WHERE nome = 'Detergente'), 10.00);

-- DEVE FALHAR: categoria com produtos -> ORA-02292 (child record found)
DELETE FROM categoria WHERE nome = 'Detergente';

-- DEVE FALHAR: fornecedor com compras -> ORA-02292 (child record found)
DELETE FROM fornecedor WHERE razao_social = 'Perol';

ROLLBACK;


-- =====================================================================
-- RN7: estoque nunca negativo (CHECK)
-- =====================================================================
-- DEVE FALHAR: estoque negativo -> ORA-02290 (check ck_produto_estoque)
UPDATE produto SET estoque_atual = -1 WHERE nome = 'Rust 5L';

-- DEVE FALHAR: estoque minimo negativo -> ORA-02290 (check ck_produto_estmin)
UPDATE produto SET estoque_minimo = -1 WHERE nome = 'Rust 5L';


-- =====================================================================
-- RN8: trigger de movimentacao (atualiza o estoque e bloqueia saida
-- maior que o saldo). Produto usado: Perol Solar 40 5L (estoque 5).
-- =====================================================================
-- Estoque antes: 5
SELECT nome, estoque_atual FROM produto WHERE nome = 'Perol Solar 40 5L';

-- PASSA: entrada de 10 -> estoque vai a 15
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade)
VALUES ((SELECT id_produto FROM produto WHERE nome = 'Perol Solar 40 5L'),
        'ENTRADA', 'TESTE', 10);
SELECT nome, estoque_atual FROM produto WHERE nome = 'Perol Solar 40 5L';

-- PASSA: saida de 3 -> estoque vai a 12
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade)
VALUES ((SELECT id_produto FROM produto WHERE nome = 'Perol Solar 40 5L'),
        'SAIDA', 'VENDA', 3);
SELECT nome, estoque_atual FROM produto WHERE nome = 'Perol Solar 40 5L';

-- DEVE FALHAR: saida maior que o saldo -> ORA-20001 (Saldo insuficiente)
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade)
VALUES ((SELECT id_produto FROM produto WHERE nome = 'Perol Solar 40 5L'),
        'SAIDA', 'VENDA', 500);

ROLLBACK;
-- Estoque depois do ROLLBACK: volta a 5
SELECT nome, estoque_atual FROM produto WHERE nome = 'Perol Solar 40 5L';


-- =====================================================================
-- RN9: tipo da movimentacao so aceita ENTRADA ou SAIDA
-- =====================================================================
-- DEVE FALHAR: tipo invalido -> ORA-02290 (check ck_mov_tipo)
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade)
VALUES ((SELECT id_produto FROM produto WHERE nome = 'Rust 5L'),
        'AJUSTE', 'TESTE', 1);

ROLLBACK;


-- =====================================================================
-- RN10: status da compra so aceita ABERTA, RECEBIDA ou CANCELADA
-- =====================================================================
-- DEVE FALHAR: status invalido -> ORA-02290 (check ck_compra_status)
UPDATE compra SET status = 'PAGA' WHERE id_compra = 1;

ROLLBACK;


-- =====================================================================
-- FUNCTION fn_situacao_estoque: usada direto em um SELECT
-- CRITICO: estoque <= minimo | ATENCAO: ate 50% acima | OK: acima
-- =====================================================================
SELECT nome,
       estoque_atual,
       estoque_minimo,
       fn_situacao_estoque(id_produto) AS situacao
  FROM produto
 WHERE ativo = 'S'
 ORDER BY situacao, nome;

-- Produto inexistente devolve NULL (sem erro)
SELECT fn_situacao_estoque(9999) AS situacao FROM dual;


-- =====================================================================
-- RN11 e PROCEDURE registrar_compra (cria compra + item + entrada;
-- a trigger atualiza o estoque). ATENCAO: faz COMMIT.
-- Produto usado: Perol Solar 40 5L (estoque 5, CRITICO).
-- =====================================================================
-- Obs.: o PL/SQL nao aceita subconsulta como argumento da procedure
-- (PLS-00405), por isso os ids sao lidos antes com SELECT INTO.

-- DEVE FALHAR: quantidade zero -> ORA-20002 (nada e gravado)
DECLARE
  v_forn fornecedor.id_fornecedor%TYPE;
  v_prod produto.id_produto%TYPE;
BEGIN
  SELECT id_fornecedor INTO v_forn FROM fornecedor WHERE razao_social = 'Perol';
  SELECT id_produto    INTO v_prod FROM produto    WHERE nome = 'Perol Solar 40 5L';
  registrar_compra(v_forn, v_prod, 0, 90.00);
END;
/

-- PASSA: compra de 10 unidades a R$ 90,00
DECLARE
  v_forn fornecedor.id_fornecedor%TYPE;
  v_prod produto.id_produto%TYPE;
BEGIN
  SELECT id_fornecedor INTO v_forn FROM fornecedor WHERE razao_social = 'Perol';
  SELECT id_produto    INTO v_prod FROM produto    WHERE nome = 'Perol Solar 40 5L';
  registrar_compra(v_forn, v_prod, 10, 90.00);
END;
/

-- Resultado: estoque 15 e situacao OK
SELECT nome, estoque_atual, estoque_minimo,
       fn_situacao_estoque(id_produto) AS situacao
  FROM produto
 WHERE nome = 'Perol Solar 40 5L';

-- A compra criada, com item e movimentacao de entrada
SELECT c.id_compra, c.status, ic.quantidade, ic.preco_unitario, m.tipo, m.motivo
  FROM compra c
  JOIN item_compra  ic ON ic.id_compra = c.id_compra
  JOIN movimentacao m  ON m.id_compra  = c.id_compra
                      AND m.id_produto = ic.id_produto
 WHERE c.id_compra = (SELECT MAX(id_compra) FROM compra);