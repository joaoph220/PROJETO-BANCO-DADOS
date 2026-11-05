-- Protecao: se as tabelas ja tem dados, os ids nao vao bater.
DECLARE
  v_qtd NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_qtd FROM categoria;
  IF v_qtd > 0 THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Tabelas ja possuem dados. Execute o 01_ddl_estrutura.sql antes do 02.');
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- CATEGORIA  (ids 1 a 7)
-- ---------------------------------------------------------------------
INSERT INTO categoria (nome) VALUES ('Descartáveis');            -- 1
INSERT INTO categoria (nome) VALUES ('Acessórios de Limpeza');   -- 2
INSERT INTO categoria (nome) VALUES ('Desengordurante');         -- 3
INSERT INTO categoria (nome) VALUES ('Desincrustante');          -- 4
INSERT INTO categoria (nome) VALUES ('Desinfetante');            -- 5
INSERT INTO categoria (nome) VALUES ('Detergente');              -- 6
INSERT INTO categoria (nome) VALUES ('EPI');                     -- 7

-- ---------------------------------------------------------------------
-- FORNECEDOR  (ids 1 a 7). CNPJ, telefone e e-mail sao FICTICIOS.
-- ---------------------------------------------------------------------
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('Perol',      '10000000000001', '(11) 4000-0001', 'contato@perol.example.com');      -- 1
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('Ecomaster',  '20000000000001', '(11) 4000-0002', 'contato@ecomaster.example.com');  -- 2
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('Indaial',    '30000000000001', '(11) 4000-0003', 'contato@indaial.example.com');    -- 3
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('Goedert',    '40000000000001', '(11) 4000-0004', 'contato@goedert.example.com');    -- 4
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('M.A. Plas',  '50000000000001', '(11) 4000-0005', 'contato@maplas.example.com');     -- 5
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('Inoven',     '60000000000001', '(11) 4000-0006', 'contato@inoven.example.com');     -- 6
INSERT INTO fornecedor (razao_social, cnpj, telefone, email)
VALUES ('Plast Rib',  '70000000000001', '(11) 4000-0007', 'contato@plastrib.example.com');   -- 7

-- ---------------------------------------------------------------------
-- PRODUTO  (ids 1 a 25)
-- colunas: nome, id_categoria, preco_venda, estoque_atual, estoque_minimo
-- (ativo usa o DEFAULT 'S'; estoque_minimo foi definido pelo grupo)
-- ---------------------------------------------------------------------
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Perol Solar 40 5L', 6, 130.00, 5, 6);                                        -- 1
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Rust 5L', 4, 98.00, 8, 4);                                                   -- 2
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('LR 400 5L', 4, 120.00, 6, 4);                                                -- 3
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Master Desintegrator 5KG', 4, 315.00, 4, 3);                                 -- 4
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Master Kitchen 5L', 3, 155.00, 6, 4);                                       -- 5
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Master Star 5L', 6, 98.00, 5, 6);                                            -- 6
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Master Float 5L', 3, 130.00, 5, 4);                                          -- 7
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Pratiko Lavanda 5L', 5, 55.00, 7, 8);                                        -- 8
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Master Bac Floral 5L', 5, 72.00, 7, 6);                                      -- 9
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Saco de Lixo 100L P4', 1, 63.90, 9, 10);                                     -- 10
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Saco de Lixo 60L Reforçado', 1, 48.90, 12, 10);                              -- 11
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Saco de Lixo 200L P6', 1, 103.00, 10, 8);                                    -- 12
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Copo Transparente 180ml caixa 2500un', 1, 183.00, 6, 4);                     -- 13
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Papel Higiênico 30m Folha Dupla Fardo 16x4 Ness', 1, 145.00, 7, 8);          -- 14
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Papel Higiênico Cai Cai Caixa 10000 Folha Simples', 1, 97.00, 5, 6);          -- 15
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Papel Higiênico Cai Cai Caixa 8000 Folha Dupla', 1, 126.00, 7, 6);            -- 16
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Papel Higiênico Rolão 300m Fardo 8 Rolos', 1, 109.00, 10, 6);                -- 17
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Papel Higiênico Fardo 64 Rolos Folha Dupla', 1, 128.00, 9, 6);                -- 18
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Cabo de Alumínio 1,40m com Ponteira', 2, 22.50, 11, 10);                      -- 19
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Rodo Duplo 55cm Sem Cabo', 2, 38.90, 7, 6);                                  -- 20
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Rodo Duplo 45cm Sem Cabo', 2, 28.60, 0, 4);                                  -- 21
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Vassoura Mult Plástica Noviça', 2, 26.25, 10, 10);                            -- 22
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Luva de Vinil Sem Pó TAM G Caixa 10x100', 7, 215.00, 3, 4);                  -- 23
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Luva de Vinil Sem Pó TAM M Caixa 10x100', 7, 215.00, 6, 4);                  -- 24
INSERT INTO produto (nome, id_categoria, preco_venda, estoque_atual, estoque_minimo) VALUES ('Touca Sanfonada Pacote 100un', 7, 13.50, 8, 10);                             -- 25

