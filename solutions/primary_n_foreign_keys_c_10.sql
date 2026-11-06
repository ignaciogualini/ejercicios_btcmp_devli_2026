
-- Relación Uno a Uno (1:1): Cada conductor tiene un solo vehículo asignado, y cada vehículo está asignado a un solo conductor.
CREATE TABLE conductores(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	licencia VARCHAR(20) UNIQUE,
	fecha_ingreso DATE
);

CREATE TABLE vehiculos(
	id SERIAL PRIMARY KEY,
	patente VARCHAR(15) UNIQUE,
	modelo VARCHAR(30),
	conductor_id INT UNIQUE REFERENCES conductores(id)
);

-- Relación Uno a Muchos (1:N): Un profesor puede dictar muchas clases, pero cada clase pertenece a un solo profesor.
CREATE TABLE profesores(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	especialidad VARCHAR(100),
	fecha_contratacion DATE
);

CREATE TABLE clases(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	horario TIME,
	profesor_id INT REFERENCES profesores(id)
);

-- Relación Muchos a Muchos (N:N): Un paciente puede tener varias enfermedades, y una enfermedad puede afectar a muchos pacientes.
CREATE TABLE pacientes(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	fecha_nacimiento DATE,
	telefono VARCHAR(15)
);

CREATE TABLE enfermedades(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	descripcion VARCHAR(100),
	nivel_gravedad VARCHAR(8) CHECK(nivel_gravedad IN ('leve', 'moderado', 'grave'))
);

CREATE TABLE pacientes_enfermedades(
	paciente_id INT REFERENCES pacientes(id),
	enfermedad_id INT REFERENCES enfermedades(id),
	fecha_diagnostico DATE,
	PRIMARY KEY (paciente_id, enfermedad_id)
);

-- Inserción de 3 valores por cada tabla --

INSERT INTO conductores(nombre, licencia, fecha_ingreso) VALUES
	('Marcelo Gallardo', '12345678', '2018-12-09'),
	('Carlos Alberto García', '98765421', '2015-05-04'),
	('Serú Girán', '42451305', '2020-03-23');

INSERT INTO vehiculos(patente, modelo, conductor_id) VALUES
	('DKP 542', 'Peugeot 206', 1),
	('JTD 280', 'Surán', 2),
	('MYD 627', 'Ferrari', 3);

INSERT INTO profesores(nombre, especialidad, fecha_contratacion) VALUES
	('Salomón Rondón', 'Ciencias naturales', '2023-03-11'),
	('Lucas Alario', 'Lengua', '2015-03-18'),
	('Benet Miranda', 'Cálculo diferencial', '2018-02-28');

INSERT INTO clases(nombre, horario, profesor_id) VALUES
	('Biología', '13:00:00', 1),
	('Cálculo', '17:30:00', 3),
	('Ecología', '15:30:00', 1);

INSERT INTO pacientes(nombre, fecha_nacimiento, telefono) VALUES
	('Lamine Martínez', '2007-05-05', '3794208871'),
	('Gonzalo Higuaín', '1932-04-04', '3783215465'),
	('Javier Milei', '2021-12-01', '3795846597');

INSERT INTO enfermedades(nombre, descripcion, nivel_gravedad) VALUES
	('COVID-19', 'Infección respiratoria aguda por el virus SARS-CoV-2', 'grave'),
	('Diabetes', 'Trastorno metabólico crónico caracterizado por niveles altos de azúcar en sangre', 'moderado'),
	('Hipertensión', 'Afección crónica donde la presión arterial hacia las paredes de las arterias es alta', 'moderado');

INSERT INTO pacientes_enfermedades(paciente_id, enfermedad_id, fecha_diagnostico) VALUES
	(3, 1, '2026-11-06'),
	(3, 2, '2026-11-05'),
	(2, 2, '2014-07-14'),
	(1, 2, '2007-06-05');


-- Testeando las constraints --

-- ERROR: new row for relation "enfermedades" violates check constraint "enfermedades_nivel_gravedad_check"
-- INSERT INTO enfermedades(nombre, descripcion, nivel_gravedad) VALUES
-- 	('Sarampión', 'enfermedad vírica aguda y altamente contagiosa que afecta principalmente a la infancia', 'maso');

-- ERROR:  duplicate key value violates unique constraint "vehiculos_conductor_id_key"
-- INSERT INTO vehiculos(patente, modelo, conductor_id) VALUES
-- 	('DIC 912', 'Fiat Duna 2004', 1);

-- ERROR:  insert or update on table "clases" violates foreign key constraint "clases_profesor_id_fkey"
-- INSERT INTO clases(nombre, horario, profesor_id) VALUES
-- 	('Física', '13:00:00', 4);