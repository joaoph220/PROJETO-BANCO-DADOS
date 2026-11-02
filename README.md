## EstoqueFácil – Controle de Estoque de Pequeno Comércio

**Disciplina:** Banco de Dados I – ADS – FATEC Ribeirão Preto
**Professora:** Profa. Me. Eliza Bomfim
**Integrantes:** JOÃO PEDRO ALMEIDA DA SILVA,HENRY FRANK RINALDI AZIANI.


## 1. Contexto e problema


## 2. Usuário / público-alvo


## 3. Necessidades de informação
- Quais produtos preciso comprar agora?
- Quanto gastei por fornecedor?
- Quais produtos nunca tiveram saída?
- Qual o histórico de entradas e saídas de um produto?


## 4. DER (modelo conceitual)


## 5. Modelo lógico/relacional

## 6. Normalização
COMPRA_GERAL (id_compra, data, nome_fornecedor, cnpj_fornecedor, telefone_fornecedor, id_produto, nome_produto, categoria, descricao_categoria, qtd, preco).

#Para que não ficassem bagunçadas as tabelas, criamos novas tabelas afim de separarmos ações e evitar problemas nas inserções de informação, atualizações e exclusões no banco de dados.

1º Forma Normal
Cada célula guarda um valor único, e não existem grupos repetidos.

Errado: uma coluna produtos com “arroz, feijão, óleo”, ou colunas produto1, produto2, produto3.
Correto: 	uma linha por produto comprado. Cada linha passa a ter uma chave 	composta (id_compra + id_produto). 	

2ª Forma Normal
Já está na 1FN e, se a chave é composta, nenhum atributo pode depender de só parte da chave.

A 	chave é (id_compra, id_produto). Mas nome_produto 	depende só de id_produto, e data 	e fornecedor 	dependem só de id_compra. 	
Solução: 	separar em PRODUTO (id_produto, nome...), COMPRA (id_compra, data, 	fornecedor) e ITEM_COMPRA (id_compra, id_produto, qtd, preço). Em 	ITEM_COMPRA, a quantidade e o preço dependem da chave inteira, e 	isso está correto. 	

3ª Forma Normal
Já está na 2FN e nenhum atributo não-chave depende de outro atributo não-chave (dependência transitiva).
	
Em 	PRODUTO: id_produto → categoria → descricao_categoria. A 	descrição depende da categoria, e não do produto. 	
Em 	COMPRA: id_compra → fornecedor → telefone_fornecedor. O telefone 	depende do fornecedor. 	
	
Solução: 	criar CATEGORIA e FORNECEDOR, e deixar só a FK nas outras tabelas.

Redundância Proposital:	
estoque_atual 	em PRODUTO poderia ser calculado somando as movimentações. 	Guardá-lo é redundância controlada: a consulta de reposição 	fica rápida e simples, e a trigger 	mantém o valor sempre correto. 	
preco_unitario 	em ITEM_COMPRA não é redundância. É o preço pago 	naquela compra, que muda com o tempo. Se só 	existisse o preço atual em PRODUTO, o histórico se perderia.


## 7. Dicionário de dados

