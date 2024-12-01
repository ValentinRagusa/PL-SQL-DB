# Sistema de Gestión de Pedidos para FunFood 🍔

Este proyecto implementa un sistema de gestión de pedidos y cobros para el restaurante **FunFood**, utilizando **MySQL** y **PL/SQL**. Está diseñado para gestionar la relación entre mozos, turnos y pedidos, automatizando procesos clave mediante procedimientos almacenados, triggers y funciones.

## 📋 Características del Sistema

1. **Gestión de Mozos y Turnos**:
   - Relación clara entre los mozos y sus turnos.
   - Registro de horarios de trabajo y asignación de turnos.

2. **Gestión de Pedidos**:
   - Relación entre pedidos y menús disponibles en el restaurante.
   - Vinculación de cada pedido con el mozo que lo atiende.

3. **Registro de Reasignaciones**:
   - Trigger que registra automáticamente los cambios en los mozos asignados a un pedido.

4. **Automatización de Procesos**:
   - Procedimientos almacenados para:
     - Asignar pedidos a mozos.
     - Insertar nuevos pedidos.
     - Cambiar turnos de mozos.

5. **Cierre de Pedidos**:
   - Función que cierra pedidos atendidos por un mozo en un turno específico.

## 🛠️ Estructura del Código

### Tablas

- **Mozos**: Registra los datos de los mozos.
- **Turnos**: Asocia turnos a mozos con horarios definidos.
- **Menus**: Contiene los detalles de los menús disponibles.
- **Pedidos**: Registra los pedidos realizados en el restaurante.
- **Reasignaciones**: Guarda el historial de cambios en los mozos asignados a un pedido.

### Procedimientos y Funciones

- **`AsignarPedidoAMozo`**: Asigna un pedido existente a un mozo.
- **`InsertarNuevoPedido`**: Inserta un nuevo pedido con todos sus detalles.
- **`CambiarTurnoMozo`**: Cambia el turno asignado a un mozo.
- **`CerrarPedidos`**: Cierra pedidos de un mozo en un turno específico y devuelve la cantidad de pedidos cerrados.

### Trigger

- **`CambiarPedidoDeMozo`**: Registra automáticamente en `Reasignaciones` los cambios de mozos asignados a pedidos.

## 📦 Cómo Probar el Código

1. Crea una base de datos en tu entorno MySQL con:
   ```sql
   CREATE DATABASE Pedido_mesa;
   USE Pedido_mesa;
