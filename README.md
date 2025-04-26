# 🍽️ Picked Backend

**Picked** es una API RESTful desarrollada en **Swift** con **Vapor** como parte del proyecto final del bootcamp de desarrollo iOS en **KeepCoding**. Esta API conecta **restaurantes** con **consumidores**, permitiendo a los restaurantes ofrecer platos próximos a vencer y a los consumidores adquirirlos a precios reducidos.

---

## 🛠️ Tecnologías Utilizadas

- **Swift 6**
- **Vapor 4**
- **Fluent ORM**
- **PostgreSQL**
- **JWT (JSON Web Tokens)** para autenticación
- **Liya** (GUI para Postgres)
- **Xcode** para desarrollo

---

## 📂 Estructura del Proyecto

- **Modelos**:
  - `User`
  - `Restaurant`
  - `Meal`
  - `Purchase`
- **Controladores**:
  - `UserController`: Registro, Login, Perfil.
  - `RestaurantController`: Gestión de restaurantes.
  - `MealController`: Gestión de platos.
  - `PurchaseController`: Gestión de compras.
- **Middlewares**:
  - `UserAuthenticator`: Verificación de tokens JWT.
- **Auditoría**:
  - Campos `created_by` y `updated_by` en las tablas.

---

## 🔐 Autenticación

- Basada en **JWT**.
- Tokens válidos por defecto durante **30 días**.
- Roles de usuario:
  - `.consumer`
  - `.restaurant`
  - `.admin`

---

## 📦 Funcionalidades Clave

### Usuarios
- Registro y login con JWT.
- Edición de perfil.
- Eliminación de cuenta (con cascada si es restaurante).

### Restaurantes
- Registro con foto (upload `multipart/form-data`).
- Ver y editar su restaurante.
- Ver sus ventas (compras realizadas a sus platos).

### Platos
- Crear, editar, eliminar platos.
- Los platos se eliminan automáticamente tras **24h** si tienen **0 unidades**.

### Compras
- Realizar compras (sin pasarela de pago real, simulado).
- Cancelar compras (se restauran unidades del plato).
- Auditoría: se registra quién crea y edita.

---

## 🧹 Limpieza Automática

- Un **Job** automático elimina platos con `0 unidades` después de 24 horas.

---

## 📍 Ubicación

- Restaurantes filtrables por radio de **10km** desde la localización del consumidor (usando fórmula Haversine).

---

## 📈 Futuras Mejoras

- Integración de pagos reales.
- Notificaciones a restaurantes.
- Interfaz admin para moderación.

---

## 🚀 Cómo Ejecutarlo

1. Clona el repositorio.
2. Configura tu base de datos Postgres.
3. Crea un archivo `.env` con tu `JWT_SECRET`.
4. Ejecuta en Xcode.

---

### 👨‍💻 Autores

- Kevin Heredia https://github.com/KevinHe1496
- Jorge Navidad https://github.com/JorgeNavi

---
