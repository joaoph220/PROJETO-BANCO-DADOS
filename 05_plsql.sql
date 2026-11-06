-- =====================================================================
-- 05_plsql.sql
-- Objetos PL/SQL do projeto EstoqueFacil
--   1) trg_movimentacao_estoque : trigger (RN7 e RN8)
--   2) fn_situacao_estoque      : function
--   3) registrar_compra         : procedure (RN11)
-- Executar como SCRIPT. Cada objeto termina com uma barra "/" sozinha.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1) TRIGGER: mantem produto.estoque_atual a cada movimentacao
--    - ENTRADA soma ao estoque
--    - SAIDA subtrai, mas so se houver saldo suficiente (RN8)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_movimentacao_estoque
BEFORE INSERT ON movimentacao
FOR EACH ROW
DECLARE
    v_saldo produto.estoque_atual%TYPE;
BEGIN
    -- Le o saldo atual e trava a linha do produto ate o fim da transacao
    SELECT estoque_atual
      INTO v_saldo
      FROM produto
     WHERE id_produto = :NEW.id_produto
       FOR UPDATE;

    IF :NEW.tipo = 'ENTRADA' THEN
        UPDATE produto
           SET estoque_atual = estoque_atual + :NEW.quantidade
         WHERE id_produto = :NEW.id_produto;

    ELSIF :NEW.tipo = 'SAIDA' THEN
        IF :NEW.quantidade > v_saldo THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Saldo insuficiente: estoque atual = ' || v_saldo ||
                ', saida solicitada = ' || :NEW.quantidade);
        END IF;

        UPDATE produto
           SET estoque_atual = estoque_atual - :NEW.quantidade
         WHERE id_produto = :NEW.id_produto;
    END IF;
END;
/


-- ---------------------------------------------------------------------
-- 2) FUNCTION: situacao do estoque de um produto
--    CRITICO : estoque_atual <= estoque_minimo
--    ATENCAO : estoque_atual ate 50% acima do minimo
--    OK      : acima disso
--    Retorna NULL se o produto nao existir.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_situacao_estoque (
    p_id_produto IN produto.id_produto%TYPE
) RETURN VARCHAR2
IS
    v_atual produto.estoque_atual%TYPE;
    v_min   produto.estoque_minimo%TYPE;
BEGIN
    SELECT estoque_atual, estoque_minimo
      INTO v_atual, v_min
      FROM produto
     WHERE id_produto = p_id_produto;

    IF v_atual <= v_min THEN
        RETURN 'CRITICO';
    ELSIF v_atual <= v_min * 1.5 THEN
        RETURN 'ATENCAO';
    ELSE
        RETURN 'OK';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/


-- ---------------------------------------------------------------------
-- 3) PROCEDURE: registra uma compra recebida de um produto
--    Cria a compra, o item e a movimentacao de ENTRADA.
--    A trigger atualiza o estoque. Se algo falhar, desfaz tudo.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE registrar_compra (
    p_id_fornecedor  IN fornecedor.id_fornecedor%TYPE,
    p_id_produto     IN produto.id_produto%TYPE,
    p_quantidade     IN item_compra.quantidade%TYPE,
    p_preco_unitario IN item_compra.preco_unitario%TYPE
)
IS
    v_id_compra compra.id_compra%TYPE;
BEGIN
    IF p_quantidade <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'A quantidade deve ser maior que zero.');
    END IF;

    INSERT INTO compra (id_fornecedor, status)
    VALUES (p_id_fornecedor, 'RECEBIDA')
    RETURNING id_compra INTO v_id_compra;

    INSERT INTO item_compra (id_compra, id_produto, quantidade, preco_unitario)
    VALUES (v_id_compra, p_id_produto, p_quantidade, p_preco_unitario);

    INSERT INTO movimentacao (id_produto, tipo, motivo, quantidade, id_compra)
    VALUES (p_id_produto, 'ENTRADA', 'COMPRA', p_quantidade, v_id_compra);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/