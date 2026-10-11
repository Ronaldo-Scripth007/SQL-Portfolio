# Window Functions em SQL (PostgreSQL)

Coleção de consultas analíticas que resolvem perguntas reais de negócio sobre um banco de **vendas** (clientes, produtos e pedidos) usando **Window Functions** em PostgreSQL.

O foco não é só a sintaxe: cada arquivo parte de uma pergunta de negócio, explica a técnica e registra as armadilhas que evitei (ordenação de datas, `NULL` no ranking, empates em somas acumuladas, divisão por zero).

## O que está aqui

| Arquivo | Pergunta de negócio | Técnicas |
|---|---|---|
| [`01_ranking.sql`](sql/01_ranking.sql) | Quem são os clientes de maior renda? Como tratar empates? | `RANK`, `DENSE_RANK`, `ROW_NUMBER` |
| [`02_medias_moveis.sql`](sql/02_medias_moveis.sql) | A receita está subindo ou caindo, sem o ruído mensal? | `AVG() OVER` com frame, `date_trunc` |
| [`03_lag_lead_comparacao_periodos.sql`](sql/03_lag_lead_comparacao_periodos.sql) | Quanto variamos vs. mês anterior (MoM) e ano anterior (YoY)? | `LAG`, `LEAD`, `NULLIF` |
| [`04_acumulados_e_pareto.sql`](sql/04_acumulados_e_pareto.sql) | Quanto já vendemos no acumulado? Quais produtos geram 80% da receita? | `SUM() OVER`, curva ABC com `CASE` |
| [`05_ntile_min_max.sql`](sql/05_ntile_min_max.sql) | Como segmentar clientes por renda? Qual o menor/maior volume em 3 meses? | `NTILE`, `MIN/MAX OVER` |
| [`06_contribuicao_e_partition_by.sql`](sql/06_contribuicao_e_partition_by.sql) | Quanto cada mês pesa no total? Qual o produto mais caro de cada marca? | `PARTITION BY`, `SUM(SUM()) OVER ()` |

## Modelo de dados

Schema `vendas`, colunas usadas nas consultas:

| Tabela | Colunas |
|---|---|
| `clientes` | `ID_Cliente`, `Nome`, `Email`, `Renda_Anual` |
| `produtos` | `ID_Produto`, `Nome_Produto`, `ID_Categoria`, `Marca_Produto`, `Num_Serie`, `Preco_Unit`, `Custo_Unit` |
| `pedidos` | `ID_Produto`, `Data_Venda`, `Qtd_Vendida`, `Receita_Venda` |

Relacionamento: `pedidos.ID_Produto` → `produtos.ID_Produto`.

> Os nomes das colunas usam maiúsculas, por isso aparecem entre aspas duplas (`"ID_Produto"`). No PostgreSQL, identificadores sem aspas são convertidos para minúsculas.

## Decisões técnicas que fazem diferença

- **Ordem cronológica de meses:** agrupo com `date_trunc('month', ...)` e só formato com `to_char` no `SELECT` final. Ordenar o texto `'MM/YY'` coloca `01/26` antes de `12/25`.
- **`NULL` em ranking:** uso `COALESCE(SUM(...), 0)` ao usar `LEFT JOIN`; no `ORDER BY ... DESC` do Postgres, `NULL` vem primeiro e bagunçaria o Pareto.
- **Empates em acumulados:** uso frame explícito (`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`) e desempate por ID, para a soma acumulada ser determinística.
- **Primeiro período do `LAG`:** deixo `NULL` em vez de `0`, pois não existe período anterior para comparar.
- **Divisão por zero:** `NULLIF(denominador, 0)` nas variações percentuais.

## Como executar

1. Tenha um PostgreSQL com o schema `vendas` e as três tabelas acima.
2. Abra qualquer arquivo em um cliente SQL (DBeaver, pgAdmin, `psql`).
3. Execute **uma consulta por vez**: cada arquivo contém várias, separadas por comentários numerados (`1.1`, `1.2`...).

## Resultados

_Adicione aqui prints dos resultados no DBeaver (pasta `img/`), por exemplo:_

<!-- ![Curva ABC](img/curva_abc.png) -->

## Ferramentas

PostgreSQL · DBeaver

## Autor

**Ronaldo** · [GitHub](https://github.com/Ronaldo-Scripth007)
