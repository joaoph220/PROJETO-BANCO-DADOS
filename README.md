# EstoqueFácil – Controle de Estoque de Pequeno Comércio

**Disciplina:** Banco de Dados I – ADS – FATEC Ribeirão Preto
**Professora:** Profa. Me. Eliza Bomfim
**SGBD:** Oracle
**Integrantes:** JOÃO PEDRO ALMEIDA DA SILVA, HENRY FRANK RINALDI AZIANI.

---

## 1. Contexto e problema
A Atitude é uma pequena empresa familiar que comercializa produtos de limpeza, higienização e descartáveis de uso profissional. O estoque e o lançamento das notas são feitos em um sistema de gestão (ERP) comercial, que atende bem o registro das operações e permite consultar, por exemplo, o gasto com cada fornecedor.

Em conversa com o responsável pela empresa, foi relatado que já ocorreu de produtos ficarem parados em estoque, ou seja, compras de itens que não giraram. As compras são feitas, em geral, com os fornecedores de costume, cujos preço e prazo de entrega já são conhecidos.

O projeto organiza esses dados em um banco relacional consistente e normalizado, capaz de indicar o que precisa ser reposto, identificar produtos sem saída e registrar o histórico de entradas e saídas de cada item, com o motivo. O banco não substitui o ERP: serve como base de apoio ao controle de estoque e à decisão de compra.

## 2. Usuário / público-alvo



## 3. Necessidades de informação

- Quais produtos preciso comprar agora?
- Quanto gastei por fornecedor?
- Quais categorias concentram mais gastos?
- Quais produtos nunca tiveram saída?
- Qual o histórico de entradas e saídas de um produto?


---

## 4. DER (modelo conceitual)

![DER]

Cardinalidades:

- **Categoria 1:N Produto**: um produto pertence a uma categoria; uma categoria tem vários produtos.
- **Fornecedor N:M Produto**: um fornecedor vende vários produtos e um produto pode ter vários fornecedores. Resolvido pela tabela associativa `PRODUTO_FORNECEDOR`.
- **Fornecedor 1:N Compra**: uma compra é feita a um único fornecedor.
- **Compra N:M Produto**: uma compra tem vários produtos e um produto aparece em várias compras. Resolvido por `ITEM_COMPRA`, que carrega quantidade e preço unitário.
- **Produto 1:N Movimentação**: cada produto tem várias movimentações de entrada e saída.

## 5. Modelo lógico/relacional

![Modelo lógico]

Regras de conversão aplicadas:

- Cada entidade virou uma tabela.
- Nos relacionamentos 1:N, a chave estrangeira foi colocada no lado N.
- Nos relacionamentos N:M, foi criada uma tabela associativa com as duas chaves estrangeiras formando a chave primária composta.

Tabelas: `categoria`, `fornecedor`, `produto`, `produto_fornecedor`, `compra`, `item_compra`, `movimentacao` e `log_preco` (auditoria).

---

## 6. Normalização

### Ponto de partida: tabela não normalizada

**COMPRA_GERAL** (id_compra, data, nome_fornecedor, cnpj_fornecedor, telefone_fornecedor, id_produto, nome_produto, categoria, descricao_categoria, qtd, preco)

Essa tabela causa três anomalias:

- **Inserção:** não é possível cadastrar um fornecedor novo que ainda não vendeu nada.
- **Atualização:** se o telefone do fornecedor mudar, é preciso alterar todas as linhas; esquecer uma deixa dados contraditórios.
- **Exclusão:** apagar a única compra de um produto faz o produto e o fornecedor desaparecerem junto.

### 1ª Forma Normal (1FN)

Cada célula guarda um único valor (atômico) e não há grupos repetidos.

- Errado: uma coluna `produtos` com "arroz, feijão, óleo", ou colunas `produto1`, `produto2`, `produto3`.
- Correto: uma linha por produto comprado, com chave composta (`id_compra`, `id_produto`).

### 2ª Forma Normal (2FN)

Está na 1FN e nenhum atributo depende de apenas **parte** da chave composta.

