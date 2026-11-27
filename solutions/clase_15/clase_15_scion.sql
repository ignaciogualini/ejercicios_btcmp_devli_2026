-- Listar todos los clientes
SELECT * FROM customers;

-- Nombre de prod y precio unitario
SELECT product_name, unit_price FROM products;

-- Prod con precio > 50
SELECT product_name, unit_price
FROM products
WHERE unit_price > 50;

-- Clientes ordena2 por país
SELECT 
	contact_name, 
	country
FROM customers
ORDER BY country;

-- Cantidad total de pedidos
SELECT COUNT(*) FROM orders;

-- Prod con stock bajo (< 10 unidades)
SELECT product_name, units_in_stock
FROM products
WHERE units_in_stock < 10;

-- Join simple (prod y proveedor)
SELECT p.product_name, s.contact_name AS supplier_name, s.company_name AS supplier_company
FROM products p
JOIN suppliers s ON p.supplier_id = s.supplier_id;

-- JOIN c filtro (productos caros y su categoría)
SELECT p.product_name, p.unit_price, c.category_name
FROM products p 
JOIN categories c ON c.category_id = p.category_id
WHERE p.unit_price > 50
ORDER BY p.unit_price;

-- JOIN múltiple (pedidos con cliente y empleado)
SELECT 
	o.order_id AS id, 
	o.order_date, 
	c.contact_name AS customer_name,
	c.company_name AS customer_company,
	e.first_name || ' ' || e.last_name AS employee_name
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN employees e ON e.employee_id = o.employee_id;

-- JOIN múltiple c filtros (pedidos envia2 a Germany)
SELECT
	c.company_name,
	p.product_name,
	od.quantity,
	o.ship_country
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_details od ON od.order_id = o.order_id
JOIN products p ON p.product_id = od.product_id
WHERE o.ship_country = 'Germany';

-- SELF JOIN (cada empleado y su jefe)
SELECT 
	e.first_name ||' '|| e.last_name AS employee_name,
	b.first_name ||' '|| b.last_name AS boss_name
FROM employees e
JOIN employees b ON e.reports_to = b.employee_id;

-- ¿Cuánto vendimos por categoría?
SELECT c.category_name,
       ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric, 2) AS total_ventas
FROM order_details od
JOIN products p   ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_ventas DESC;

-- Creo un nuevo esquema para versión normalizada
DROP SCHEMA IF EXISTS northwind_olap CASCADE;
CREATE SCHEMA IF NOT EXISTS northwind_olap;

CREATE TABLE northwind_olap.fact_sales AS
SELECT
	od.order_id,
	o.order_date,
	o.customer_id,
	o.employee_id,
	o.ship_via,
	od.product_id,
	od.quantity,
	od.unit_price,
	od.discount,
	od.quantity * od.unit_price * (1 - od.discount) AS final_amount
FROM public.orders o
JOIN public.order_details od ON o.order_id = od.order_id;

-- DIM CUSTOMER QUIÉN COMPRA
CREATE TABLE northwind_olap.dim_customer AS
SELECT
	customer_id,
	company_name,
	contact_name,
	country,
	city,
	region
FROM public.customers

-- DIM EMPLOYEE QUIÉN VENDE
CREATE TABLE northwind_olap.dim_employee AS
SELECT
	employee_id,
	first_name,
	last_name,
	title,
	country,
	city
FROM public.employees;

-- DIM shipper cómo se envía
CREATE TABLE northwind_olap.dim_shipper AS
SELECT
	shipper_id,
	company_name AS shipper_name
FROM public.shippers;

-- DIM date cuándo
CREATE TABLE northwind_olap.dim_date AS
SELECT DISTINCT
    order_date::date AS date_key,
    EXTRACT(YEAR FROM order_date)::int    AS year,
    EXTRACT(QUARTER FROM order_date)::int AS quarter,
    EXTRACT(MONTH FROM order_date)::int   AS month,
    TO_CHAR(order_date, 'FMMonth')        AS month_name,
    EXTRACT(DAY FROM order_date)::int     AS day,
    EXTRACT(DOW FROM order_date)::int     AS weekday,
    TO_CHAR(order_date, 'FMDay')          AS weekday_name
FROM public.orders
WHERE order_date IS NOT NULL;

-- DIM PRODUCT QUÉ SE VENDE
CREATE TABLE northwind_olap.dim_product AS
SELECT
	p.product_id,
	p.product_name,
	c.category_name,
	s.company_name AS supplier_name
FROM products p
JOIN categories c ON c.category_id = p.category_id
JOIN suppliers s ON s.supplier_id = p.supplier_id;

-- Usando el nuevo esquema, ¿cuánto se vendió por categoría?
SELECT 
	p.category_name,
	SUM(f.quantity) AS total_units_sold
FROM northwind_olap.dim_product p 
JOIN northwind_olap.fact_sales f ON p.product_id = f.product_id
GROUP BY p.category_name
ORDER BY total_units_sold DESC;

-- Ventas totales por producto
SELECT
	p.product_name,
	SUM(f.quantity) AS total_units_sold
FROM northwind_olap.dim_product p
JOIN northwind_olap.fact_sales f ON p.product_id = f.product_id
GROUP BY p.product_name
ORDER BY total_units_sold;

-- Venta por país del cliente
SELECT 
	c.country,
	SUM(f.quantity) AS total_units_sold
FROM northwind_olap.dim_customer c
JOIN northwind_olap.fact_sales f ON f.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_units_sold;

-- Ventas por emplea2
SELECT
	e.first_name ||' '|| e.last_name AS full_name,
	SUM(f.quantity) AS total_units_sold
FROM northwind_olap.dim_employee e
JOIN northwind_olap.fact_sales f ON e.employee_id = f.employee_id
GROUP BY full_name
ORDER BY total_units_sold;

-- Ventas mensuales
SELECT
	d.month_name,
	SUM(f.quantity) AS total_units_sold
FROM northwind_olap.dim_date d
JOIN northwind_olap.fact_sales f ON d.date_key = f.order_date
GROUP BY d.month_name
ORDER BY total_units_sold;

-- Top 10 clientes
SELECT
	c.company_name,
	SUM(f.quantity) AS total_units_sold
FROM northwind_olap.dim_customer c
JOIN northwind_olap.fact_sales f ON c.customer_id = f.customer_id
GROUP BY c.company_name
ORDER BY total_units_sold DESC LIMIT 10;

-- Ventas por empresa de envío
SELECT
	s.shipper_name,
	SUM(f.quantity) AS total_units_sold
FROM northwind_olap.dim_shipper s
JOIN northwind_olap.fact_sales f ON s.shipper_id = f.ship_via
GROUP BY s.shipper_name
ORDER BY total_units_sold DESC;