-- ---------------------------------------------------------------------
-- PRODUTO_FORNECEDOR: o que cada fornecedor vende, preco de referencia
-- (custo estimado) e prazo de entrega em dias.
-- colunas: id_produto, id_fornecedor, preco_referencia, prazo_entrega
-- ---------------------------------------------------------------------
-- Perol (1)
INSERT INTO produto_fornecedor VALUES (1, 1, 91.00, 3);
INSERT INTO produto_fornecedor VALUES (2, 1, 68.00, 3);
INSERT INTO produto_fornecedor VALUES (3, 1, 84.00, 3);
-- Ecomaster (2)
INSERT INTO produto_fornecedor VALUES (4, 2, 220.00, 5);
INSERT INTO produto_fornecedor VALUES (5, 2, 108.00, 5);
INSERT INTO produto_fornecedor VALUES (6, 2, 68.00, 5);
INSERT INTO produto_fornecedor VALUES (7, 2, 91.00, 5);
INSERT INTO produto_fornecedor VALUES (8, 2, 38.00, 5);
INSERT INTO produto_fornecedor VALUES (9, 2, 50.00, 5);
-- Indaial (3)
INSERT INTO produto_fornecedor VALUES (14, 3, 101.00, 4);
INSERT INTO produto_fornecedor VALUES (15, 3, 68.00, 4);
INSERT INTO produto_fornecedor VALUES (16, 3, 88.00, 4);
-- Goedert (4)
INSERT INTO produto_fornecedor VALUES (17, 4, 76.00, 5);
INSERT INTO produto_fornecedor VALUES (18, 4, 90.00, 5);
INSERT INTO produto_fornecedor VALUES (19, 4, 15.00, 5);
INSERT INTO produto_fornecedor VALUES (20, 4, 27.00, 5);
INSERT INTO produto_fornecedor VALUES (21, 4, 20.00, 5);
INSERT INTO produto_fornecedor VALUES (22, 4, 18.00, 5);
-- M.A. Plas (5)
INSERT INTO produto_fornecedor VALUES (10, 5, 44.00, 7);
INSERT INTO produto_fornecedor VALUES (11, 5, 34.00, 7);
INSERT INTO produto_fornecedor VALUES (12, 5, 72.00, 7);
-- Inoven (6)
INSERT INTO produto_fornecedor VALUES (23, 6, 150.00, 6);
INSERT INTO produto_fornecedor VALUES (24, 6, 150.00, 6);
INSERT INTO produto_fornecedor VALUES (25, 6, 9.00, 6);
-- Plast Rib (7)
INSERT INTO produto_fornecedor VALUES (13, 7, 128.00, 7);
-- Produtos com mais de um fornecedor (exemplo do relacionamento N:M)
INSERT INTO produto_fornecedor VALUES (13, 5, 132.00, 10);   -- copo tambem na M.A. Plas
INSERT INTO produto_fornecedor VALUES (17, 3, 79.00, 4);     -- rolao tambem na Indaial
INSERT INTO produto_fornecedor VALUES (18, 3, 93.00, 4);     -- fardo 64 tambem na Indaial

