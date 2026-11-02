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


## 8. Regras de negócio


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
