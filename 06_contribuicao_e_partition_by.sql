/* =============================================================================
   06 | CONTRIBUIÇÃO PERCENTUAL E ANÁLISE SEGMENTADA (PARTITION BY)
   -----------------------------------------------------------------------------
   Pergunta de negócio: quanto cada mês representa do total vendido e quais são
   os produtos mais caros DENTRO de cada marca?

   Técnicas: SUM() OVER () | PARTITION BY | RANK() particionado
   Tabelas:  vendas.pedidos, vendas.produtos
   ============================================================================= */


-- 6.1 Participação de cada mês no total geral
--     SUM(SUM(x)) OVER () = soma de todas as linhas já agregadas por mês.
--     OVER () vazio significa "janela = resultado inteiro".
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
    ROUND(100.0 * total_vendido / SUM(total_vendido) OVER (), 2) AS pct_do_total
FROM vendas_mensais
ORDER BY mes;


-- 6.2 Ranking de preço dentro de cada marca (PARTITION BY)
--     PARTITION BY reinicia o ranking a cada marca: é como um GROUP BY que
--     NÃO colapsa as linhas.
SELECT
    p."Marca_Produto",
    p."Nome_Produto",
    p."Preco_Unit",
    RANK() OVER (
        PARTITION BY p."Marca_Produto"
        ORDER BY p."Preco_Unit" DESC
    ) AS posicao_na_marca
FROM vendas.produtos p
ORDER BY p."Marca_Produto", posicao_na_marca;


-- 6.3 Aplicação prática: produto mais caro de cada marca
--     O ranking é calculado na subquery e filtrado por fora.
SELECT "Marca_Produto", "Nome_Produto", "Preco_Unit"
FROM (
    SELECT
        p."Marca_Produto",
        p."Nome_Produto",
        p."Preco_Unit",
        RANK() OVER (
            PARTITION BY p."Marca_Produto"
            ORDER BY p."Preco_Unit" DESC
        ) AS posicao_na_marca
    FROM vendas.produtos p
) AS ranking
WHERE posicao_na_marca = 1
ORDER BY "Marca_Produto";