-- ---------------------------------------------------------------------
-- COMPRA  (ids 1 a 13, na ordem abaixo)
-- colunas: id_fornecedor, data, status
-- ---------------------------------------------------------------------
INSERT INTO compra (id_fornecedor, data, status) VALUES (1, DATE '2026-08-04', 'RECEBIDA');    -- 1  Perol
INSERT INTO compra (id_fornecedor, data, status) VALUES (2, DATE '2026-08-06', 'RECEBIDA');    -- 2  Ecomaster
INSERT INTO compra (id_fornecedor, data, status) VALUES (5, DATE '2026-08-11', 'RECEBIDA');    -- 3  M.A. Plas
INSERT INTO compra (id_fornecedor, data, status) VALUES (3, DATE '2026-08-13', 'RECEBIDA');    -- 4  Indaial
INSERT INTO compra (id_fornecedor, data, status) VALUES (4, DATE '2026-08-20', 'RECEBIDA');    -- 5  Goedert
INSERT INTO compra (id_fornecedor, data, status) VALUES (6, DATE '2026-08-25', 'RECEBIDA');    -- 6  Inoven
INSERT INTO compra (id_fornecedor, data, status) VALUES (7, DATE '2026-09-02', 'RECEBIDA');    -- 7  Plast Rib
INSERT INTO compra (id_fornecedor, data, status) VALUES (5, DATE '2026-09-10', 'CANCELADA');   -- 8  M.A. Plas
INSERT INTO compra (id_fornecedor, data, status) VALUES (1, DATE '2026-09-15', 'RECEBIDA');    -- 9  Perol
INSERT INTO compra (id_fornecedor, data, status) VALUES (2, DATE '2026-09-22', 'RECEBIDA');    -- 10 Ecomaster
INSERT INTO compra (id_fornecedor, data, status) VALUES (4, DATE '2026-10-06', 'RECEBIDA');    -- 11 Goedert
INSERT INTO compra (id_fornecedor, data, status) VALUES (3, DATE '2026-10-20', 'ABERTA');      -- 12 Indaial
INSERT INTO compra (id_fornecedor, data, status) VALUES (6, DATE '2026-10-27', 'ABERTA');      -- 13 Inoven

-- ---------------------------------------------------------------------
-- ITEM_COMPRA: colunas id_compra, id_produto, quantidade, preco_unitario
-- (preco_unitario = preco efetivamente pago naquela compra)
-- ---------------------------------------------------------------------
-- Compra 1 (Perol)
INSERT INTO item_compra VALUES (1, 1, 12, 88.00);
INSERT INTO item_compra VALUES (1, 2, 8, 66.00);
INSERT INTO item_compra VALUES (1, 3, 6, 82.00);
-- Compra 2 (Ecomaster)
INSERT INTO item_compra VALUES (2, 4, 4, 220.00);
INSERT INTO item_compra VALUES (2, 5, 6, 106.00);
INSERT INTO item_compra VALUES (2, 6, 10, 66.00);
INSERT INTO item_compra VALUES (2, 8, 12, 37.00);
INSERT INTO item_compra VALUES (2, 9, 8, 49.00);
-- Compra 3 (M.A. Plas)
INSERT INTO item_compra VALUES (3, 10, 20, 43.00);
INSERT INTO item_compra VALUES (3, 11, 20, 33.00);
INSERT INTO item_compra VALUES (3, 12, 10, 71.00);
-- Compra 4 (Indaial)
INSERT INTO item_compra VALUES (4, 14, 12, 100.00);
INSERT INTO item_compra VALUES (4, 15, 8, 67.00);
INSERT INTO item_compra VALUES (4, 16, 8, 87.00);
-- Compra 5 (Goedert)
INSERT INTO item_compra VALUES (5, 17, 10, 75.00);
INSERT INTO item_compra VALUES (5, 18, 10, 89.00);
INSERT INTO item_compra VALUES (5, 19, 20, 15.00);
INSERT INTO item_compra VALUES (5, 20, 8, 27.00);
INSERT INTO item_compra VALUES (5, 22, 15, 17.50);
-- Compra 6 (Inoven)
INSERT INTO item_compra VALUES (6, 23, 6, 148.00);
INSERT INTO item_compra VALUES (6, 24, 6, 148.00);
INSERT INTO item_compra VALUES (6, 25, 20, 9.00);
-- Compra 7 (Plast Rib)
INSERT INTO item_compra VALUES (7, 13, 6, 127.00);
-- Compra 8 (M.A. Plas, cancelada)
INSERT INTO item_compra VALUES (8, 10, 30, 44.00);
-- Compra 9 (Perol)
INSERT INTO item_compra VALUES (9, 1, 10, 91.00);
INSERT INTO item_compra VALUES (9, 2, 6, 68.00);
-- Compra 10 (Ecomaster)
INSERT INTO item_compra VALUES (10, 5, 4, 108.00);
INSERT INTO item_compra VALUES (10, 6, 12, 68.00);
INSERT INTO item_compra VALUES (10, 7, 6, 91.00);
INSERT INTO item_compra VALUES (10, 8, 12, 38.00);
-- Compra 11 (Goedert)
INSERT INTO item_compra VALUES (11, 17, 8, 76.00);
INSERT INTO item_compra VALUES (11, 18, 8, 90.00);
INSERT INTO item_compra VALUES (11, 22, 10, 18.00);
-- Compra 12 (Indaial, aberta)
INSERT INTO item_compra VALUES (12, 14, 12, 101.00);
INSERT INTO item_compra VALUES (12, 15, 10, 68.00);
-- Compra 13 (Inoven, aberta)
INSERT INTO item_compra VALUES (13, 23, 6, 150.00);
INSERT INTO item_compra VALUES (13, 25, 20, 9.00);