Tabela	Coluna	Tipo	Nulo?	Chave	Regra associada
categoria	id_categoria	NUMBER	Não	PK	Identity
categoria	nome	VARCHAR2(50)	Não	UNIQUE	RN2
fornecedor	id_fornecedor	NUMBER	Não	PK	Identity
fornecedor	razao_social	VARCHAR2(100)	Não		
fornecedor	cnpj	CHAR(14)	Não	UNIQUE	RN1
fornecedor	telefone	VARCHAR2(15)	Sim		
fornecedor	email	VARCHAR2(100)	Sim		
produto	id_produto	NUMBER	Não	PK	Identity
produto	nome	VARCHAR2(100)	Não		
produto	id_categoria	NUMBER	Não	FK → categoria	RN5
produto	preco_venda	NUMBER(10,2)	Não		RN3
produto	estoque_atual	NUMBER(10)	Não		RN6; redundância controlada
produto	estoque_minimo	NUMBER(10)	Não		Base da consulta de reposição
produto	ativo	CHAR(1)	Não		CHECK ‘S’ ou ’N’
produto_fornecedor	id_produto	NUMBER	Não	PK/FK → produto	RN5
produto_fornecedor	id_fornecedor	NUMBER	Não	PK/FK → fornecedor	RN5
produto_fornecedor	preco_referencia	NUMBER(10,2)	Não		RN3
produto_fornecedor	prazo_entrega_dias	NUMBER(3)	Sim		
compra	id_compra	NUMBER	Não	PK	Identity
compra	id_fornecedor	NUMBER	Não	FK → fornecedor	RN5
compra	data_compra	DATE	Não		Default SYSDATE
compra	status	VARCHAR2(15)	Não		CHECK ABERTA/RECEBIDA/CANCELADA
item_compra	id_compra	NUMBER	Não	PK/FK → compra	RN5
item_compra	id_produto	NUMBER	Não	PK/FK → produto	RN5
item_compra	quantidade	NUMBER(10)	Não		RN4
item_compra	preco_unitario	NUMBER(10,2)	Não		RN3; preço pago na compra
movimentacao	id_movimentacao	NUMBER	Não	PK	Identity
movimentacao	id_produto	NUMBER	Não	FK → produto	RN5
movimentacao	tipo	VARCHAR2(7)	Não		RN9
movimentacao	motivo	VARCHAR2(30)	Não		
movimentacao	quantidade	NUMBER(10)	Não		RN4
movimentacao	data_mov	DATE	Não		Default SYSDATE
movimentacao	id_compra	NUMBER	Sim	FK → compra	Nulo em saída por venda
log_preco	id_log	NUMBER	Não	PK	Identity
log_preco	id_produto	NUMBER	Não		Preenchido pela trigger (RN8)
log_preco	preco_antigo	NUMBER(10,2)	Sim		
log_preco	preco_novo	NUMBER(10,2)	Sim		
log_preco	data_alteracao	DATE	Sim		Default SYSDATE

## 8. Regras de negócio
RN1	- O CNPJ do fornecedor não pode repetir	Declarativa: UNIQUE em fornecedor.cnpj
RN2	- O nome da categoria não pode repetir	Declarativa: UNIQUE em categoria.nome
RN3	- Preços e valores não podem ser negativos	Declarativa: CHECK (preco >= 0)
RN4	- A quantidade de um item ou movimentação deve ser maior que zero	Declarativa: CHECK (quantidade > 0)
RN5	- Um produto não pode ter categoria inexistente; um item não existe sem compra e produto	Referencial: FOREIGN KEY
RN6	- O estoque nunca pode ficar negativo	CHECK (estoque_atual >= 0) + trigger (a fazer)
RN7	- Uma saída não pode ser maior que o saldo em estoque	PL/SQL: trigger (a fazer)
RN8	- Toda mudança de preço de venda fica registrada	PL/SQL: trigger de auditoria (a fazer)
RN9	- O tipo da movimentação é só ENTRADA ou SAIDA	Declarativa: CHECK

## 9. Consultas e perguntas de negócio


## 10. Objetos PL/SQL


## 11. Como criar e testar o banco no Oracle
1. Abrir o Oracle Live SQL (ou SQL Developer conectado ao Oracle XE).
2. Executar, nesta ordem: 01_ddl_estrutura.sql, 02_dml_carga.sql,
   03_dml_operacoes.sql, 04_consultas.sql, 05_plsql.sql, 06_testes.sql.
3. Conferir com: SELECT table_name FROM user_tables;

## 12. Estrutura do repositório
/docs (DER, modelo lógico, README)
/scripts (01 a 06 .sql)