- Com a chave (`id_compra`, `id_produto`): `nome_produto` depende só de `id_produto`; `data` e fornecedor dependem só de `id_compra`.
- **Solução:** separar em `PRODUTO`, `COMPRA` e `ITEM_COMPRA`. Em `ITEM_COMPRA`, quantidade e preço dependem da chave inteira.

### 3ª Forma Normal (3FN)

Está na 2FN e nenhum atributo não-chave depende de outro atributo não-chave (dependência transitiva).

- Em `PRODUTO`: `id_produto` → categoria → descrição da categoria.
- Em `COMPRA`: `id_compra` → fornecedor → telefone do fornecedor.
- **Solução:** criar `CATEGORIA` e `FORNECEDOR`, mantendo apenas a chave estrangeira nas outras tabelas.

### Redundâncias deliberadas

- **`produto.estoque_atual`:** poderia ser calculado somando as movimentações. Foi mantido como redundância controlada para que a consulta de reposição seja rápida e simples. A trigger de movimentação mantém o valor sempre correto.
- **`item_compra.preco_unitario`:** não é redundância. Guarda o preço **pago naquela compra**, que muda com o tempo. Sem ele, o histórico de preços se perderia.

---

## 7. Dicionário de dados

| Tabela | Coluna | Tipo | Nulo? | Chave | Regra associada |
|---|---|---|---|---|---|
| categoria | id_categoria | NUMBER | Não | PK | Identity |
| categoria | nome | VARCHAR2(50) | Não | UNIQUE | RN2 |
| fornecedor | id_fornecedor | NUMBER | Não | PK | Identity |
| fornecedor | razao_social | VARCHAR2(100) | Não | | |
| fornecedor | cnpj | CHAR(14) | Não | UNIQUE | RN1 |
| fornecedor | telefone | VARCHAR2(15) | Sim | | |
| fornecedor | email | VARCHAR2(100) | Sim | | |
| produto | id_produto | NUMBER | Não | PK | Identity |
| produto | nome | VARCHAR2(100) | Não | | |
| produto | id_categoria | NUMBER | Não | FK → categoria | RN5 |
| produto | preco_venda | NUMBER(10,2) | Não | | RN3 |
| produto | estoque_atual | NUMBER(10) | Não | | RN6; redundância controlada |
| produto | estoque_minimo | NUMBER(10) | Não | | Base da consulta de reposição |
| produto | ativo | CHAR(1) | Não | | CHECK 'S' ou 'N' |
| produto_fornecedor | id_produto | NUMBER | Não | PK/FK → produto | RN5 |
| produto_fornecedor | id_fornecedor | NUMBER | Não | PK/FK → fornecedor | RN5 |
| produto_fornecedor | preco_referencia | NUMBER(10,2) | Não | | RN3 |
| produto_fornecedor | prazo_entrega_dias | NUMBER(3) | Sim | | |
| compra | id_compra | NUMBER | Não | PK | Identity |
| compra | id_fornecedor | NUMBER | Não | FK → fornecedor | RN5 |
| compra | data_compra | DATE | Não | | Default SYSDATE |
| compra | status | VARCHAR2(15) | Não | | CHECK ABERTA/RECEBIDA/CANCELADA |
| item_compra | id_compra | NUMBER | Não | PK/FK → compra | RN5 |
| item_compra | id_produto | NUMBER | Não | PK/FK → produto | RN5 |
| item_compra | quantidade | NUMBER(10) | Não | | RN4 |
| item_compra | preco_unitario | NUMBER(10,2) | Não | | RN3; preço pago na compra |
| movimentacao | id_movimentacao | NUMBER | Não | PK | Identity |
| movimentacao | id_produto | NUMBER | Não | FK → produto | RN5 |
| movimentacao | tipo | VARCHAR2(7) | Não | | RN9 |
| movimentacao | motivo | VARCHAR2(30) | Não | | |
| movimentacao | quantidade | NUMBER(10) | Não | | RN4 |
| movimentacao | data_mov | DATE | Não | | Default SYSDATE |
| movimentacao | id_compra | NUMBER | Sim | FK → compra | Nulo em saída por venda |
| log_preco | id_log | NUMBER | Não | PK | Identity |
| log_preco | id_produto | NUMBER | Não | | Preenchido pela trigger (RN8) |
| log_preco | preco_antigo | NUMBER(10,2) | Sim | | |
| log_preco | preco_novo | NUMBER(10,2) | Sim | | |
| log_preco | data_alteracao | DATE | Sim | | Default SYSDATE |