-- ---------------------------------------------------------------------
-- MOVIMENTACAO
-- colunas: id_produto, tipo, motivo, quantidade, data, id_compra
-- ENTRADAS: so das compras RECEBIDAS (ligadas pelo id_compra).
-- ---------------------------------------------------------------------
-- Compra 1
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (1, 'ENTRADA', 'COMPRA', 12, DATE '2026-08-07', 1);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (2, 'ENTRADA', 'COMPRA', 8, DATE '2026-08-07', 1);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (3, 'ENTRADA', 'COMPRA', 6, DATE '2026-08-07', 1);
-- Compra 2
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (4, 'ENTRADA', 'COMPRA', 4, DATE '2026-08-11', 2);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (5, 'ENTRADA', 'COMPRA', 6, DATE '2026-08-11', 2);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (6, 'ENTRADA', 'COMPRA', 10, DATE '2026-08-11', 2);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (8, 'ENTRADA', 'COMPRA', 12, DATE '2026-08-11', 2);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (9, 'ENTRADA', 'COMPRA', 8, DATE '2026-08-11', 2);
-- Compra 3
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (10, 'ENTRADA', 'COMPRA', 20, DATE '2026-08-18', 3);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (11, 'ENTRADA', 'COMPRA', 20, DATE '2026-08-18', 3);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (12, 'ENTRADA', 'COMPRA', 10, DATE '2026-08-18', 3);
-- Compra 4
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (14, 'ENTRADA', 'COMPRA', 12, DATE '2026-08-18', 4);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (15, 'ENTRADA', 'COMPRA', 8, DATE '2026-08-18', 4);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (16, 'ENTRADA', 'COMPRA', 8, DATE '2026-08-18', 4);
-- Compra 5
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (17, 'ENTRADA', 'COMPRA', 10, DATE '2026-08-26', 5);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (18, 'ENTRADA', 'COMPRA', 10, DATE '2026-08-26', 5);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (19, 'ENTRADA', 'COMPRA', 20, DATE '2026-08-26', 5);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (20, 'ENTRADA', 'COMPRA', 8, DATE '2026-08-26', 5);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (22, 'ENTRADA', 'COMPRA', 15, DATE '2026-08-26', 5);
-- Compra 6
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (23, 'ENTRADA', 'COMPRA', 6, DATE '2026-09-01', 6);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (24, 'ENTRADA', 'COMPRA', 6, DATE '2026-09-01', 6);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (25, 'ENTRADA', 'COMPRA', 20, DATE '2026-09-01', 6);
-- Compra 7
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (13, 'ENTRADA', 'COMPRA', 6, DATE '2026-09-09', 7);
-- Compra 9
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (1, 'ENTRADA', 'COMPRA', 10, DATE '2026-09-18', 9);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (2, 'ENTRADA', 'COMPRA', 6, DATE '2026-09-18', 9);
-- Compra 10
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (5, 'ENTRADA', 'COMPRA', 4, DATE '2026-09-28', 10);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (6, 'ENTRADA', 'COMPRA', 12, DATE '2026-09-28', 10);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (7, 'ENTRADA', 'COMPRA', 6, DATE '2026-09-28', 10);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (8, 'ENTRADA', 'COMPRA', 12, DATE '2026-09-28', 10);
-- Compra 11
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (17, 'ENTRADA', 'COMPRA', 8, DATE '2026-10-11', 11);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (18, 'ENTRADA', 'COMPRA', 8, DATE '2026-10-11', 11);
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data, id_compra) VALUES (22, 'ENTRADA', 'COMPRA', 10, DATE '2026-10-11', 11);

