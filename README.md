# Relatório em SQL — Northwind

## Objetivo

Este repositório tem como objetivo apresentar consultas em SQL para responder a perguntas de negócio.  
Essas análises podem ser facilmente replicadas, extraindo insights valiosos dos dados e ajudando o time de negócio a tomar decisões estratégicas.

---
## Perguntas de Negócio
1. Qual foi a receita total por ano e o crescimento em relação ao ano anterior?   
2. Quais são os 10 clientes que mais geram receita e qual o ticket médio por pedido?
3. Como evolui a receita mês a mês e o acumulado dentro do ano (YTD)?
4. Quais produtos e categorias mais vendem em receita e em quantidade?
---

## Estrutura do Banco de Dados

O banco **Northwind** simula uma empresa de importação e exportação que realiza vendas de produtos alimentícios no atacado.  
É um banco de dados ERP com informações sobre clientes, pedidos, inventário, compras, fornecedores, remessas, funcionários e contabilidade.

**Principais entidades:**
- **Customers** – Clientes
- **Orders / Order_Details** – Pedidos e itens do pedido
- **Products / Categories / Suppliers** – Produtos, categorias e fornecedores
- **Employees / Shippers** – Vendedores e transportadoras
- **Regions / Territories** – Localização geográfica

O banco inclui 14 tabelas, e os relacionamentos entre elas são mostrados no seguinte diagrama de entidades:
![[Pasted image 20251022203252.png]]

---
# Consultas para Responder às Perguntas de Negócio
## 1. Qual foi a receita total por ano e o crescimento em relação ao ano anterior?
**Insight:** mostra a evolução do faturamento e o ritmo de crescimento anual.
```SQL
WITH base as (
	SELECT
		o.order_date::date AS order_date,
		((od.unit_price * od.quantity) * (1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o on o.order_id = od.order_id
), 
receita_anual AS (
	SELECT
		to_char(order_date, 'YYYY') as ano,
		SUM(receita) as receita_total
	FROM base
	group by 1
), 
variacao as (
	SELECT
		ano,
		receita_total,
		LAG(receita_total) OVER (ORDER BY ano) AS receita_anterior
	FROM receita_anual
)
SELECT
	ano,
	receita_total,
	receita_anterior,
	round((receita_total - receita_anterior) * 100 / NULLIF(receita_anterior, 0),2) as variacao_percentual
FROM variacao	
```
## 2. Quais são os 10 clientes que mais geram receita e qual o ticket médio por pedido?
**Insight:** identifica clientes estratégicos e sua importância no faturamento.
```SQL
WITH base as (
	SELECT
	c.customer_id,
	c.company_name,
	COUNT(DISTINCT o.order_id) AS total_pedidos,
	SUM((od.unit_price  * od.quantity) * (1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o ON o.order_id = od.order_id
						  INNER JOIN customers c ON c.customer_id = o.customer_id
	group by c.customer_id, c.company_name
)
SELECT
	company_name,
	total_pedidos,
	ROUND(receita,2) AS receita_total,
	ROUND(receita/NULLIF(total_pedidos,0),2) AS ticket_medio
FROM base
ORDER BY receita_total DESC
LIMIT 10
```

## 3. Como evolui a receita mês a mês e o acumulado dentro do ano?
**Insight:** permite observar tendências sazonais e a evolução acumulada (YTD) ao longo do ano.
```SQL
WITH base as (
	SELECT
		o.order_date::date AS order_date,
		EXTRACT(YEAR FROM o.order_date)::int as ano,
		EXTRACT(MONTH FROM O.order_date)::int as mes_num,
		((od.unit_price * od.quantity) *(1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o on o.order_id = od.order_id
), acumulado_mes as (
	SELECT
		ano,
		mes_num,
		sum(receita) as receita_total
	FROM base
	GROUP BY ano, mes_num
)
select
	ano,
	mes_num,
	receita_total,
	sum(receita_total) over (
		PARTITION BY ano 
	    ORDER BY mes_num 
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS receita_ytd
from acumulado_mes
order by ano, mes_num
```

## 4. Quais produtos e categorias mais vendem em receita e em quantidade?
**Insight:** identifica os produtos “campeões de venda” e as categorias prioritárias.
```SQL
WITH base as (
	SELECT
		c.category_name,
		p.product_name,
		od.quantity,
		((od.unit_price * od.quantity) *(1 - od.discount))::numeric(12,2) as receita
	FROM order_details od INNER JOIN orders o on o.order_id = od.order_id
						  INNER JOIN products p on p.product_id = od.product_id
						  INNER JOIN categories c ON c.category_id = p.category_id 
)
SELECT 
	category_name,
	product_name,
	SUM(quantity) as unidades_vendidas,
	round(SUM(receita), 2) as receita_total,
	RANK() OVER (PARTIT
```

## Configuração Inicial

### 1. Manualmente
Utilize o arquivo SQL fornecido, `northwind.sql`, para popular o banco de dados.
### 2. Com Docker e Docker Compose

**Pré-requisitos:**  
Instale o Docker e o Docker Compose:
- [Começar com Docker](https://www.docker.com/get-started)
- [Instalar Docker Compose](https://docs.docker.com/compose/install/)
#### Passos para configuração com Docker:
1. **Iniciar o Docker Compose**  
    Execute o comando abaixo para subir os serviços:
```BASH
docker compose up -d
```

- Aguarde as mensagens de configuração, como:
```BASH
Creating network "northwind_psql_db" with driver "bridge"
Creating volume "northwind_psql_db" with default driver
Creating volume "northwind_psql_pgadmin" with default driver
Creating pgadmin ... done
Creating db ... done
```
2. **Conectar o PgAdmin**  
    Acesse o PgAdmin pelo URL: [http://localhost:5050](http://localhost:5050), com a senha `postgres`.  
    Configure um novo servidor no PgAdmin:
- **Aba General:**
    - Nome: db
- **Aba Connection:**
    - Nome do host: db
    - Nome de usuário: postgres
    - Senha: postgres

Em seguida, selecione o banco de dados **northwind**.
3. **Parar o Docker Compose**  
    Para encerrar o servidor iniciado pelo comando anterior, pressione `Ctrl + C` e remova os contêineres:

4. **Arquivos e Persistência**
Suas modificações no banco Postgres serão persistidas no volume Docker postgresql_data e poderão ser recuperadas reiniciando o Docker Compose com docker-compose up.
Para deletar os dados do banco, execute:
```BASH
docker compose down -v
```