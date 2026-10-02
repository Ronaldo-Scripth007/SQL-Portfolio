-- FUNÇOES DE JANELAS - RANK E DESE_RAK

SELECT *FROM vendas.clientes c;

SELECT  
	"Nome", "Email", "Renda_Anual",
	rank() over(ORDER BY "Renda_Anual" DESC) AS "Posição"
FROM vendas.clientes;



-- DENSE RANK > NÃO PULA POSIÇÃO. SEMPRE SEGUE A ORDEM

SELECT 
	"Nome", "Email", "Renda_Anual", 
	dense_rank() OVER(ORDER BY "Renda_Anual" DESC )AS "Posição"
FROM VENDAS.clientes;