-- SAIDAS por venda (sem id_compra, que fica NULL)
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (19, 'SAIDA', 'VENDA', 5, DATE '2026-09-08');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (1, 'SAIDA', 'VENDA', 11, DATE '2026-09-05');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (2, 'SAIDA', 'VENDA', 5, DATE '2026-09-12');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (9, 'SAIDA', 'VENDA', 1, DATE '2026-09-14');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (6, 'SAIDA', 'VENDA', 10, DATE '2026-09-15');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (22, 'SAIDA', 'VENDA', 8, DATE '2026-09-15');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (8, 'SAIDA', 'VENDA', 12, DATE '2026-09-20');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (10, 'SAIDA', 'VENDA', 6, DATE '2026-09-20');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (25, 'SAIDA', 'VENDA', 6, DATE '2026-09-20');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (17, 'SAIDA', 'VENDA', 5, DATE '2026-09-24');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (11, 'SAIDA', 'VENDA', 5, DATE '2026-09-25');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (18, 'SAIDA', 'VENDA', 5, DATE '2026-09-26');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (14, 'SAIDA', 'VENDA', 3, DATE '2026-09-30');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (5, 'SAIDA', 'VENDA', 4, DATE '2026-10-05');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (15, 'SAIDA', 'VENDA', 3, DATE '2026-10-06');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (20, 'SAIDA', 'VENDA', 1, DATE '2026-10-09');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (1, 'SAIDA', 'VENDA', 6, DATE '2026-10-10');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (2, 'SAIDA', 'VENDA', 1, DATE '2026-10-10');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (6, 'SAIDA', 'VENDA', 7, DATE '2026-10-12');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (7, 'SAIDA', 'VENDA', 1, DATE '2026-10-12');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (17, 'SAIDA', 'VENDA', 3, DATE '2026-10-13');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (16, 'SAIDA', 'VENDA', 1, DATE '2026-10-14');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (23, 'SAIDA', 'VENDA', 3, DATE '2026-10-14');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (8, 'SAIDA', 'VENDA', 5, DATE '2026-10-15');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (18, 'SAIDA', 'VENDA', 4, DATE '2026-10-15');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (22, 'SAIDA', 'VENDA', 7, DATE '2026-10-16');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (10, 'SAIDA', 'VENDA', 5, DATE '2026-10-18');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (25, 'SAIDA', 'VENDA', 5, DATE '2026-10-21');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (11, 'SAIDA', 'VENDA', 3, DATE '2026-10-22');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (19, 'SAIDA', 'VENDA', 3, DATE '2026-10-23');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (14, 'SAIDA', 'VENDA', 2, DATE '2026-10-25');

-- SAIDAS por ajuste de inventario (contagem fisica)
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (25, 'SAIDA', 'AJUSTE', 1, DATE '2026-10-29');
INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, data) VALUES (19, 'SAIDA', 'AJUSTE', 1, DATE '2026-10-30');

COMMIT;

-- ---------------------------------------------------------------------
-- CONFERENCIA 1: quantidade de linhas por tabela
-- Esperado: categoria 7, fornecedor 7, produto 25, produto_fornecedor 28,
--           compra 13, item_compra 37, movimentacao 65
-- ---------------------------------------------------------------------
SELECT 'categoria' AS tabela, COUNT(*) AS linhas FROM categoria
UNION ALL SELECT 'fornecedor', COUNT(*) FROM fornecedor
UNION ALL SELECT 'produto', COUNT(*) FROM produto
UNION ALL SELECT 'produto_fornecedor', COUNT(*) FROM produto_fornecedor
UNION ALL SELECT 'compra', COUNT(*) FROM compra
UNION ALL SELECT 'item_compra', COUNT(*) FROM item_compra
UNION ALL SELECT 'movimentacao', COUNT(*) FROM movimentacao;

-- ---------------------------------------------------------------------
-- CONFERENCIA 2: estoque_atual = entradas - saidas.
-- Esperado: nenhuma linha ("no rows selected").
-- ---------------------------------------------------------------------
SELECT p.id_produto, p.nome, p.estoque_atual,
       NVL(SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.quantidade ELSE -m.quantidade END), 0) AS saldo_movimentacoes
  FROM produto p
  LEFT JOIN movimentacao m ON m.id_produto = p.id_produto
 GROUP BY p.id_produto, p.nome, p.estoque_atual
HAVING p.estoque_atual <> NVL(SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.quantidade ELSE -m.quantidade END), 0);
