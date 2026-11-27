-- Ejercicio 1: Vista vista_detalle_ventas

DROP VIEW IF EXISTS vista_detalle_ventas;
CREATE OR REPLACE VIEW vista_detalle_ventas AS
SELECT 
	v.id AS venta_id,
	v.fecha,
	c.nombre AS cliente,
	mp.nombre AS metodo_pago,
	p.nombre AS producto,
	pr.nombre AS proveedor,
	vp.cantidad,
	vp.precio_unitario,
	(cantidad * precio_unitario) AS subtotal
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN metodos_pago mp ON v.metodo_pago_id = mp.id
JOIN venta_productos vp ON v.id = vp.venta_id
JOIN productos p ON vp.producto_id = p.id
JOIN proveedores pr ON pr.id = p.proveedor_id;


-- Ejercicio 2: Consultas sobre vista_detalle_ventas

SELECT cliente, SUM(subtotal) AS total_gastado
FROM vista_detalle_ventas
GROUP BY cliente
ORDER BY total_gastado DESC;

SELECT producto, SUM(cantidad) AS unidades_vendidas
FROM vista_detalle_ventas
GROUP BY producto
ORDER BY unidades_vendidas DESC;


-- Ejercicio 3: Vista vista_stock_bajo

DROP VIEW IF EXISTS vista_stock_bajo;
CREATE OR REPLACE VIEW vista_stock_bajo AS
SELECT
	p.id,
	p.nombre AS producto,
	p.stock AS stock,
	pr.nombre AS nombre_prov,
	pr.telefono AS tel_prov
FROM productos p
JOIN proveedores pr ON p.proveedor_id = pr.id
WHERE stock < 10;

SELECT * 
FROM vista_stock_bajo
ORDER BY stock;


-- Ejercicio 4: Vista materializada mv_ventas_por_mes

DROP MATERIALIZED VIEW IF EXISTS mv_ventas_por_mes;
CREATE MATERIALIZED VIEW mv_ventas_por_mes AS
SELECT
	DATE_TRUNC('month', v.fecha)::DATE AS mes,
	COUNT(DISTINCT v.id) AS cantidad_ventas,
	SUM(vp.cantidad * vp.precio_unitario) AS total_mes
FROM ventas v
JOIN venta_productos vp ON vp.venta_id = v.id
GROUP BY mes
ORDER BY mes;

SELECT * FROM mv_ventas_por_mes;


-- Ejercicio 5 (Índices 1): Listado en pg_indexes y columnas ya indexadas

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Las columnas que ya tienen índice son las definidas como PRIMARY KEY (id en
-- cada tabla) y cualquier columna con restricción UNIQUE.

DROP TABLE IF EXISTS prueba_indices;


-- Ejercicio 6 (Índices 2): Prueba con 1 millón de filas y EXPLAIN ANALYZE

CREATE TABLE prueba_indices AS
SELECT
    g AS id,
    (floor(random() * 10000) + 1)::INT AS cliente_id,
    (CURRENT_DATE - (floor(random() * 365))::INT) AS fecha,
    ROUND((random() * 50000 + 100)::NUMERIC, 2) AS total
FROM generate_series(1, 1000000) AS g;

EXPLAIN ANALYZE
SELECT * FROM prueba_indices WHERE cliente_id = 500;
-- 2.195 seg

CREATE INDEX idx_prueba_clientes_id ON prueba_indices(cliente_id);

EXPLAIN ANALYZE
SELECT * FROM prueba_indices WHERE cliente_id = 500;
-- 0.109 seg

DROP TABLE prueba_indices;


-- Ejercicio 7 (Índices 3): Índices en minimercado y verificación

CREATE INDEX IF NOT EXISTS idx_ventas_cliente_id ON ventas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_venta_productos_producto_id ON venta_productos(producto_id);
CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas(fecha);

SELECT 
	tablename, 
	indexname, 
	indexdef
FROM 
	pg_indexes
WHERE
	schemaname = 'public'
ORDER BY 
	tablename;


-- Ejercicio 8 (Funciones y procedimientos 1): Función fn_total_gastado

