DROP TABLE IF EXISTS prestamo_libros, prestamos, libros, autores, carnets, socios CASCADE;

-- 1:1 Socios y Carnets
-- Cada socio tiene un único carnet y viceversa, utilizando clave primaria compartida.
CREATE TABLE socios(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	DNI VARCHAR(8) UNIQUE NOT NULL CHECK (LENGTH(DNI) = 8)
);

CREATE TABLE carnets(
	id_socio INT PRIMARY KEY REFERENCES socios(id),
	codigo_carnet VARCHAR(50) NOT NULL
);

-- 1:N Autores y Libros
-- Un autor puede escribir varios libros, pero cada libro pertenece a un solo autor.
CREATE TABLE autores(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	nacionalidad VARCHAR(30)
);

CREATE TABLE libros(
	id SERIAL PRIMARY KEY,
	titulo VARCHAR(100) NOT NULL,
	year_publ INT,
	id_autor INT NOT NULL REFERENCES autores(id)
);

-- 1:N Socios y Préstamos
-- Un socio puede realizar múltiples préstamos a lo largo del tiempo.
CREATE TABLE prestamos(
	id SERIAL PRIMARY KEY,
	fecha DATE DEFAULT CURRENT_DATE,
	id_socio INT REFERENCES socios(id)
);

-- N:M Préstamos y Libros
-- Un préstamo puede incluir varios libros y un libro puede estar presente en diferentes préstamos.
CREATE TABLE prestamo_libros(
	id_prestamo INT REFERENCES prestamos(id),
	id_libro INT REFERENCES libros(id),
	PRIMARY KEY (id_prestamo, id_libro)
);


INSERT INTO socios (nombre, DNI) VALUES 
('Lucía Gómez', '38456789'),
('Carlos Pérez', '41234567'),
('Sofía Benítez', '35987654');

INSERT INTO carnets (id_socio, codigo_carnet) VALUES 
(1, 'CARNET-001'),
(2, 'CARNET-002'),
(3, 'CARNET-003');

INSERT INTO autores (nombre, nacionalidad) VALUES 
('Jorge Luis Borges', 'Argentina'),
('Gabriel García Márquez', 'Colombiana'),
('Julio Cortázar', 'Argentina');

INSERT INTO libros (titulo, year_publ, id_autor) VALUES 
('Ficciones', 1944, 1),
('Cien años de soledad', 1967, 2),
('Rayuela', 1963, 3);

INSERT INTO prestamos (fecha, id_socio) VALUES 
('2026-11-01', 1),
('2026-11-05', 2),
(DEFAULT, 1);

INSERT INTO prestamo_libros (id_prestamo, id_libro) VALUES 
(1, 1), -- El préstamo 1 incluye el libro 1
(1, 2), -- El préstamo 1 también incluye el libro 2
(2, 3), -- El préstamo 2 incluye el libro 3
(3, 2); -- El préstamo 3 incluye el libro 2