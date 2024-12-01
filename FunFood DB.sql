-- Crear la base de datos
-- CREATE DATABASE Pedido_mesa;
USE Pedido_mesa;

-- Tabla Mozos
CREATE TABLE Mozos (
    n_mozo INT PRIMARY KEY AUTO_INCREMENT,
    apellido VARCHAR(50) NOT NULL,
    nombre VARCHAR(50) NOT NULL
);

-- Tabla Turnos
CREATE TABLE Turnos (
    n_turno INT PRIMARY KEY AUTO_INCREMENT,
    n_mozo INT NOT NULL,
    inicio DATETIME NOT NULL,
    fin DATETIME NOT NULL,
    FOREIGN KEY (n_mozo) REFERENCES Mozos(n_mozo)
);

-- Tabla Menús
CREATE TABLE Menus (
    n_menu INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    n_pedido INT PRIMARY KEY AUTO_INCREMENT,
    n_mozo INT NOT NULL,
    n_menu INT NOT NULL,
    detalle_menu VARCHAR(255),
    bebida VARCHAR(100),
    cantidad INT NOT NULL,
    n_mesa INT NOT NULL,
    forma_pago VARCHAR(50),
    FOREIGN KEY (n_mozo) REFERENCES Mozos(n_mozo),
    FOREIGN KEY (n_menu) REFERENCES Menus(n_menu)
);

-- Tabla para reasignaciones
CREATE TABLE Reasignaciones (
    id_reasignacion INT PRIMARY KEY AUTO_INCREMENT,
    n_pedido INT NOT NULL,
    antiguo_mozo INT NOT NULL,
    nuevo_mozo INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    FOREIGN KEY (n_pedido) REFERENCES Pedidos(n_pedido),
    FOREIGN KEY (antiguo_mozo) REFERENCES Mozos(n_mozo),
    FOREIGN KEY (nuevo_mozo) REFERENCES Mozos(n_mozo)
);


-- ------------------------------------------------------------
-- Sección 1: Sentencias de creación de procedimientos almacenados de la base de datos.

-- Asignar un nuevo pedido a un mozo:
DELIMITER //
CREATE PROCEDURE AsignarPedidoAMozo (
    IN p_n_pedido INT,
    IN p_n_mozo INT
)
BEGIN
    UPDATE Pedidos
    SET n_mozo = p_n_mozo
    WHERE n_pedido = p_n_pedido;
END //
DELIMITER ;

-- Insertar un nuevo pedido:
DELIMITER //
CREATE PROCEDURE InsertarNuevoPedido (
    IN p_n_mozo INT,
    IN p_n_menu INT,
    IN p_detalle_menu VARCHAR(255),
    IN p_bebida VARCHAR(100),
    IN p_cantidad INT,
    IN p_n_mesa INT,
    IN p_forma_pago VARCHAR(50)
)
BEGIN
    INSERT INTO Pedidos (n_mozo, n_menu, detalle_menu, bebida, cantidad, n_mesa, forma_pago)
    VALUES (p_n_mozo, p_n_menu, p_detalle_menu, p_bebida, p_cantidad, p_n_mesa, p_forma_pago);
END //
DELIMITER ;

-- Asignar un mozo a otro turno:
DELIMITER //
CREATE PROCEDURE CambiarTurnoMozo (
    IN p_n_mozo INT,
    IN p_n_turno INT
)
BEGIN
    UPDATE Turnos
    SET n_mozo = p_n_mozo
    WHERE n_turno = p_n_turno;
END //
DELIMITER ;


-- ------------------------------------------------------------
-- Sección 2: Sentencias de creación de triggers asociados a la base de datos.

-- Registrar reasignación de un pedido a otro mozo
DELIMITER //
CREATE TRIGGER CambiarPedidoDeMozo
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    IF OLD.n_mozo != NEW.n_mozo THEN
        INSERT INTO Reasignaciones (n_pedido, antiguo_mozo, nuevo_mozo, fecha_hora)
        VALUES (OLD.n_pedido, OLD.n_mozo, NEW.n_mozo, NOW());
    END IF;
END //
DELIMITER ;

-- ------------------------------------------------------------
-- Sección 3: Sentencias de creación de funciones en la base de datos.

-- Cerrar pedidos por mozo y turno
DELIMITER //
CREATE FUNCTION CerrarPedidos (
    p_n_mozo INT,
    p_n_turno INT
) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total_cerrados INT;

    -- Actualizar los pedidos como "Cerrados"
    UPDATE Pedidos
    SET forma_pago = 'Cerrado'
    WHERE n_mozo = p_n_mozo 
    AND EXISTS (
        SELECT 1 
        FROM Turnos 
        WHERE Turnos.n_turno = p_n_turno 
        AND Turnos.n_mozo = p_n_mozo
    );

    -- Contar los pedidos cerrados
    SELECT COUNT(*) INTO total_cerrados
    FROM Pedidos
    WHERE forma_pago = 'Cerrado';

    RETURN total_cerrados;
END //
DELIMITER ;






-- ------------------------------------------------------------
-- Insertamos datos a las tablas para probar

INSERT INTO Mozos (apellido, nombre) VALUES
('Pérez', 'Juan'),
('Gómez', 'Ana'),
('López', 'Carlos');

INSERT INTO Turnos (n_mozo, inicio, fin) VALUES
(1, '2024-11-15 08:00:00', '2024-11-15 16:00:00'),
(2, '2024-11-15 16:00:00', '2024-11-15 23:59:00'),
(3, '2024-11-15 08:00:00', '2024-11-15 16:00:00');

INSERT INTO Menus (descripcion, precio) VALUES
('Hamburguesa con papas', 1500.00),
('Pizza', 1200.00),
('Ensalada César', 1000.00);

INSERT INTO Pedidos (n_mozo, n_menu, detalle_menu, bebida, cantidad, n_mesa, forma_pago) VALUES
(1, 1, 'Extra queso', 'Coca-Cola', 2, 101, NULL),
(2, 2, 'Sin bordes rellenos', 'Agua', 1, 102, NULL),
(3, 3, 'Aderezo aparte', 'Limonada', 3, 103, NULL);


-- ------------------------------------------------------------
-- PRUEBAS DE FUNCIONALIDADES

-- 1 asignar un pedido a un mozo
SELECT * FROM Pedidos;
CALL AsignarPedidoAMozo(1, 1); -- Asignar el pedido 1 al mozo 2
SELECT * FROM Pedidos WHERE n_pedido = 1;

-- 2 Insertar un nuevo pedido
SELECT * FROM Pedidos;
CALL InsertarNuevoPedido(1, 2, 'Sin gluten', 'Pepsi', 1, 104, 'Efectivo');

-- 3 Asignar un mozo a otro turno
SELECT * FROM Turnos;
CALL CambiarTurnoMozo(2, 3); -- Asignar al mozo 2 al turno 3

-- 4 Trigger: Registrar reasignación de pedido
SELECT * FROM Reasignaciones;
UPDATE Pedidos SET n_mozo = 3 WHERE n_pedido = 1; -- Cambiar el mozo del pedido 1 al mozo 3
SELECT * FROM Reasignaciones WHERE n_pedido = 1;

-- 5 Cerrar pedidos por mozo y turno
SELECT * FROM Pedidos;
SELECT CerrarPedidos(1, 1); -- Cerrar los pedidos del mozo 1 en el turno 1
SELECT * FROM Pedidos WHERE n_mozo = 1 AND forma_pago = 'Cerrado';

