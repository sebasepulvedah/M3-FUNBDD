-- MYSQL VISUAL STUDIO CODES

-- CREACION DE TABLAS

CREATE TABLE transacciones (
    id int auto_increment primary key,
    remitente_usuarios_id int NOT NULL,
    destinatario_usuarios_id int NOT NULL,
    importe int DEFAULT 0,
    fecha_transaccion datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_remitente_usuarios_id 
    FOREIGN KEY (remitente_usuarios_id) REFERENCES usuarios(id)
    ON UPDATE CASCADE 
    ON DELETE CASCADE, 
    CONSTRAINT fk_destinatario_usuarios_id 
    foreign key (destinatario_usuarios_id) references usuarios(id)
    ON UPDATE CASCADE 
    ON DELETE CASCADE
    );

-- Se crea como “usuario” para luego realizar alter table usuarios.
CREATE TABLE usuario (
    id int NOT NULL AUTO_INCREMENT,
    nombre varchar(100) NOT NULL,
    email varchar(100) NOT NULL,
    contraseña varchar(45) NOT NULL,
    saldo int NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `email_UNIQUE` (`email`)
);

CREATE TABLE `monedas` (
    `id` int NOT NULL AUTO_INCREMENT,
    `nombre` varchar(45) NOT NULL,
    `simbolo` char(3) NOT NULL,
    PRIMARY KEY (`id`)
);

-- INSERT
--TABLA USUARIOS 
INSERT INTO usuarios (nombre, email, contraseña)
VALUES('Sebastian','sebastian@ejemplo.com','12345'), ('Andrea','andrea@ejemplo.com','12345'), ('Jose','jose@ejemplo.com','12345'),
('Pedro','pedro@ejemplo.com','12345'), ('Luis','luis@ejemplo.com','12345'), ('Pamela','pamela@ejemplo.com','12345'), ('Alberto','alberto@ejemplo.com','12345')
;
--Se agrega UNIQUE email para que no se dupliquen correos.
--Comprobamos: 
INSERT INTO usuarios (nombre, email, contraseña)
VALUES('Sebastian','sebastian@ejemplo.com','12345')
;


-- Para comprobar Default de saldo
INSERT INTO usuarios (nombre, email, contraseña)
VALUES('Alberto','alberto@ejemplo.com','12345')
;

-- Se crea otro usuario sebastian pero con distinto correo para hacer la búsqueda de where sebastian%
INSERT INTO usuarios (nombre, email, contraseña, saldo)
VALUES('Sebastian','seba@ejemplo.com','12345','100000'); 
-- TABLA MONEDAS
INSERT INTO monedas (`id`, `nombre`, `simbolo`) 
VALUES('1', 'peso chileno','CLP'), ('2', 'euro', 'EUR'),('3', ' peso Colombiano', 'COP'), 
('4', 'peso argentino', 'ARS'),('5','dolar','USD'),('6','real Brasileño','BSL')
;

-- TABLA TRANSACCIONES
-- POR DEFAULT DEBERIA ESTAR SIN IMPORTE NI MONEDA_ID, pero se agregaron para mostrar la tabla.
INSERT INTO transacciones (remitente_usuarios_id, destinatario_usuarios_id, importe, moneda_id) VALUES ('1', '2', '20000', '2');
INSERT INTO transacciones (remitente_usuarios_id, destinatario_usuarios_id, importe, moneda_id) VALUES ('2', '3', '111', '3');

-- SELECT
SELECT * FROM alkewallet.usuarios;
SELECT * FROM alkewallet.monedas;
SELECT * FROM alkewallet.transacciones;


SELECT nombre, email
FROM usuarios
where id > 5;

SELECT id, nombre
FROM usuarios
where id in (1,4,5,9)
order by nombre desc;

-- Se buscan solo los que tengan nombre sebastian		
SELECT *
FROM usuarios u
where u.nombre LIKE 'sebastian%'
;

-- cuenta registros
SELECT count(*) total_usuarios 
FROM usuarios
;

