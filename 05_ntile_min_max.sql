/* =============================================================================
   05 | FAIXAS E EXTREMOS: NTILE, MIN e MAX em janela
   -----------------------------------------------------------------------------
   Pergunta de negócio: como segmentar clientes por renda e qual foi o menor e
   o maior volume de vendas nos últimos 3 meses?

   Técnicas: NTILE() | MIN()/MAX() OVER com frame | agregação aninhada
   Tabelas:  vendas.clientes, vendas.pedidos
   ============================================================================= */


-- 5.1 Quartis de renda com NTILE(4)
--     Divide os clientes em 4 grupos de tamanho (quase) igual.
--     Faixa 1 = 25% de maior renda | Faixa 4 = 25% de menor renda.
SELECT
    c."ID_Cliente",
    c."Nome",
    c."Renda_Anual",
    NTILE(4) OVER (ORDER BY c."Renda_Anual" DESC) AS faixa_renda
FROM vendas.clientes c
ORDER BY faixa_renda, c."Renda_Anual" DESC;


-- 5.2 Menor e maior volume mensal dentro da janela dos últimos 3 meses
--     SUM() é a agregação do GROUP BY; MIN()/MAX() OVER é a window function
--     aplicada sobre o resultado já agregado.
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
    MIN(total_vendido) OVER (
        ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS minimo_3_meses,
    MAX(total_vendido) OVER (
        ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS maximo_3_meses
FROM vendas_mensais
ORDER BY mes;
