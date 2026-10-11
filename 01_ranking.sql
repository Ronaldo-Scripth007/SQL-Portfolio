/* =============================================================================
   01 | RANKING: RANK, DENSE_RANK e ROW_NUMBER
   -----------------------------------------------------------------------------
   Pergunta de negócio: quem são os clientes de maior renda e como lidar com
   empates ao montar um ranking?

   Técnicas: RANK() | DENSE_RANK() | ROW_NUMBER() | subquery para filtrar
             o resultado de uma window function
   Tabela:   vendas.clientes
   ============================================================================= */


-- 1.1 RANK vs DENSE_RANK lado a lado
--     RANK       -> empates dividem a posição e a seguinte é PULADA (1, 2, 2, 4)
--     DENSE_RANK -> empates dividem a posição e a seguinte NÃO é pulada (1, 2, 2, 3)
SELECT
    "Nome",
    "Email",
    "Renda_Anual",
    RANK()       OVER (ORDER BY "Renda_Anual" DESC) AS posicao_rank,
    DENSE_RANK() OVER (ORDER BY "Renda_Anual" DESC) AS posicao_dense_rank
FROM vendas.clientes
ORDER BY "Renda_Anual" DESC;


-- 1.2 N-ésimo valor com ROW_NUMBER: 2º cliente de maior renda
--     Window functions não podem ser filtradas no WHERE da mesma consulta,
--     por isso o ranking é calculado na subquery e filtrado por fora.
--     Atenção: ROW_NUMBER desempata de forma arbitrária. Para "2ª maior renda"
--     em caso de empate, use DENSE_RANK() = 2.
SELECT *
FROM (
    SELECT
        "Nome",
        "Email",
        "Renda_Anual",
        ROW_NUMBER() OVER (ORDER BY "Renda_Anual" DESC) AS posicao
    FROM vendas.clientes
) AS ranking
WHERE posicao = 2;
