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

Usuários de referência: dois perfis, entrevistados durante o projeto.

- **Responsável comercial** (vendas, entregas e compras): decide o que comprar e de qual fornecedor. Usaria o banco para saber quais produtos precisam ser repostos, quais estão parados em estoque e quanto foi gasto com cada fornecedor.
- **Responsável administrativo** (notas fiscais e financeiro): lança as entradas e saídas de nota, que alteram o estoque. Usaria o banco para registrar compras e movimentações e consultar o histórico de um produto, com a data e o motivo de cada alteração.

**Público-alvo:** o modelo também serve a outros pequenos comércios que controlam estoque e compras de forma semelhante.

## 3. Necessidades de informação

1. Quais produtos estão com estoque igual ou abaixo do mínimo e precisam ser comprados agora, e qual fornecedor os atende?
2. Quais produtos nunca tiveram saída (estoque parado)?
3. Quanto foi gasto com cada fornecedor?
4. Quais categorias concentram mais gastos com compras?
5. Quais produtos cada fornecedor vende, a que preço de referência e com qual prazo de entrega?
6. Qual o histórico de entradas e saídas de um produto, e o motivo de cada movimentação?
7. Quais compras estão abertas e ainda não foram recebidas?

---

## 4. DER (modelo conceitual)

Arquivo: [Visualizar Modelo Conceitual (DER - PDF)](./modelo_conceitual_der.pdf)

Entidades: Categoria, Fornecedor, Produto, Compra e Movimentacao.

Relacionamentos e cardinalidades (mínima, máxima):

| Relacionamento | Entidades | Cardinalidades | Observação |
|---|---|---|---|
| Classificar | Categoria (0,n) – Produto (1,1) | 1:N | Todo produto tem exatamente uma categoria; uma categoria pode ter nenhum ou vários produtos |
| Fornecer | Fornecedor (0,n) – Produto (0,n) | N:M | Atributos do relacionamento: `preco_referencia` e `prazo_entrega` |
| Realizar | Fornecedor (0,n) – Compra (1,1) | 1:N | Toda compra é feita a exatamente um fornecedor |
| Conter | Produto (0,n) – Compra (1,n) | N:M | Atributos do relacionamento: `quantidade` e `preco_unitario`. Toda compra tem ao menos um item |
| Possuir | Produto (0,n) – Movimentacao (1,1) | 1:N | Toda movimentação pertence a exatamente um produto |
| Gerar | Compra (0,n) – Movimentacao (0,1) | 1:N | Uma movimentação pode ou não ter origem em uma compra (saída por venda não tem) |

## 5. Modelo lógico/relacional

Arquivo: [Visualizar Modelo Lógico (PDF)](./modelo_logico_der.pdf)

Regras de conversão aplicadas:

- Cada entidade virou uma tabela.
- Nos relacionamentos 1:N, a chave estrangeira foi colocada no lado N: `id_categoria` em `produto`, `id_fornecedor` em `compra`, `id_produto` e `id_compra` em `movimentacao`.
- Nos relacionamentos N:M, foi criada uma tabela associativa com as duas chaves estrangeiras formando a chave primária composta: `produto_fornecedor` (de Fornecer) e `item_compra` (de Conter). Os atributos do relacionamento foram para essas tabelas.
- A participação (0,1) de Movimentacao em Gerar fez `movimentacao.id_compra` ser opcional (aceita nulo).

Tabelas: `categoria`, `fornecedor`, `produto`, `produto_fornecedor`, `compra`, `item_compra` e `movimentacao`.

Observação sobre tipos: o modelo lógico usa tipos genéricos (`INT`, `FLOAT`, `VARCHAR`). Na implementação Oracle, foram adotados `NUMBER` (com `GENERATED ALWAYS AS IDENTITY` nos identificadores), `NUMBER(10,2)` para valores monetários (evita erros de arredondamento do `FLOAT`), `VARCHAR2`, `CHAR` e `DATE`.

---

## 6. Normalização

### Ponto de partida: tabela não normalizada

**COMPRA_GERAL** (id_compra, data, id_fornecedor, nome_fornecedor, cnpj_fornecedor, telefone_fornecedor, id_produto, nome_produto, id_categoria, nome_categoria, qtd, preco)

Essa tabela causa três anomalias:

- **Inserção:** não é possível cadastrar um fornecedor novo que ainda não vendeu nada.
- **Atualização:** se o telefone do fornecedor mudar, é preciso alterar todas as linhas; esquecer uma deixa dados contraditórios.
- **Exclusão:** apagar a única compra de um produto faz o produto e o fornecedor desaparecerem junto.

### 1ª Forma Normal (1FN)

Cada célula guarda um único valor (atômico) e não há grupos repetidos.

- Errado: uma coluna `produtos` com "desinfetante, detergente, luva", ou colunas `produto1`, `produto2`, `produto3`.
- Correto: uma linha por produto comprado, com chave composta (`id_compra`, `id_produto`).

### 2ª Forma Normal (2FN)

Está na 1FN e nenhum atributo depende de apenas **parte** da chave composta.