---

## 8. Regras de negócio

| # | Regra | Como é garantida |
|---|---|---|
| RN1 | O CNPJ do fornecedor não pode repetir | Declarativa: `UNIQUE` em `fornecedor.cnpj` |
| RN2 | O nome da categoria não pode repetir | Declarativa: `UNIQUE` em `categoria.nome` |
| RN3 | Preços e valores não podem ser negativos | Declarativa: `CHECK (preco >= 0)` |
| RN4 | A quantidade de um item ou movimentação deve ser maior que zero | Declarativa: `CHECK (quantidade > 0)` |
| RN5 | Não existe produto de categoria inexistente; item só existe com compra e produto existentes | Referencial: `FOREIGN KEY` |
| RN6 | O estoque nunca pode ficar negativo | `CHECK (estoque_atual >= 0)` + trigger |
| RN7 | Uma saída não pode ser maior que o saldo em estoque | PL/SQL: trigger em `movimentacao` |
| RN8 | Toda mudança de preço de venda fica registrada | PL/SQL: trigger de auditoria (`log_preco`) |
| RN9 | O tipo da movimentação é apenas ENTRADA ou SAIDA | Declarativa: `CHECK` |

---

## 9. Consultas e perguntas de negócio

| # | Pergunta de negócio | Recursos usados |
|---|---|---|
| 1 | Quais produtos ativos custam mais de R$ 20, do mais caro ao mais barato? | SELECT, WHERE, ORDER BY |
| 2 | Qual o nome e a categoria de cada produto? | JOIN |
| 3 | Quais produtos cada fornecedor me vendeu e a que preço? | JOIN de 3 tabelas |
| 4 | Quanto gastei por fornecedor? | SUM, GROUP BY |
| 5 | Quais categorias gastaram mais de R$ 1.000 em compras? | GROUP BY, HAVING |
| 6 | Quais produtos nunca tiveram saída? | Subconsulta |
| 7 | Qual o histórico de entradas e saídas de um produto? | UNION |
| 8 | O que preciso comprar agora, e de qual fornecedor? | JOIN, filtro `estoque_atual <= estoque_minimo` |



## 10. Objetos PL/SQL

| Objeto | Tipo | Finalidade |
|---|---|---|
| `registrar_compra` | Procedure | Registra uma compra e seus itens em uma única operação, com rollback em caso de erro |
| `fn_situacao_estoque` | Function | Retorna 'CRÍTICO', 'ATENÇÃO' ou 'OK' conforme o estoque atual e o mínimo; pode ser usada em um SELECT |
| `trg_movimentacao_estoque` | Trigger | Após INSERT em `movimentacao`, soma ou subtrai do `estoque_atual`; bloqueia saída maior que o saldo |
| `trg_auditoria_preco` | Trigger | Registra em `log_preco` toda alteração de `preco_venda` |



---

## 11. Como criar e testar o banco no Oracle

1. Abrir o Oracle Live SQL (ou SQL Developer conectado ao Oracle XE).
2. Executar, nesta ordem, como **script** (não linha por linha):
   1. `01_ddl_estrutura.sql`
   2. `02_dml_carga.sql`
   3. `03_dml_operacoes.sql`
   4. `04_consultas.sql`
   5. `05_plsql.sql`
   6. `06_testes.sql`
3. Conferir a criação com:

```sql
SELECT table_name FROM user_tables ORDER BY table_name;
```

Observação: na primeira execução do `01_ddl_estrutura.sql`, os erros `ORA-00942` nos comandos `DROP TABLE` são esperados, pois as tabelas ainda não existem.

## 12. Estrutura do repositório

```text
/docs      DER, modelo lógico
/scripts   01_ddl_estrutura.sql a 06_testes.sql
README.md
```
