# Bakery Pro — Backend API

API REST construida con **NestJS** y **TypeScript** que expone todos los servicios del sistema de gestión de pastelería. Gestiona autenticación, usuarios, inventario, producción, ventas, facturación y delivery.

## Tabla de Contenidos

- [Stack y dependencias](#stack-y-dependencias)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos previos](#requisitos-previos)
- [Instalación y ejecución](#instalación-y-ejecución)
- [Variables de entorno](#variables-de-entorno)
- [Base de datos y Prisma](#base-de-datos-y-prisma)
- [Autenticación](#autenticación)
- [Endpoints de la API](#endpoints-de-la-api)
- [Arquitectura y patrones](#arquitectura-y-patrones)
- [Scripts disponibles](#scripts-disponibles)

---

## Stack y Dependencias

| Tecnología | Versión | Uso |
|-----------|---------|-----|
| **NestJS** | 10.3 | Framework principal |
| **TypeScript** | 5.4 | Tipado estático |
| **PostgreSQL** | 16 | Base de datos relacional |
| **Prisma ORM** | 5.10 | Acceso a datos, migraciones |
| **Redis** | 7 | Caché y sesiones |
| **Passport + JWT** | — | Autenticación |
| **bcrypt** | 5.1 | Hash de contraseñas |
| **class-validator** | 0.14 | Validación de DTOs |
| **Swagger** | 7.3 | Documentación OpenAPI |
| **Sharp** | 0.34 | Procesamiento de imágenes (WebP) |
| **pdfmake** | 0.2 | Generación de PDFs |
| **winston** | 3.13 | Logging estructurado |
| **Helmet** | 7.1 | Seguridad HTTP |
| **Throttler** | 5.1 | Rate limiting |

---

## Estructura del Proyecto

```
backend/
├── prisma/
│   ├── schema.prisma          # Definición completa del modelo de datos
│   └── seed.ts                # Script de datos iniciales
│
├── src/
│   ├── main.ts                # Bootstrap: CORS, pipes, filtros, Swagger
│   ├── app.module.ts          # Módulo raíz — importa todos los módulos
│   │
│   ├── common/                # Código compartido entre módulos
│   │   ├── decorators/
│   │   │   ├── public.decorator.ts       # @Public() — rutas sin auth
│   │   │   ├── roles.decorator.ts        # @Roles(...) — control de acceso
│   │   │   └── current-user.decorator.ts # @CurrentUser() — usuario del JWT
│   │   ├── dto/
│   │   │   └── pagination.dto.ts         # Paginación + paginateResponse()
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts  # Formato de errores consistente
│   │   ├── guards/
│   │   │   ├── jwt-auth.guard.ts         # Valida Bearer token
│   │   │   └── roles.guard.ts            # Valida roles del usuario
│   │   └── interceptors/
│   │       ├── transform.interceptor.ts  # Envuelve respuestas en ApiResponse<T>
│   │       └── logging.interceptor.ts    # Log de requests/responses
│   │
│   ├── prisma/
│   │   ├── prisma.module.ts   # Módulo global exporta PrismaService
│   │   └── prisma.service.ts  # Cliente Prisma con lifecycle hooks
│   │
│   └── modules/
│       ├── auth/              # Login, logout, refresh, profile
│       ├── users/             # CRUD, roles, toggle-active, avatar
│       ├── customers/         # CRUD de clientes
│       ├── products/          # Productos y categorías con imágenes
│       ├── inventory/         # Ingredientes, movimientos, kardex, alertas
│       ├── recipes/           # Recetas, ingredientes, cálculo de costo
│       ├── production/        # Órdenes de producción, estados, asignación
│       ├── orders/            # Pedidos personalizados, tipo PICKUP/DELIVERY
│       ├── sales/             # POS, carrito, pagos, caja, resumen diario
│       ├── invoices/          # Facturación, anulación, PDF
│       ├── delivery/          # Asignación, estado, pago contra entrega
│       ├── reports/           # Dashboard, gráficos, exportación CSV
│       └── upload/            # Subida de imágenes con conversión WebP
│
├── .env.example               # Plantilla de variables de entorno
├── .gitignore
├── package.json
└── tsconfig.json
```

### Estructura interna de cada módulo

Cada módulo sigue el patrón estándar de NestJS:

```
modules/ejemplo/
├── dto/
│   ├── create-ejemplo.dto.ts   # Validación de entrada (POST)
│   └── update-ejemplo.dto.ts   # PartialType del DTO de creación (PATCH)
├── ejemplo.controller.ts       # Rutas HTTP, decoradores Swagger
├── ejemplo.service.ts          # Lógica de negocio, acceso a Prisma
└── ejemplo.module.ts           # Imports/exports del módulo
```

---

## Requisitos Previos

- **Node.js** >= 20.x
- **npm** >= 10.x
- **PostgreSQL** >= 15 corriendo localmente (o vía Docker)
- **Redis** >= 7 corriendo localmente (o vía Docker)

> Para levantar solo la base de datos y Redis con Docker:
> ```bash
> docker-compose up -d postgres redis
> ```

---

## Instalación y Ejecución

### 1. Instalar dependencias

```bash
npm install
```

### 2. Configurar variables de entorno

```bash
cp .env.example .env
```

Editar `.env` con los valores correctos (ver sección [Variables de entorno](#variables-de-entorno)).

### 3. Generar el cliente Prisma

```bash
npm run prisma:generate
```

### 4. Ejecutar las migraciones

```bash
# Modo desarrollo (crea la migración y la aplica)
npm run prisma:migrate

# Modo producción (aplica migraciones existentes sin crear nuevas)
npm run prisma:migrate:prod
```

### 5. Poblar datos iniciales

```bash
npm run prisma:seed
```

Crea: usuarios de prueba (5 roles), categorías de ejemplo y productos base.

### 6. Iniciar el servidor

```bash
# Desarrollo con hot-reload
npm run start:dev

# Producción
npm run build
npm run start:prod
```

El servidor estará disponible en: `http://localhost:3000`

---

## Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `NODE_ENV` | Entorno de ejecución | `development` |
| `PORT` | Puerto del servidor | `3000` |
| `API_PREFIX` | Prefijo global de la API | `api/v1` |
| `FRONTEND_URL` | URL del frontend (CORS) | `http://localhost:5173` |
| `DATABASE_URL` | Cadena de conexión PostgreSQL | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | Clave secreta para access tokens | cadena aleatoria larga |
| `JWT_EXPIRES_IN` | Expiración del access token | `1h` |
| `JWT_REFRESH_SECRET` | Clave secreta para refresh tokens | cadena aleatoria larga |
| `JWT_REFRESH_EXPIRES_IN` | Expiración del refresh token | `7d` |
| `REDIS_URL` | URL de conexión a Redis | `redis://localhost:6379` |
| `THROTTLE_TTL` | Ventana de rate limiting (segundos) | `60` |
| `THROTTLE_LIMIT` | Máx. requests por ventana | `100` |
| `MAX_FILE_SIZE` | Tamaño máximo de archivo (bytes) | `5242880` (5 MB) |
| `UPLOAD_PATH` | Ruta local para archivos subidos | `./uploads` |
| `LOG_LEVEL` | Nivel de logging | `debug` |

> **Seguridad:** Nunca subas el archivo `.env` al repositorio. Usa valores fuertes y únicos para `JWT_SECRET` y `JWT_REFRESH_SECRET` en producción.

---

## Base de Datos y Prisma

### Modelos principales

| Modelo | Descripción |
|--------|-------------|
| `User` | Usuarios del sistema con roles |
| `Customer` | Clientes de la pastelería |
| `Category` | Categorías de productos |
| `Product` | Productos con precio y stock |
| `Ingredient` | Ingredientes del inventario |
| `InventoryMovement` | Movimientos de stock (kardex) |
| `Recipe` | Recetas vinculadas a productos |
| `RecipeDetail` | Líneas de ingredientes de una receta |
| `Order` | Pedidos personalizados de clientes |
| `OrderDetail` | Líneas de productos de un pedido |
| `ProductionOrder` | Órdenes de producción |
| `Sale` | Transacciones de venta |
| `SaleDetail` | Líneas de una venta |
| `Payment` | Pagos asociados a una venta |
| `Invoice` | Facturas generadas |
| `Delivery` | Registro de entregas a domicilio |
| `CashRegister` | Sesiones de caja |

### Comandos de Prisma

```bash
# Generar cliente tras cambiar el schema
npm run prisma:generate

# Crear migración en desarrollo
npm run prisma:migrate

# Aplicar migraciones en producción
npm run prisma:migrate:prod

# Resetear BD (solo desarrollo)
npm run prisma:reset

# Poblar datos iniciales
npm run prisma:seed

# Abrir GUI de base de datos
npm run prisma:studio
```

---

## Autenticación

El sistema usa **JWT con refresh tokens**:

- El **access token** expira en `1h` y se envía en el header `Authorization: Bearer <token>`.
- El **refresh token** expira en `7d` y se usa para obtener nuevos access tokens sin volver a iniciar sesión.
- Rutas públicas se marcan con el decorador `@Public()`.
- El control de acceso por roles se aplica con `@Roles(UserRole.ADMIN, ...)`.

### Roles disponibles

| Rol | Descripción |
|-----|-------------|
| `ADMIN` | Acceso completo al sistema |
| `SUPERVISOR` | Acceso de supervisión y reportes |
| `CASHIER` | Ventas, cobros y clientes |
| `BAKER` | Módulo de producción |
| `DELIVERY` | Módulo de delivery |

### Flujo de autenticación

```
POST /api/v1/auth/login
  → { accessToken, refreshToken, user }

POST /api/v1/auth/refresh
  Body: { refreshToken }
  → { accessToken, refreshToken }

POST /api/v1/auth/logout
  → 200 OK

GET  /api/v1/auth/profile
  → datos del usuario autenticado
```

---

## Endpoints de la API

Todos los endpoints tienen el prefijo `/api/v1`. La documentación completa e interactiva está en `/api/docs`.

### Autenticación

```
POST   /auth/login               Iniciar sesión
POST   /auth/refresh             Renovar access token
POST   /auth/logout              Cerrar sesión
GET    /auth/profile             Perfil del usuario actual
PATCH  /auth/change-password     Cambiar contraseña
```

### Usuarios

```
GET    /users                    Listar usuarios (paginado, filtro por rol)
POST   /users                    Crear usuario
GET    /users/:id                Obtener usuario por ID
PATCH  /users/:id                Actualizar usuario
PATCH  /users/:id/toggle-active  Activar / desactivar usuario
DELETE /users/:id                Eliminar usuario (soft delete)
```

### Clientes

```
GET    /customers                Listar clientes (paginado, búsqueda)
POST   /customers                Crear cliente
GET    /customers/:id            Obtener cliente
PATCH  /customers/:id            Actualizar cliente
DELETE /customers/:id            Eliminar cliente
```

### Productos y Categorías

```
GET    /products                 Listar productos (filtros: categoría, búsqueda)
POST   /products                 Crear producto
GET    /products/:id             Obtener producto
PATCH  /products/:id             Actualizar producto
DELETE /products/:id             Eliminar producto

GET    /products/categories      Listar categorías
POST   /products/categories      Crear categoría
PATCH  /products/categories/:id  Actualizar categoría
DELETE /products/categories/:id  Eliminar categoría
```

### Inventario

```
GET    /inventory/ingredients              Listar ingredientes (paginado)
POST   /inventory/ingredients              Crear ingrediente
GET    /inventory/ingredients/:id          Obtener ingrediente
PATCH  /inventory/ingredients/:id          Actualizar ingrediente
DELETE /inventory/ingredients/:id          Eliminar ingrediente
GET    /inventory/ingredients/:id/kardex   Kardex del ingrediente
POST   /inventory/movements                Registrar movimiento (entrada/salida/ajuste)
GET    /inventory/alerts/low-stock         Ingredientes con stock bajo
```

### Recetas

```
GET    /recipes              Listar recetas
POST   /recipes              Crear receta con ingredientes
GET    /recipes/:id          Obtener receta con detalle
PATCH  /recipes/:id          Actualizar receta
DELETE /recipes/:id          Eliminar receta
GET    /recipes/:id/cost     Calcular costo de la receta
```

### Producción

```
GET    /production           Listar órdenes (filtro por estado)
POST   /production           Crear orden de producción
GET    /production/:id       Obtener orden con detalle
PATCH  /production/:id/status   Avanzar estado
PATCH  /production/:id/assign   Asignar pastelero
```

### Pedidos

```
GET    /orders               Listar pedidos (filtros: estado, búsqueda)
POST   /orders               Crear pedido
GET    /orders/:id           Obtener pedido completo
PATCH  /orders/:id/status    Cambiar estado manualmente
PATCH  /orders/:id/cancel    Cancelar pedido
```

### Ventas

```
GET    /sales                Listar ventas (filtros: estado, búsqueda)
POST   /sales                Registrar venta (POS o cobro de pedido)
GET    /sales/summary/daily  Resumen diario de ventas
PATCH  /sales/:id/complete   Completar venta pendiente
POST   /sales/cash-register/open         Abrir caja
POST   /sales/cash-register/:id/close    Cerrar caja
```

### Facturas

```
GET    /invoices             Listar facturas
GET    /invoices/:id         Obtener factura
GET    /invoices/:id/data    Datos para imprimir
GET    /invoices/:id/pdf     Descargar PDF
PATCH  /invoices/:id/cancel  Anular factura
```

### Delivery

```
GET    /delivery             Listar entregas (filtro por estado)
GET    /delivery/:id         Obtener entrega
PATCH  /delivery/:id/assign  Asignar repartidor
PATCH  /delivery/:id/status  Actualizar estado de entrega
POST   /delivery/:id/register-payment  Registrar pago contra entrega
```

### Reportes

```
GET    /reports/dashboard          Estadísticas generales
GET    /reports/sales-chart        Gráfico de ventas por día
GET    /reports/top-products       Productos más vendidos
GET    /reports/sales-by-category  Ventas por categoría
GET    /reports/production-summary Resumen de producción
GET    /reports/low-stock          Ingredientes con stock bajo
```

### Upload

```
POST   /upload/image         Subir imagen (devuelve URL pública)
DELETE /upload/image         Eliminar imagen
```

### Formato de respuesta

Todas las respuestas siguen el mismo envelope:

```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  },
  "timestamp": "2026-05-17T12:00:00.000Z"
}
```

Los errores siguen el formato:

```json
{
  "success": false,
  "statusCode": 400,
  "message": "Descripción del error",
  "timestamp": "2026-05-17T12:00:00.000Z",
  "path": "/api/v1/..."
}
```

---

## Arquitectura y Patrones

| Patrón | Implementación |
|--------|----------------|
| **Modular** | Cada dominio es un módulo NestJS independiente |
| **DTO + Validación** | `class-validator` en todos los endpoints |
| **Repository (via Prisma)** | Acceso a datos centralizado en services |
| **Transform Interceptor** | Respuestas uniformes `ApiResponse<T>` |
| **RBAC** | Guards `JwtAuthGuard` + `RolesGuard` globales |
| **Soft Delete** | Campo `deletedAt` en lugar de eliminar físicamente |
| **Paginación** | `PaginationDto` + `paginateResponse()` reutilizable |
| **Transacciones** | `prisma.$transaction()` en operaciones críticas |
| **Rate Limiting** | `ThrottlerGuard` global: 100 req/60s |

---

## Scripts Disponibles

```bash
npm run start:dev           # Desarrollo con hot-reload
npm run start:debug         # Desarrollo con inspector de Node
npm run build               # Compilar TypeScript
npm run start:prod          # Ejecutar build compilado

npm run lint                # ESLint
npm run format              # Prettier

npm run test                # Tests unitarios (Jest)
npm run test:watch          # Tests en modo watch
npm run test:cov            # Tests con reporte de cobertura
npm run test:e2e            # Tests end-to-end

npm run prisma:generate     # Generar cliente Prisma
npm run prisma:migrate      # Crear y aplicar migración (dev)
npm run prisma:migrate:prod # Aplicar migraciones (prod)
npm run prisma:seed         # Datos iniciales
npm run prisma:studio       # GUI visual de la BD
npm run prisma:reset        # Resetear BD completa (dev)
```