- Com a chave (`id_compra`, `id_produto`): `nome_produto` depende só de `id_produto`; `data` e fornecedor dependem só de `id_compra`.
- **Solução:** separar em `PRODUTO`, `COMPRA` e `ITEM_COMPRA`. Em `ITEM_COMPRA`, quantidade e preço dependem da chave inteira.

### 3ª Forma Normal (3FN)

Está na 2FN e nenhum atributo não-chave depende de outro atributo não-chave (dependência transitiva).

- Em `PRODUTO`: `id_produto` → `id_categoria` → `nome_categoria`.
- Em `COMPRA`: `id_compra` → `id_fornecedor` → `telefone_fornecedor`.
- **Solução:** criar `CATEGORIA` e `FORNECEDOR`, mantendo apenas a chave estrangeira nas outras tabelas.

O N:M entre Fornecedor e Produto também foi resolvido em `PRODUTO_FORNECEDOR`: preço de referência e prazo de entrega dependem do **par** produto + fornecedor, e não de um só.

### Redundâncias deliberadas

- **`produto.estoque_atual`:** poderia ser calculado somando as movimentações. Foi mantido como redundância controlada para que a consulta de reposição seja rápida e simples. A trigger de movimentação mantém o valor sempre correto.
- **`item_compra.preco_unitario`:** não é redundância. Guarda o preço **pago naquela compra**, que muda com o tempo. Sem ele, o histórico de preços se perderia.

---

## 7. Dicionário de dados

| Tabela | Coluna | Tipo | Nulo? | Chave | Regra associada |
|---|---|---|---|---|---|
| categoria | id_categoria | NUMBER | Não | PK | Identity |
| categoria | nome | VARCHAR2(50) | Não | UNIQUE | RN3 |
| fornecedor | id_fornecedor | NUMBER | Não | PK | Identity |
| fornecedor | razao_social | VARCHAR2(100) | Não | | |
| fornecedor | cnpj | CHAR(14) | Não | UNIQUE | RN1, RN2 |
| fornecedor | telefone | VARCHAR2(15) | Sim | | |
| fornecedor | email | VARCHAR2(100) | Sim | | |
| produto | id_produto | NUMBER | Não | PK | Identity |
| produto | nome | VARCHAR2(100) | Não | | |
| produto | id_categoria | NUMBER | Não | FK → categoria | RN6 |
| produto | preco_venda | NUMBER(10,2) | Não | | RN4 |
| produto | estoque_atual | NUMBER(10) | Não | | RN7; redundância controlada |
| produto | estoque_minimo | NUMBER(10) | Não | | RN7; base da consulta de reposição |
| produto | ativo | CHAR(1) | Não | | CHECK 'S' ou 'N'; default 'S' |
| produto_fornecedor | id_produto | NUMBER | Não | PK/FK → produto | RN6 |
| produto_fornecedor | id_fornecedor | NUMBER | Não | PK/FK → fornecedor | RN6 |
| produto_fornecedor | preco_referencia | NUMBER(10,2) | Não | | RN4 |
| produto_fornecedor | prazo_entrega | NUMBER(3) | Não | | CHECK >= 0 (dias) |
| compra | id_compra | NUMBER | Não | PK | Identity |
| compra | id_fornecedor | NUMBER | Não | FK → fornecedor | RN6 |
| compra | data | DATE | Não | | Default SYSDATE |
| compra | status | VARCHAR2(15) | Não | | RN10; default 'ABERTA' |
| item_compra | id_compra | NUMBER | Não | PK/FK → compra | RN6 |
| item_compra | id_produto | NUMBER | Não | PK/FK → produto | RN6 |
| item_compra | quantidade | NUMBER(10) | Não | | RN5 |
| item_compra | preco_unitario | NUMBER(10,2) | Não | | RN4; preço pago na compra |
| movimentacao | id_movimentacao | NUMBER | Não | PK | Identity |
| movimentacao | id_produto | NUMBER | Não | FK → produto | RN6 |
| movimentacao | tipo | VARCHAR2(7) | Não | | RN9 |
| movimentacao | motivo | VARCHAR2(30) | Sim | | Ex.: COMPRA, VENDA, AJUSTE |
| movimentacao | quantidade | NUMBER(10) | Não | | RN5, RN8 |
| movimentacao | data | DATE | Não | | Default SYSDATE |
| movimentacao | id_compra | NUMBER | Sim | FK → compra | RN6; nulo em saída por venda |

---

## 8. Regras de negócio

