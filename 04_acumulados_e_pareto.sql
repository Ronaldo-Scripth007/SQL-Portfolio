/* =============================================================================
   04 | ACUMULADOS E CURVA ABC (PARETO)
   -----------------------------------------------------------------------------
   Pergunta de negócio: quanto já vendemos no acumulado do período e quais
   produtos concentram 80% da receita?

   Técnicas: SUM() OVER (ORDER BY ...) | frame explícito | CTE | CASE
   Tabelas:  vendas.pedidos, vendas.produtos
   ============================================================================= */


-- 4.1 Soma acumulada de unidades vendidas por mês
WITH vendas_mensais AS (
    SELECT
        date_trunc('month', "Data_Venda"::date) AS mes,
        SUM("Qtd_Vendida")                      AS total_vendido
    FROM vendas.pedidos
    GROUP BY date_trunc('month', "Data_Venda"::date)
)
SELECT
    to_char(mes, 'MM/YY') AS "Mês",
    total_vendido,
    SUM(total_vendido) OVER (
        ORDER BY mes
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS acumulado
FROM vendas_mensais
ORDER BY mes;


-- 4.2 Percentual acumulado de receita por produto + classificação ABC
--     Passos:
--       1) receita total por produto (LEFT JOIN mantém produtos sem venda)
--       2) soma acumulada ordenada da maior para a menor receita
--       3) divisão pelo total geral  ->  % acumulado
--       4) CASE transforma o % em classe: A (até 80%), B (até 95%), C (resto)
--
--     Detalhes que evitam resultados errados:
--       * COALESCE(..., 0): sem ele, produtos sem venda ficam com receita NULL
--         e, no ORDER BY ... DESC do Postgres, NULL aparece PRIMEIRO.
--       * Frame ROWS explícito + desempate por ID: com empates de receita, o
--         frame padrão (RANGE) somaria as linhas empatadas de uma só vez.
WITH receita AS (
    SELECT
        p."ID_Produto",
        p."Nome_Produto",
        COALESCE(SUM(pe."Receita_Venda"), 0) AS receita_total
    FROM vendas.produtos p
    LEFT JOIN vendas.pedidos pe
           ON pe."ID_Produto" = p."ID_Produto"
    GROUP BY p."ID_Produto", p."Nome_Produto"
),
acumulado AS (
    SELECT
        "ID_Produto",
        "Nome_Produto",
        receita_total,
        100.0 * SUM(receita_total) OVER (
                    ORDER BY receita_total DESC, "ID_Produto"
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                )
              / NULLIF(SUM(receita_total) OVER (), 0) AS pct_acumulado
    FROM receita
)
SELECT
    "ID_Produto",
    "Nome_Produto",
    receita_total,
    ROUND(pct_acumulado::numeric, 2) AS pct_acumulado,
    CASE
        WHEN pct_acumulado <= 80 THEN 'A'
        WHEN pct_acumulado <= 95 THEN 'B'
        ELSE 'C'
    END AS classe_abc
FROM acumulado
ORDER BY receita_total DESC, "ID_Produto";