-- Union tablas transacciones con usuarios.
SELECT *
FROM transacciones t
INNER JOIN usuarios u
    ON t.remitente_usuarios_id = u.id;

--INNER JOIN para ver importes entre remitente y destinatario 
SELECT  t.id AS transaccion_id, ur.nombre AS remitente, ud.nombre AS destinatario, t.importe, t.fecha_transaccion
FROM transacciones t
INNER JOIN usuarios ur 
    ON t.remitente_usuarios_id = ur.id
INNER JOIN usuarios ud 
ON t.destinatario_usuarios_id = ud.id;

-- Hacemos un left join para ver las transacciones realizadas por cada usuario remitente.
SELECT u.id,u.nombre,  
    COUNT(t.id) AS total_Tenviadas FROM usuarios u LEFT JOIN transacciones t
    ON u.id = t.remitente_usuarios_id
    GROUP BY u.id, u.nombre;

--Hacemos un left join para ver las transacciones recibidas por cada usuario destinatario.

SELECT  u.id,u.nombre, 
COUNT(t.id) AS total_recibidas FROM usuarios u LEFT JOIN transacciones t
    ON u.id = t.destinatario_usuarios_id
GROUP BY u.id, u.nombre;


-- Transacciones con nombres, moneda y fecha ocupando ALIAS y JOIN
SELECT  tr.id AS transaccion_id, ur.nombre AS remitente,
    ud.nombre AS destinatario, tr.importe,
    m.codigo AS moneda, tr.fecha_transaccion
FROM transacciones tr
JOIN usuarios ur 
    ON tr.remitente_usuarios_id = ur.id
JOIN usuarios ud 
    ON tr.destinatario_usuarios_id = ud.id
JOIN monedas m 
    ON tr.moneda_id = m.id;


--TAREA PLUS: TOP 5
CREATE VIEW Top5_Usuarios_MayorSaldo AS
SELECT 
    id,
    nombre,
    email,
    saldo
FROM usuarios
ORDER BY saldo DESC
LIMIT 5;

SELECT * 
FROM Top5_Usuarios_MayorSaldo;

-- ALTER TABLE
-- CAMBIAMOS EL NOMBRE de usuario a usuarios
ALTER TABLE usuario RENAME to usuarios; 

ALTER TABLE `alkewallet`.`monedas` 
CHANGE COLUMN simbolo codigo CHAR(3) NOT NULL ;

-- Creamos clave  FK moneda_id en transacciones

ALTER TABLE `alkewallet`.`transacciones` 
ADD COLUMN `moneda_id` INT NOT NULL AFTER `fecha_transaccion`,
ADD INDEX `fk_transacciones_monedas_idx` (`moneda_id` ASC) VISIBLE;
;
ALTER TABLE `alkewallet`.`transacciones` 
ADD CONSTRAINT `fk_transacciones_monedas`
  FOREIGN KEY (`moneda_id`)
  REFERENCES `alkewallet`.`monedas` (`id`)
   ON DELETE CASCADE
  ON UPDATE CASCADE;	
-- CAMBIAMOS EL SALDO e IMPORTE A DECIMAL PARA EVITAR ERRORES A LA HORA DE HACER TRANSACCIONES.
ALTER TABLE usuarios
MODIFY saldo DECIMAL(12,2) NOT NULL DEFAULT 0.00;
AGREGAMOS SALDO POSITIVO SIEMPRE.
ALTER TABLE usuarios
ADD CONSTRAINT chk_saldo_positivo CHECK (saldo >= 0)
;

ALTER TABLE transacciones
MODIFY importe DECIMAL(12,2) NOT NULL DEFAULT 0.00
;

 -- Modificar la tabla usuario para añadir la fecha de creación usando ALTER TABLE.
ALTER TABLE usuarios
ADD fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

INSERT INTO `alkewallet`.`usuarios` (`id`, `nombre`, `email`, `contraseña`, `saldo`) VALUES ('10', 'Anibal', 'anibal@ejemplo.com', '12345', '5000');


--UPDATE  
--SE AGREGAN 10000 AL USUARIO PAMELA
  update usuarios set saldo = saldo + 10000 where id = 6;