| # | Regra | Como é garantida |
|---|---|---|
| RN1 | O CNPJ do fornecedor não pode repetir | Declarativa: `UNIQUE` em `fornecedor.cnpj` |
| RN2 | O CNPJ deve ter exatamente 14 dígitos numéricos | Declarativa: `CHECK` em `fornecedor.cnpj` |
| RN3 | O nome da categoria não pode repetir | Declarativa: `UNIQUE` em `categoria.nome` |
| RN4 | Preços não podem ser negativos | Declarativa: `CHECK (... >= 0)` em `preco_venda`, `preco_referencia` e `preco_unitario` |
| RN5 | A quantidade de um item de compra ou movimentação deve ser maior que zero | Declarativa: `CHECK (quantidade > 0)` |
| RN6 | Não existe produto sem categoria, compra sem fornecedor, item sem compra e produto, nem movimentação sem produto | Referencial: `FOREIGN KEY` + `NOT NULL` |
| RN7 | Estoque atual e estoque mínimo nunca podem ser negativos | Declarativa: `CHECK` em `produto` |
| RN8 | Uma saída não pode ser maior que o saldo em estoque | PL/SQL: trigger `trg_movimentacao_estoque` |
| RN9 | O tipo da movimentação é apenas ENTRADA ou SAIDA | Declarativa: `CHECK` |
| RN10 | O status da compra é apenas ABERTA, RECEBIDA ou CANCELADA | Declarativa: `CHECK` |
| RN11 | Toda compra registrada pela procedure nasce com ao menos um item | PL/SQL: procedure `registrar_compra` |

Cada regra tem um teste (um comando que passa e outro que é bloqueado) no arquivo `06_testes.sql`.

---

## 9. Consultas e perguntas de negócio

Arquivo: `04_consultas.sql`.

| # | Pergunta de negócio | Recursos usados |
|---|---|---|
| 1 | Quais produtos ativos custam mais de R$ 20, do mais caro ao mais barato? | SELECT, WHERE, ORDER BY |
| 2 | Qual o nome e a categoria de cada produto? | JOIN |
| 3 | Quais produtos cada fornecedor vende, a que preço de referência e com qual prazo? | JOIN de 3 tabelas |
| 4 | Quanto foi gasto com cada fornecedor e quantas compras foram feitas? | SUM, COUNT, GROUP BY |
| 5 | Quais categorias concentram gastos acima de R$ 3.000 em compras recebidas? | GROUP BY, HAVING |
| 6 | Quais produtos ativos nunca tiveram saída (estoque parado)? | Subconsulta (NOT EXISTS) |
| 6B | Quais produtos estão com estoque abaixo da média geral? | Subconsulta escalar (AVG) |
| 7 | Qual o histórico unificado de entradas e saídas de cada produto? | UNION |
| 8 | O que precisa ser comprado agora, de qual fornecedor (menor preço) e em quantos dias ele entrega? | JOIN, LEFT JOIN, subconsulta correlacionada |
| 9 | Quais compras estão abertas, com qual fornecedor e qual valor previsto? | JOIN, GROUP BY, SUM |

Nas consultas de gasto (4, 5 e 7), só entram compras com status `RECEBIDA`: compras abertas ou canceladas não geraram despesa nem entrada de estoque.

## 10. Objetos PL/SQL

Arquivo: `05_plsql.sql`.

| Objeto | Tipo | Finalidade |
|---|---|---|
| `trg_movimentacao_estoque` | Trigger | Antes de cada INSERT em `movimentacao`, soma (ENTRADA) ou subtrai (SAIDA) do `estoque_atual` do produto; bloqueia saída maior que o saldo com o erro ORA-20001 (RN8) |
| `fn_situacao_estoque` | Function | Retorna 'CRITICO' (estoque <= mínimo), 'ATENCAO' (até 50% acima do mínimo) ou 'OK'; devolve NULL se o produto não existe; pode ser usada em um SELECT |
| `registrar_compra` | Procedure | Registra uma compra recebida de um produto: cria a compra, o item e a movimentação de ENTRADA em uma única transação, com rollback em caso de erro (RN11) |

---

## 11. Como criar e testar o banco no Oracle

1. Abrir o Oracle FreeSQL.
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

Observações:

- O `01_ddl_estrutura.sql` começa apagando as tabelas do projeto, então pode ser executado quantas vezes for preciso para reconstruir o banco do zero. O bloco ignora o erro ORA-00942 (tabela não existe) na primeira execução.
- O `02_dml_carga.sql` só roda com as tabelas vazias; se já houver dados, ele avisa para executar o `01` antes.
- A carga insere o `estoque_atual` de cada produto já calculado (entradas menos saídas), porque a trigger só é criada no `05_plsql.sql`. Ao final do `02`, a conferência 2 confirma que `estoque_atual` bate com a soma das movimentações.
- Contagem esperada de linhas depois do `02`: categoria 7, fornecedor 7, produto 25, produto_fornecedor 28, compra 13, item_compra 37, movimentacao 65. Depois do `03`: compra 12 e item_compra 36 (as demais não mudam).
- O `06_testes.sql` gera erros de propósito (comandos marcados "DEVE FALHAR"). O teste da procedure faz COMMIT e fica por último; para limpar a base, execute `01` e `02` de novo.

## 12. Estrutura do repositório

```text
01_ddl_estrutura.sql
02_dml_carga.sql
03_dml_operacoes.sql
04_consultas.sql
05_plsql.sql
06_testes.sql
modelo_conceitual_der.pdf
modelo_logico_der.pdf
README.md
```
