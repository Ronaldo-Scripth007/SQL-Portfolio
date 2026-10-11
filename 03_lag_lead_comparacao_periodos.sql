/* =============================================================================
   03 | COMPARAÇÃO ENTRE PERÍODOS: LAG e LEAD
   -----------------------------------------------------------------------------
   Pergunta de negócio: quanto as vendas variaram em relação ao mês anterior
   (MoM) e ao mesmo mês do ano anterior (YoY)?

   Técnicas: LAG() | LEAD() | NULLIF para evitar divisão por zero
   Tabela:   vendas.pedidos
   ============================================================================= */


-- 3.1 Variação mês a mês (MoM), em unidades e em %
--     LAG(coluna, 1) olha 1 linha para trás. Sem valor DEFAULT, o primeiro mês
--     fica NULL (correto: não existe mês anterior). Usar DEFAULT 0 faria a
--     "diferença" do primeiro mês ser igual ao total, distorcendo a análise.
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
    LAG(total_vendido) OVER (ORDER BY mes) AS mes_anterior,
    total_vendido - LAG(total_vendido) OVER (ORDER BY mes) AS diferenca,
    ROUND(
        100.0 * (total_vendido - LAG(total_vendido) OVER (ORDER BY mes))
        / NULLIF(LAG(total_vendido) OVER (ORDER BY mes), 0)
    , 2) AS variacao_pct
FROM vendas_mensais
ORDER BY mes;


-- 3.2 Análise YoY: basta mudar o deslocamento do LAG para 12 meses.
--     (Só retorna valores quando a base tiver mais de 12 meses de histórico.)
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
    LAG(total_vendido, 12) OVER (ORDER BY mes) AS mesmo_mes_ano_anterior
FROM vendas_mensais
ORDER BY mes;


-- 3.3 LEAD: o inverso do LAG, olha para as linhas SEGUINTES.
--     Útil para comparar com o próximo período (ex.: 2 meses à frente).
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
    LEAD(total_vendido, 2) OVER (ORDER BY mes) AS vendas_daqui_2_meses
FROM vendas_mensais
ORDER BY mes;