-- Se modifica el código del real brasileño a RBR(ESE ES EL CORRECTO)
UPDATE `alkewallet`.`monedas` SET `codigo` = 'RBR' WHERE (`id` = '6');

--SENTENCIA DML para modificar correo.
UPDATE usuarios
SET email = 'sebastianS@ejemplo.com'
WHERE id = 1;

-- SELECT, UPDATE Y ALTER TABLE (PRUEBAS NOT NULL, NULL)
--Se modifica de null a not null moneda_id, en donde ya había un registro.

SEELCT * 
FROM transacciones
WHERE moneda_id IS NULL;

UPDATE transacciones
SET moneda_id = 1
WHERE moneda_id IS NULL;

ALTER TABLE alkewallet.transacciones
MODIFY moneda_id IS NOT NULL
;

-- START TRANSACCION
START TRANSACTION;
	update usuarios 
	set saldo = saldo - 500 
	where id = 1;
	update usuarios 
	set saldo = saldo + 500
	where id = 5;
	INSERT INTO transacciones (remitente_usuarios_id, destinatario_usuarios_id, importe, fecha_transaccion, moneda_id)
	VALUES (1, 5, 500, NOW(), 6);
	COMMIT;


-- Se hace transacción entre el remitente 1 y destinatario 2. En donde se le descuenta 20000 al remitente y se le suma 20000 al destinatario.
START TRANSACTION;
-- 1) Bloqueo registro
SELECT saldo FROM usuarios WHERE id IN (1,2) FOR UPDATE;
-- 3) Descontar al remitente
UPDATE usuarios
SET saldo = saldo - 20000
WHERE id = 1;
-- 4) Sumar al destinatario
UPDATE usuarios
SET saldo = saldo + 20000
WHERE id = 2;
-- 5) Registrar la transacción
INSERT INTO transacciones (remitente_usuarios_id, destinatario_usuarios_id, importe, fecha_transaccion, moneda_id)
VALUES (1, 2, 20000, NOW(), 6);
COMMIT;


-- Con rollback

START TRANSACTION;
UPDATE usuarios
SET saldo = saldo - 100
WHERE id = 1;
UPDATE usuarios
SET saldo = saldo + 100
WHERE id = 6;
-- Se revierte todo
ROLLBACK;
 

-- Se cumple LA RESTRICCION  saldo negativo, ya que se iba a realizar una transaccion de 20000 y el usuario tiene 18800.
USE alkewallet;
START TRANSACTION;
SELECT saldo FROM usuarios WHERE id IN (1,2) FOR UPDATE;
UPDATE usuarios
SET saldo = saldo - 20000
WHERE id = 1;
UPDATE usuarios
SET saldo = saldo + 20000
WHERE id = 2;
INSERT INTO transacciones (remitente_usuarios_id, destinatario_usuarios_id, importe, fecha_transaccion, moneda_id)
VALUES (1, 2, 20000, NOW(), 6);
COMMIT;


-- DELETE
-- Se comprueba primero el id a eliminar.
SELECT *
FROM transacciones
WHERE id = 6;
-- Luego se borra la transaccion 6
DELETE FROM transacciones
WHERE id = 6;

-- se prueba TRUNCATE y DROP con restriccion y sin restricciones.

SELECT * FROM alkewallet.transacciones;


SELECT *
FROM transacciones
WHERE remitente_usuarios_id = 6;

DELETE FROM usuarios
WHERE id = 6;
 
DELETE FROM transacciones
WHERE remitente_usuarios_id = 6;

DELETE FROM usuarios
WHERE id = 6;

TRUNCATE transacciones;

DROP TABLE IF transacciones;
DROP TABLE IF monedas;
DROP TABLE IF usuarios;

-- Error Code: 3730. Cannot drop table 'usuarios' referenced by a foreign key constraint 'fk_destinatario_usuarios_id' on table 'transacciones'.

-- MODELO ER

-- El modelo cumple 3FN porque todos los atributos no clave dependen únicamente de la clave primaria y no existen dependencias transitivas entre atributos.

 

 
