/* =============================================================================
   00 | CRIAÇÃO DO SCHEMA E DAS TABELAS
   -----------------------------------------------------------------------------
   Execute este arquivo ANTES das demais consultas.
   Depois, carregue os dados (arquivos da pasta dados/) e rode os arquivos 01 a 06.

   Relacionamentos (lógicos: o banco não declara chaves estrangeiras):
     pedidos.ID_Cliente    -> clientes.ID_Cliente
     pedidos.ID_Produto    -> produtos.ID_Produto
     pedidos.ID_Loja       -> lojas.ID_Loja
     produtos.ID_Categoria -> categorias.ID_Categoria
   A tabela locais (Cidade, Estado, Região) não tem coluna de ligação com as demais.

   Observação: Data_Venda e Data_Nascimento são do tipo text. As consultas
   convertem para data com "Data_Venda"::date.
   ============================================================================= */

CREATE SCHEMA IF NOT EXISTS vendas;


-- Categorias de produtos
CREATE TABLE IF NOT EXISTS vendas.categorias (
    "ID_Categoria" int4 NULL,
    "Categoria"    text NULL
);


-- Clientes
CREATE TABLE IF NOT EXISTS vendas.clientes (
    "ID_Cliente"      int4 NULL,
    "Nome"            text NULL,
    "Sobrenome"       text NULL,
    "Data_Nascimento" text NULL,
    "Estado_Civil"    text NULL,
    "Sexo"            text NULL,
    "Email"           text NULL,
    "Telefone"        text NULL,
    "Renda_Anual"     int4 NULL,
    "Qtd_Filhos"      int4 NULL,
    "Escolaridade"    text NULL
);


-- Localidades
CREATE TABLE IF NOT EXISTS vendas.locais (
    "Cidade" text NULL,
    "Estado" text NULL,
    "Região" text NULL
);


-- Lojas
CREATE TABLE IF NOT EXISTS vendas.lojas (
    "ID_Loja"          int4 NULL,
    "Loja"             text NULL,
    "Gerente"          text NULL,
    "Endereco"         text NULL,
    "Num_Funcionarios" int4 NULL,
    "Telefone"         text NULL
);


-- Produtos
CREATE TABLE IF NOT EXISTS vendas.produtos (
    "ID_Produto"    int4    NULL,
    "Nome_Produto"  text    NULL,
    "ID_Categoria"  int4    NULL,
    "Marca_Produto" text    NULL,
    "Num_Serie"     text    NULL,
    "Preco_Unit"    int4    NULL,
    "Custo_Unit"    numeric NULL
);


-- Pedidos (uma linha por venda)
CREATE TABLE IF NOT EXISTS vendas.pedidos (
    "ID_Pedido"     int4    NULL,
    "Data_Venda"    text    NULL,
    "ID_Loja"       int4    NULL,
    "ID_Produto"    int4    NULL,
    "ID_Cliente"    int4    NULL,
    "Qtd_Vendida"   int4    NULL,
    "Receita_Venda" int4    NULL,
    "Custo_Venda"   numeric NULL,
    "Custo_Unit"    numeric NULL,
    "Preco_Unit"    int4    NULL
);
