/* =============================================================================
   02 | MÉDIAS MÓVEIS
   -----------------------------------------------------------------------------
   Pergunta de negócio: a receita está subindo ou caindo, descontando as
   oscilações mensais?

   Técnicas: AVG() OVER com frame (ROWS BETWEEN ... PRECEDING AND CURRENT ROW)
             | agregação dentro de CTE | date_trunc para ordem cronológica
   Tabela:   vendas.pedidos
   ============================================================================= */


-- Média móvel de 3 meses da receita.
-- Boas práticas aplicadas:
--   * date_trunc('month', ...) agrupa e ORDENA cronologicamente. Ordenar pelo
--     texto 'MM/YY' não funciona (01/26 viria antes de 12/25).
--   * A formatação do mês (to_char) fica só no SELECT final, para exibição.
--   * Nos 2 primeiros meses a média usa menos de 3 pontos (não há histórico).
WITH receita_mensal AS (
    SELECT
        date_trunc('month', "Data_Venda"::date) AS mes,
        SUM("Receita_Venda")                    AS receita_mes
    FROM vendas.pedidos
    GROUP BY date_trunc('month', "Data_Venda"::date)
)
SELECT
    to_char(mes, 'MM/YY') AS "Mês",
    receita_mes,
    ROUND(
        AVG(receita_mes) OVER (
            ORDER BY mes
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric, 2
    ) AS media_movel_3_meses
FROM receita_mensal
ORDER BY mes;