CREATE OR REPLACE FUNCTION fn_total_gastado(p_cliente_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE	
	v_total NUMERIC;
BEGIN
	SELECT COALESCE(SUM(vp.cantidad * vp.precio_unitario), 0)
	INTO v_total
	FROM ventas v
	JOIN venta_productos vp ON v.id = vp.venta_id
	WHERE v.cliente_id = p_cliente_id;
	RETURN v_total;
END;
$$;

SELECT
	c.id,
	c.nombre,
	fn_total_gastado(c.id) AS total_gastado
FROM clientes c
ORDER BY total_gastado DESC;


-- Ejercicio 9 (Funciones y procedimientos 2): Procedimiento sp_aumentar_precios

CREATE OR REPLACE PROCEDURE sp_aumentar_precios(p_proveedor_id INT, p_porcentaje NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    v_actualizados INT;
BEGIN
	UPDATE productos
	SET precio = ROUND(precio * (1 + p_porcentaje/100))
	WHERE proveedor_id = p_proveedor_id;
	
	GET DIAGNOSTICS v_actualizados = ROW_COUNT;
    RAISE NOTICE 'Se actualizaron % productos del proveedor ID %.', v_actualizados, p_proveedor_id;
END;
$$;

-- Previo al aumento
SELECT
	p.id,
	p.nombre,
	p.precio,
	pr.nombre AS proveedor
FROM productos p
JOIN proveedores pr ON p.proveedor_id = pr.id
WHERE pr.nombre = 'Lácteos del Valle'
ORDER BY p.id;

-- Aumento
DO $$
DECLARE v_prov_id INT;
BEGIN
	SELECT id INTO v_prov_id
	FROM proveedores
	WHERE nombre = 'Lácteos del Valle';

	CALL sp_aumentar_precios(v_prov_id, 10);
END;
$$;

-- Luego del aumento
SELECT
	p.id,
	p.nombre,
	p.precio,
	pr.nombre AS proveedor
FROM productos p
JOIN proveedores pr ON p.proveedor_id = pr.id
WHERE pr.nombre = 'Lácteos del Valle'
ORDER BY p.id;


-- Ejercicio 10 (Triggers 1): Trigger trg_descontar_stock

CREATE OR REPLACE FUNCTION fn_descontar_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE productos
	SET stock = stock - NEW.cantidad
	WHERE id = NEW.producto_id;
	RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_descontar_stock ON venta_productos;

CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON venta_productos
FOR EACH ROW
EXECUTE FUNCTION fn_descontar_stock();

SELECT id, nombre, stock FROM productos WHERE nombre ILIKE '%Leche Entera%';

DO $$
DECLARE
    v_venta_id INT;
    v_prod_id INT;
    v_precio NUMERIC;
BEGIN
    INSERT INTO ventas (cliente_id, fecha, metodo_pago_id)
    VALUES (1, CURRENT_DATE, 1)
    RETURNING id INTO v_venta_id;

    SELECT id, precio INTO v_prod_id, v_precio
    FROM productos
    WHERE nombre ILIKE '%Leche Entera%'
    LIMIT 1;

    INSERT INTO venta_productos (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_prod_id, 2, v_precio);
END;
$$;

SELECT id, nombre, stock FROM productos WHERE nombre ILIKE '%Leche Entera%';


-- Ejercicio 11 (Triggers 2): Intento de insertar producto con stock 0 (Jamón Cocido)

SELECT id, nombre, stock FROM productos WHERE nombre ILIKE '%Jamón Cocido%';

INSERT INTO venta_productos (venta_id, producto_id, cantidad, precio_unitario)
VALUES (
    (SELECT MAX(id) FROM ventas),
    (SELECT id FROM productos WHERE nombre ILIKE '%Jamón Cocido%' LIMIT 1),
    1,
    (SELECT precio FROM productos WHERE nombre ILIKE '%Jamón Cocido%' LIMIT 1)
);

SELECT id, nombre, stock FROM productos WHERE nombre ILIKE '%Jamón Cocido%';

-- Si la tabla `productos` tiene una restricción CHECK (stock >= 0) (lo habitual
-- en este esquema), al ejecutarse el trigger AFTER INSERT e intentar actualizar
-- `stock = 0 - 1 = -1`, PostgreSQL lanza un error de violación de restricción
-- CHECK (`new row for relation "productos" violates check constraint...`) y
-- aborta toda la sentencia.