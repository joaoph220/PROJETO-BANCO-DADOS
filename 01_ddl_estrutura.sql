-- Reexecutável: apaga na ordem inversa das dependências
DROP TABLE movimentacao CASCADE CONSTRAINTS;
DROP TABLE item_compra CASCADE CONSTRAINTS;
DROP TABLE compra CASCADE CONSTRAINTS;
DROP TABLE produto_fornecedor CASCADE CONSTRAINTS;
DROP TABLE produto CASCADE CONSTRAINTS;
DROP TABLE fornecedor CASCADE CONSTRAINTS;
DROP TABLE categoria CASCADE CONSTRAINTS;

CREATE TABLE categoria (
    id_categoria  NUMBER GENERATED ALWAYS AS IDENTITY,
    nome          VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
);

CREATE TABLE fornecedor (
    id_fornecedor NUMBER GENERATED ALWAYS AS IDENTITY,
    razao_social  VARCHAR2(100) NOT NULL,
    cnpj          CHAR(14) NOT NULL,
    telefone      VARCHAR2(15),
    email         VARCHAR2(100),
    CONSTRAINT pk_fornecedor PRIMARY KEY (id_fornecedor),
    CONSTRAINT uq_fornecedor_cnpj UNIQUE (cnpj),
    CONSTRAINT ck_fornecedor_cnpj CHECK (LENGTH(cnpj) = 14)
);

CREATE TABLE produto (
    id_produto     NUMBER GENERATED ALWAYS AS IDENTITY,
    nome           VARCHAR2(100) NOT NULL,
    id_categoria   NUMBER NOT NULL,
    preco_venda    NUMBER(10,2) NOT NULL,
    estoque_atual  NUMBER(10) DEFAULT 0 NOT NULL,
    estoque_minimo NUMBER(10) DEFAULT 0 NOT NULL,
    ativo          CHAR(1) DEFAULT 'S' NOT NULL,
    CONSTRAINT pk_produto PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria),
    CONSTRAINT ck_produto_preco CHECK (preco_venda >= 0),
    CONSTRAINT ck_produto_estoque CHECK (estoque_atual >= 0),
    CONSTRAINT ck_produto_estmin CHECK (estoque_minimo >= 0),
    CONSTRAINT ck_produto_ativo CHECK (ativo IN ('S','N'))
);

CREATE TABLE produto_fornecedor (
    id_produto       NUMBER,
    id_fornecedor    NUMBER,
    preco_referencia NUMBER(10,2) NOT NULL,
    prazo_entrega    NUMBER(3) NOT NULL,
    CONSTRAINT pk_prod_forn PRIMARY KEY (id_produto, id_fornecedor),
    CONSTRAINT fk_pf_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
    CONSTRAINT fk_pf_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor),
    CONSTRAINT ck_pf_preco CHECK (preco_referencia >= 0),
    CONSTRAINT ck_pf_prazo CHECK (prazo_entrega >= 0)
);

CREATE TABLE compra (
    id_compra     NUMBER GENERATED ALWAYS AS IDENTITY,
    id_fornecedor NUMBER NOT NULL,
    data          DATE DEFAULT SYSDATE NOT NULL,
    status        VARCHAR2(15) DEFAULT 'ABERTA' NOT NULL,
    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedor (id_fornecedor),
    CONSTRAINT ck_compra_status CHECK (status IN ('ABERTA','RECEBIDA','CANCELADA'))
);

CREATE TABLE item_compra (
    id_compra      NUMBER,
    id_produto     NUMBER,
    quantidade     NUMBER(10) NOT NULL,
    preco_unitario NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_item_compra PRIMARY KEY (id_compra, id_produto),
    CONSTRAINT fk_ic_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra),
    CONSTRAINT fk_ic_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
    CONSTRAINT ck_ic_qtd CHECK (quantidade > 0),
    CONSTRAINT ck_ic_preco CHECK (preco_unitario >= 0)
);

CREATE TABLE movimentacao (
    id_movimentacao NUMBER GENERATED ALWAYS AS IDENTITY,
    id_produto      NUMBER NOT NULL,
    tipo            VARCHAR2(7) NOT NULL,
    motivo          VARCHAR2(30),
    quantidade      NUMBER(10) NOT NULL,
    data            DATE DEFAULT SYSDATE NOT NULL,
    id_compra       NUMBER,
    CONSTRAINT pk_movimentacao PRIMARY KEY (id_movimentacao),
    CONSTRAINT fk_mov_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
    CONSTRAINT ck_mov_tipo CHECK (tipo IN ('ENTRADA','SAIDA')),
    CONSTRAINT ck_mov_qtd CHECK (quantidade > 0)
);

-- FK adicionada depois
ALTER TABLE movimentacao
    ADD CONSTRAINT fk_mov_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra);