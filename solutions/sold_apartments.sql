-- PARTE 1: DEPARTAMENTOS EN VENTA/ALQUILER

DROP TABLE IF EXISTS apartments;
-- Creación de la tabla apartments
CREATE TABLE apartments(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	address VARCHAR(100),
	city VARCHAR(50),
	postal_code VARCHAR(10),
	bedrooms INT,
	area_m2 NUMERIC(6, 2),
	price NUMERIC(10, 2),
	available BOOLEAN,
	published_date DATE
);

-- Inserción de al menos 30 filas inventadas
INSERT INTO apartments (name, address, city, postal_code, bedrooms, area_m2, price, available, published_date) VALUES
('Depto A', 'Av. Siempre Viva 123', 'Buenos Aires', 'C1000', 2, 55.5, 120000, TRUE, '2023-08-01'),
('Loft Palermo', 'Honduras 4300', 'Buenos Aires', 'C1414', 1, 40.0, 95000, TRUE, '2023-08-02'),
('Piso Belgrano', 'Cabildo 2000', 'Buenos Aires', 'C1428', 3, 90.0, 180000, FALSE, '2023-08-03'),
('Depto Centro', 'Corrientes 900', 'Rosario', 'S2000', 2, 60.0, 105000, TRUE, '2023-08-04'),
('Casa Norte', 'Av. Alberdi 150', 'Rosario', 'S2013', 4, 120.0, 210000, TRUE, '2023-08-05'),
('Monoambiente', 'San Martin 50', 'Cordoba', 'X5000', 1, 30.0, 55000, FALSE, '2023-08-06'),
('Duplex Sur', 'Av. Velez Sarsfield 800', 'Cordoba', 'X5000', 2, 75.0, 130000, TRUE, '2023-08-07'),
('Depto Rio', 'Costanera 100', 'Corrientes', 'W3400', 2, 65.0, 110000, TRUE, '2023-08-08'),
('Torre Alta 1', 'Junin 1200', 'Corrientes', 'W3400', 3, 85.0, 145000, FALSE, '2023-08-09'),
('Torre Alta 2', 'Junin 1200', 'Corrientes', 'W3400', 1, 45.0, 80000, TRUE, '2023-08-10'),
('Estudio 1', 'Mendoza 400', 'Mendoza', 'M5500', 1, 35.0, 60000, TRUE, '2023-08-11'),
('Piso 5', 'San Martin 1200', 'Mendoza', 'M5500', 3, 100.0, 160000, TRUE, '2023-08-12'),
('Depto Familiar', 'Av. Mitre 500', 'Avellaneda', 'B1870', 4, 110.0, 175000, FALSE, '2023-08-13'),
('Loft Soho', 'Gorriti 5500', 'Buenos Aires', 'C1414', 1, 50.0, 115000, TRUE, '2023-08-14'),
('Piso 12', 'Av. del Libertador 3000', 'Buenos Aires', 'C1425', 4, 150.0, 350000, TRUE, '2023-08-15'),
('Depto B', 'Callao 1500', 'Buenos Aires', 'C1024', 2, 70.0, 140000, FALSE, '2023-08-16'),
('Mono Centro', 'Mitre 800', 'Rosario', 'S2000', 1, 28.0, 48000, TRUE, '2023-08-17'),
('Domo 3', 'Pellegrini 1200', 'Rosario', 'S2000', 2, 62.0, 115000, TRUE, '2023-08-18'),
('Casa Rio', 'Rondeau 300', 'Rosario', 'S2013', 3, 95.0, 160000, FALSE, '2023-08-19'),
('Depto U', 'Colón 400', 'Cordoba', 'X5000', 1, 42.0, 72000, TRUE, '2023-08-20'),
('Piso 2', 'General Paz 150', 'Cordoba', 'X5000', 2, 68.0, 125000, TRUE, '2023-08-21'),
('Duplex C', 'Av. 3 de Abril 900', 'Corrientes', 'W3400', 2, 80.0, 135000, TRUE, '2023-08-22'),
('Estudio Sur', 'Salta 600', 'Corrientes', 'W3400', 1, 38.0, 65000, FALSE, '2023-08-23'),
('Depto X', 'Sarmiento 200', 'Mendoza', 'M5500', 2, 55.0, 95000, TRUE, '2023-08-24'),
('Casa Viña', 'Belgrano 1000', 'Mendoza', 'M5500', 3, 115.0, 185000, TRUE, '2023-08-25'),
('Depto 8', 'Alsina 100', 'Avellaneda', 'B1870', 2, 58.0, 85000, FALSE, '2023-08-26'),
('Torre Sur 4', 'Av. de Mayo 900', 'Buenos Aires', 'C1084', 3, 85.0, 165000, TRUE, '2023-08-27'),
('Mono 2', 'Santa Fe 2500', 'Buenos Aires', 'C1425', 1, 32.0, 75000, TRUE, '2023-08-28'),
('Piso 9', 'Oroño 500', 'Rosario', 'S2000', 4, 130.0, 240000, FALSE, '2023-08-29'),
('Depto Z', 'San Juan 800', 'Cordoba', 'X5000', 2, 65.0, 110000, TRUE, '2023-08-30');

-- Ejercicio 1: Mostrar los departamentos disponibles, ordenados del más barato al más caro.
SELECT name, price 
FROM apartments 
ORDER BY price ASC;

-- Ejercicio 2: Mostrar el precio promedio por ciudad.	
SELECT city, AVG(price) 
FROM apartments 
GROUP BY city;

-- Ejercicio 3: Mostrar los departamentos con 2 o más habitaciones y menos de 60 m².
SELECT name, bedrooms, area_m2
FROM apartments 
WHERE bedrooms >= 2 AND area_m2 < 60;


-- PARTE 2: VENTAS

DROP TABLE IF EXISTS sales;
-- Creación de la tabla sales
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product VARCHAR(50),
    category VARCHAR(30),
    price NUMERIC,
    quantity INT,
    sale_date DATE
);

-- Inserción de los datos de ventas provistos en la tarea
INSERT INTO sales (product, category, price, quantity, sale_date) VALUES
('Mouse', 'Electronics', 15, 4, '2023-07-10'),
('Keyboard', 'Electronics', 30, 2, '2023-07-11'),
('Notebook', 'Stationery', 8, 10, '2023-07-12'),
('Pen', 'Stationery', 2, 25, '2023-07-13'),
('Headphones', 'Electronics', 40, 3, '2023-07-14'),
('Monitor', 'Electronics', 120, 1, '2023-07-15'),
('Desk Chair', 'Furniture', 85, 2, '2023-07-16'),
('Notebook Case', 'Accessories', 25, 3, '2023-07-17'),
('Printer Paper', 'Stationery', 6, 15, '2023-07-18'),
('USB Drive', 'Electronics', 12, 5, '2023-07-19'),
('Desk Lamp', 'Furniture', 35, 4, '2023-07-20'),
('Stapler', 'Stationery', 7, 6, '2023-07-21'),
('Calculator', 'Electronics', 20, 3, '2023-07-22'),
('Water Bottle', 'Accessories', 10, 8, '2023-07-23'),
('Laptop Stand', 'Accessories', 45, 2, '2023-07-24'),
('Office Desk', 'Furniture', 150, 1, '2023-07-25'),
('Whiteboard', 'Furniture', 60, 1, '2023-07-26'),
('Marker Set', 'Stationery', 5, 12, '2023-07-27'),
('Mouse Pad', 'Accessories', 8, 7, '2023-07-28'),
('Webcam', 'Electronics', 50, 2, '2023-07-29'),
('Smartphone', 'Electronics', 300, 1, '2023-07-30'),
('Notebook Pro', 'Electronics', 900, 1, '2023-07-31'),
('File Cabinet', 'Furniture', 120, 1, '2023-08-01'),
('Backpack', 'Accessories', 40, 3, '2023-08-02'),
('Binder', 'Stationery', 4, 20, '2023-08-03'),
('Headset Stand', 'Accessories', 15, 5, '2023-08-04'),
('Desk Organizer', 'Accessories', 12, 6, '2023-08-05'),
('Laptop Sleeve', 'Accessories', 30, 2, '2023-08-06'),
('Paper Clips', 'Stationery', 1, 50, '2023-08-07'),
('Surge Protector', 'Electronics', 25, 3, '2023-08-08'),
('Pen Holder', 'Accessories', 5, 10, '2023-08-09');

-- Ejercicio 1: Mostrar todas las ventas de la categoría 'Electronics'.
SELECT * 
FROM sales 
WHERE category = 'Electronics';

-- Ejercicio 2: Calcular el total de ingresos por categoría (price * quantity).
SELECT category, SUM(price * quantity) AS total_income 
FROM sales 
GROUP BY category;

-- Ejercicio 3: Obtener la categoría con mayor ingreso total.
SELECT category, SUM(price * quantity) AS total_income 
FROM sales 
GROUP BY category 
ORDER BY total_income DESC LIMIT 1;

-- Ejercicio 4: Mostrar todas las ventas donde el precio del producto sea mayor a 20.
SELECT * 
FROM sales 
WHERE price > 20;

-- Ejercicio 5: Calcular el total de unidades vendidas (SUM(quantity)) por cada producto.
SELECT product, SUM(quantity) AS sold_units 
FROM sales 
GROUP BY product;

-- Ejercicio 6: Calcular el ingreso promedio por venta (AVG(price * quantity)) para cada producto.
SELECT product, AVG(price * quantity) AS avg_income 
FROM sales 
GROUP BY product;

-- Ejercicio 7: Mostrar los 3 productos con mayor cantidad total vendida (SUM(quantity)) usando ORDER BY y LIMIT.
SELECT product, SUM(quantity) AS sold_units 
FROM sales 
GROUP BY product 
ORDER BY sold_units DESC LIMIT 3;

-- Ejercicio 8: Mostrar todas las ventas realizadas después del 12 de julio de 2023.
SELECT * 
FROM sales 
WHERE sale_date > '2023-07-12';

-- Ejercicio 9: Mostrar la categoría y el ingreso total, pero solo para categorías cuyo ingreso sea mayor a 50 (HAVING SUM(price * quantity) > 50).
SELECT category, SUM(price * quantity) AS total_income 
FROM sales 
GROUP BY category 
HAVING SUM(price * quantity) > 50;

-- Ejercicio 10: Mostrar todas las ventas donde el nombre del producto comience con la letra H (LIKE 'H%').
SELECT * 
FROM sales 
WHERE product LIKE 'H%';

-- Ejercicio 11: Calcular la cantidad promedio de productos vendidos (AVG(quantity)) agrupados por categoría.
SELECT category, AVG(quantity) 
FROM sales 
GROUP BY category;

-- Ejercicio 12: Mostrar todas las ventas y calcular el ingreso por fila (price * quantity), ordenadas de mayor a menor ingreso.
SELECT *, price * quantity as income 
FROM sales 
ORDER BY price * quantity DESC;

-- Ejercicio 13: Mostrar todas las ventas de la categoría 'Electronics' donde la cantidad sea mayor a 2 y el precio menor a 40.
SELECT * 
FROM sales
WHERE category = 'Electronics' AND quantity > 2 AND price < 40; 