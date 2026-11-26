# Semana 8 · Clase 16 — Business Intelligence: dashboards, KPIs y visualización de datos

> 🎯 **Objetivo:** entender qué es **Business Intelligence**, qué hace a un buen **KPI** y a un buen **dashboard**, aprender a **elegir el gráfico según la pregunta** y armar en **Metabase** un tablero con pestañas y filtros sobre el esquema analítico `dw` de Northwind.
>
> 📝 **Tarea:** [Tarea Clase 16 — Gráficos en Metabase](../../tasks/semana_8/clase_16.md)

---

## 🧩 1. ¿Dónde estamos?

Ya armamos el modelo analítico.

```
Base transaccional  →  Transformación  →  Data warehouse  →  Business Intelligence
OLTP (public)          SQL (CTAS)          OLAP (dw)           Metabase  ← HOY
```

| Etapa                  | En Northwind                          | Para qué sirve                                   |
| ---------------------- | ------------------------------------- | ------------------------------------------------ |
| Base transaccional     | schema `public`                       | Registrar la operación diaria, sin duplicar datos |
| Transformación         | `CREATE TABLE AS SELECT` (CTAS)       | Reorganizar los datos para analizar              |
| Data warehouse         | schema `dw`                           | `fact_ventas` + dimensiones, listo para leer     |
| Business Intelligence  | Metabase                              | Dashboards y KPIs para tomar decisiones          |

### Repaso: OLTP vs. OLAP

|                | OLTP                                    | OLAP                                     |
| -------------- | --------------------------------------- | ---------------------------------------- |
| Significa      | Online Transaction Processing           | Online Analytical Processing             |
| Hace           | Registra la operación diaria            | Analiza datos históricos                 |
| Tablas         | Muchas, normalizadas                    | Pocas, pensadas para leer y sumar        |
| Objetivo       | Mantener el negocio funcionando         | Entender cómo funciona el negocio        |
| En Northwind   | `public`: `orders`, `customers`, …      | `dw`: `fact_ventas` + dimensiones        |

> 💡 El dashboard se conecta siempre que se pueda a la base **analítica**. Si cien personas consultan un tablero pesado contra la base de ventas, el sistema con el que la empresa vende se pone lento.

### Repaso: hechos, dimensiones y estrella ⭐

- **Hechos:** los números que medimos → `fact_ventas` (cantidad, precio, descuento, venta neta).
- **Dimensiones:** el contexto para agrupar y filtrar → quién, qué, cuándo, cómo se envió.
- **Estrella:** hechos al centro, dimensiones alrededor.
- **Granularidad:** 1 fila = 1 producto de un pedido. Un pedido con 3 productos aparece 3 veces.

| Tabla               | Qué guarda                                                                 |
| ------------------- | -------------------------------------------------------------------------- |
| `fact_ventas`       | Una fila por producto vendido en un pedido: cantidad, precio, descuento, montos |
| `dim_cliente`       | Quién compra: empresa, contacto, ciudad y país                             |
| `dim_producto`      | Qué se vende: producto, categoría y proveedor                              |
| `dim_empleado`      | Quién vende: nombre, cargo, ciudad y país                                  |
| `dim_transportista` | Cómo se envía: la empresa de envío                                         |
| `dim_fecha`         | Cuándo pasa: año, trimestre, mes, día y día de la semana                   |

> 💡 El schema `dw` también trae vistas ya armadas (`vw_ventas_mensuales`, `vw_ventas_por_pais`, `vw_top_productos`, …) que sirven para explorar rápido.

### Del modelo al dashboard

| En el dashboard…              | En SQL…                         |
| ----------------------------- | ------------------------------- |
| Un KPI                        | `SUM` o `COUNT` sobre los hechos |
| Agrupar (ventas por país)     | `GROUP BY` una dimensión        |
| Un filtro de fecha o rubro    | `WHERE` sobre una dimensión     |
| Contar pedidos                | `COUNT(DISTINCT pedido_id)`     |

> ✅ Un buen dashboard depende de un buen modelo debajo.

---

## 🧩 2. Teoría: BI, KPIs y dashboards

### Business Intelligence

**BI** es el conjunto de procesos y tecnologías para analizar datos y apoyar la toma de decisiones. Las herramientas de BI permiten:

- Conectar y visualizar datos de distintas fuentes.
- Crear dashboards y reportes interactivos.
- Analizar (y a veces transformar) datos para descubrir *insights*.

Ejemplos: **Metabase**, Power BI, Tableau, Grafana.

### Metabase

- Herramienta de BI **open source**, ideal para equipos chicos.
- **No reemplaza** un ETL ni un data warehouse: se conecta a ellos y los consulta.
- Cada consulta se llama **pregunta** (*question*), y se puede hacer con **SQL** o con el **editor visual** (sin código).

### KPI: Key Performance Indicator

Una métrica estratégica que mide el desempeño de un proceso clave del negocio. Un buen KPI es:

| # | Característica | Qué significa                                               |
| - | -------------- | ----------------------------------------------------------- |
| 1 | **Claro**      | Fácil de entender: ventas, órdenes, clientes nuevos         |
| 2 | **Calculable** | Basado en datos confiables del modelo analítico             |
| 3 | **Comparativo**| Permite ver evolución: vs. mes anterior, vs. objetivo       |
| 4 | **Oportuno**   | Actualizado y visible cuando se necesita                    |

### Dashboards

- **Qué son:** un conjunto de visualizaciones que resumen KPIs y tendencias de un área.
- **Parametrizados:** tienen filtros (fecha, categoría, etc.) que actualizan todos los gráficos a la vez.
- **Un buen dashboard:** pocas métricas, una pregunta por gráfico y una historia clara.

---

## 🧩 3. Primero la pregunta, después el gráfico

| Pregunta                          | Gráfico                    |
| --------------------------------- | -------------------------- |
| ¿Cuánto en total?                 | Número / KPI               |
| ¿Quién es más grande?             | Barras                     |
| ¿Cómo evolucionó?                 | Línea                      |
| ¿Qué parte del todo?              | Torta o dona               |
| ¿Hay relación entre variables?    | Dispersión o burbujas      |
| ¿Dónde pasa?                      | Mapa                       |

> ⚠️ El gráfico incorrecto puede llevar a malas interpretaciones.

### 📊 Barras — ¿quién es más grande?

- Comparan valores entre categorías y se leen sin conocimiento técnico.
- Ordenar de mayor a menor.
- ⚠️ Demasiadas barras saturan, y un eje que no arranca en 0 exagera las diferencias.

### 📈 Línea — ¿cómo evolucionó?

- Muestra tendencias en el tiempo.
- Elegir bien el intervalo: día, semana, mes.
- Pocas líneas por gráfico.

### 🍩 Torta o dona — ¿qué parte del todo?

- Proporciones que suman 100 %.
- ⚠️ Evitar con muchas categorías, porcentajes parecidos o valores negativos.

### 🫧 Dispersión y burbujas — ¿hay relación?

- **Correlación positiva:** las dos variables suben juntas.
- **Correlación negativa:** una sube mientras la otra baja.
- **Burbujas:** el tamaño agrega una tercera variable.

### 🌎 Mapas — ¿dónde pasa?

- **Coroplético:** color por región (el que usamos en Metabase).
- **Puntos / símbolos proporcionales:** ubicaciones exactas.
- **Calor:** zonas de concentración.

### 📊📈 Pareto — barras + línea

- Barras: venta por producto. Línea: % acumulado del total.
- Responde: *¿qué pocos productos concentran la mayoría de las ventas?*

### Hay muchos más…

| Gráfico            | Sirve para                                         |
| ------------------ | -------------------------------------------------- |
| Área               | Acumulados y evolución de partes de un total       |
| Mapa de calor      | Patrones en grillas grandes (día × hora)           |
| Treemap            | Jerarquías y relaciones parte-todo                 |
| Radar              | Varias variables a la vez y estacionalidad         |
| Lollipop           | Como barras, pero más livianas visualmente         |
| Binning hexagonal  | Densidad cuando hay muchísimos puntos              |

---

## 🧩 4. Práctica: levantar Metabase con Docker Compose

El `docker-compose.yml` levanta tres contenedores en la misma red:

| Servicio        | Para qué                          | Puerto (afuera:adentro) | Se abre en              |
| --------------- | --------------------------------- | ----------------------- | ----------------------- |
| `postgres-db`   | Guarda los datos                  | `5433:5432`             | — (no es una web)       |
| `pg_admin`      | Mirar tablas y escribir consultas | `8080:80`               | <http://localhost:8080> |
| `metabase-app`  | Gráficos y dashboards             | `4000:3000`             | <http://localhost:4000> |

Adentro de Postgres, la base `northwind` tiene **dos schemas**:

- `public` → Northwind transaccional (sale de `northwind.sql`).
- `dw` → Northwind analítica, modelo estrella (sale de `analytics.sql`). **Es la que usa Metabase.**

> 💡 Metabase guarda sus usuarios, preguntas y dashboards en la base `postgres` (variables `MB_DB_*` del YAML), no en un archivo H2 dentro del contenedor. Así todo queda en `./pgdata` y hay un solo lugar para respaldar. **Si se borra `pgdata`, se pierden también los dashboards.**

```bash
# 1. Abrir Docker Desktop (motor corriendo)
# 2. Ir a la carpeta del docker-compose.yml
cd btcmp-data-devli
# 3. Levantar Postgres, pgAdmin y Metabase
docker compose up -d
# 4. Ver que los 3 servicios estén "Up"
docker compose ps
# 5. Apagar todo (los datos quedan en ./pgdata)
docker compose down
```

---

## 🧩 5. Conectar Postgres con Metabase

En <http://localhost:4000>: **Añade tus datos → Base de datos → PostgreSQL**.

| Campo                | Valor         | Pregunta que responde |
| -------------------- | ------------- | --------------------- |
| Nombre para mostrar  | `Northwind DW`| Solo una etiqueta     |
| Servidor (host)      | `postgres-db` | ¿A qué caja voy?      |
| Puerto               | `5432`        | ¿A qué ventanilla?    |
| Base de datos        | `northwind`   | ¿Qué cajón abro?      |
| Usuario              | `(.env)`      | La llave              |
| Contraseña           | `(.env)`      | La llave              |
| Schemas              | Todos, o solo `dw` | —                |
| SSL / túnel SSH      | Apagados      | Son para bases remotas |

---

## 🧩 6. Hoja de ruta de la práctica

| # | Paso                | Qué hacemos                                                              |
| - | ------------------- | ------------------------------------------------------------------------ |
| 1 | Query vs. plot      | La misma consulta en pgAdmin y en Metabase: ver qué suma una herramienta de BI |
| 2 | KPIs                | Preguntas que devuelven un solo número: las tarjetas del tablero         |
| 3 | Variables y filtros | Filtros en la query para elegir categoría o año                          |
| 4 | Dashboard con tabs  | Todo junto en un tablero con pestañas y un filtro común                  |
| 5 | El potencial        | Editor visual, drill-down, X-ray y alertas                               |

> 📏 **Regla: una métrica, una sola fórmula.** En todas las consultas calculamos la venta como `cantidad * precio_unitario * (1 - descuento_pct)`. La tabla también tiene `venta_neta`: si un gráfico usa una y otro la otra, por redondeos o reglas ocultas los números pueden no coincidir, y un dashboard con dos números distintos para lo mismo pierde credibilidad.

### 1️⃣ Query vs. plot

```sql
-- Ventas totales por producto
SELECT
    p.producto,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f
JOIN dw.dim_producto p ON f.producto_key = p.producto_key
GROUP BY p.producto
ORDER BY total_ventas DESC;
```

- **En pgAdmin:** una tabla de 77 filas. Correcta, pero hay que leer número por número.
- **En Metabase:** **+ Nuevo → Consulta SQL**, base `Northwind DW`, pegar la misma query y ejecutar (▶).
- **Un clic:** **Visualización → Barras**. Ahora se ve en un segundo qué producto vende más. **Eso es BI.**

### 2️⃣ KPIs con visualización **Número**

#### A) Ventas totales

```sql
SELECT
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f;
```

#### B) Cantidad de órdenes

```sql
SELECT
    COUNT(DISTINCT f.pedido_id) AS total_ordenes
FROM dw.fact_ventas f;
```

### 3️⃣ Variables y filtros

| Sintaxis       | Qué hace                                                                 |
| -------------- | ------------------------------------------------------------------------ |
| `{{variable}}` | Metabase crea una casilla de filtro para la consulta                     |
| `[[ AND ... ]]`| Parte **opcional**: si la casilla está vacía, Metabase borra esa línea   |
| `WHERE 1=1`    | Siempre es verdadero: no filtra nada, pero deja que cada filtro arranque con `AND` |
| Tipo           | Texto, Número o Fecha, según la columna que filtra                       |

```sql
-- Ventas por mes, filtrables por categoría y año
SELECT
    d.mes,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f
JOIN dw.dim_fecha d    ON f.fecha_pedido_key = d.fecha_key
JOIN dw.dim_producto p ON f.producto_key = p.producto_key
WHERE 1 = 1
  [[AND p.categoria = {{categoria}}]]
  [[AND d.anio = {{anio}}]]
GROUP BY d.mes
ORDER BY d.mes;
```

| Variable        | Tipo en Metabase | Valores posibles                                                                 |
| --------------- | ---------------- | -------------------------------------------------------------------------------- |
| `{{categoria}}` | Texto            | Beverages, Condiments, Confections, Dairy Products, Grains/Cereals, Meat/Poultry, Produce, Seafood |
| `{{anio}}`      | Número           | 1996, 1997, 1998                                                                 |

> 🚃 **¿Por qué `WHERE 1=1`?** Sin él, si el usuario completa solo el año, la consulta queda `WHERE AND d.anio = 1997` → ❌ error.

Para saber qué valores cargar en los filtros:

```sql
SELECT DISTINCT categoria FROM dw.dim_producto ORDER BY categoria;
SELECT DISTINCT anio      FROM dw.dim_fecha    ORDER BY anio;
```

---

## 🧩 7. Dashboard con tabs

**+ Nuevo → Dashboard**, ponerle nombre y entrar en modo edición. Crear cuatro pestañas:

| Tab              | Preguntas                                                         | Visualización         |
| ---------------- | ----------------------------------------------------------------- | --------------------- |
| **KPIs**         | Ventas totales · Cantidad de órdenes                              | Número                |
| **Tendencias**   | Ventas anuales · Órdenes anuales · Ventas por mes del año         | Línea o barras        |
| **Ranking**      | Top 10 clientes · Ranking de vendedores · Top 10 productos        | Barras horizontales / tabla |
| **Segmentación** | Ventas por país · Ventas por categoría                            | Mapa · Dona           |

> 💡 **Filtro común:** en modo edición, **Agregar filtro** → elegir el tipo (por ejemplo categoría o año) → en cada tarjeta conectarlo con la variable de esa pregunta. Guardar: con un clic en el filtro se actualizan todos los gráficos.

### 📈 Tab Tendencias

#### A) Ventas anuales

```sql
SELECT
    d.anio,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f
JOIN dw.dim_fecha d    ON f.fecha_pedido_key = d.fecha_key
JOIN dw.dim_producto p ON f.producto_key = p.producto_key
WHERE 1 = 1
  [[AND p.categoria = {{categoria}}]]
GROUP BY d.anio
ORDER BY d.anio;
```

#### B) Órdenes anuales

```sql
SELECT
    d.anio,
    COUNT(DISTINCT f.pedido_id) AS total_ordenes
FROM dw.fact_ventas f
JOIN dw.dim_fecha d    ON f.fecha_pedido_key = d.fecha_key
JOIN dw.dim_producto p ON f.producto_key = p.producto_key
WHERE 1 = 1
  [[AND p.categoria = {{categoria}}]]
GROUP BY d.anio
ORDER BY d.anio;
```

#### C) Ventas por mes del año

La consulta de ventas por mes del paso 3 (variables y filtros).

### 🏆 Tab Ranking

#### A) Top 10 clientes

```sql
SELECT
    c.empresa AS cliente,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f
JOIN dw.dim_cliente c ON f.cliente_key = c.cliente_key
GROUP BY c.empresa
ORDER BY total_ventas DESC
LIMIT 10;
```

#### B) Ranking de vendedores

```sql
SELECT
    e.nombre_completo AS vendedor,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas,
    COUNT(DISTINCT f.pedido_id) AS pedidos
FROM dw.fact_ventas f
JOIN dw.dim_empleado e ON f.empleado_key = e.empleado_key
GROUP BY e.nombre_completo
ORDER BY total_ventas DESC;
```

#### C) Top 10 productos

```sql
SELECT
    p.producto,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f
JOIN dw.dim_producto p ON f.producto_key = p.producto_key
GROUP BY p.producto
ORDER BY total_ventas DESC
LIMIT 10;
```

### 🌎 Tab Segmentación

#### A) Ventas por país — **Mapa → Mapa de regiones → Mundo**

Los datos guardan el país como nombre (`USA`, `UK`, `Argentina`), pero el mapa de Metabase reconoce los países por su **código de dos letras** (`US`, `GB`, `AR`). El `CASE WHEN` funciona como un traductor:

```sql
SELECT
    CASE c.pais
        WHEN 'Argentina'   THEN 'AR'
        WHEN 'Austria'     THEN 'AT'
        WHEN 'Belgium'     THEN 'BE'
        WHEN 'Brazil'      THEN 'BR'
        WHEN 'Canada'      THEN 'CA'
        WHEN 'Denmark'     THEN 'DK'
        WHEN 'Finland'     THEN 'FI'
        WHEN 'France'      THEN 'FR'
        WHEN 'Germany'     THEN 'DE'
        WHEN 'Ireland'     THEN 'IE'
        WHEN 'Italy'       THEN 'IT'
        WHEN 'Mexico'      THEN 'MX'
        WHEN 'Norway'      THEN 'NO'
        WHEN 'Poland'      THEN 'PL'
        WHEN 'Portugal'    THEN 'PT'
        WHEN 'Spain'       THEN 'ES'
        WHEN 'Sweden'      THEN 'SE'
        WHEN 'Switzerland' THEN 'CH'
        WHEN 'UK'          THEN 'GB'
        WHEN 'USA'         THEN 'US'
        WHEN 'Venezuela'   THEN 'VE'
    END AS pais,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f
JOIN dw.dim_cliente c ON f.cliente_key = c.cliente_key
GROUP BY 1
ORDER BY total_ventas DESC;
```

> 💡 **Países en gris:** son países sin ventas. Northwind tiene clientes en 21 países, casi todos de Europa y América. Más oscuro = más ventas.

#### B) Ventas por categoría — **Dona**

```sql
SELECT
    p.categoria,
    SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct)) AS total_ventas
FROM dw.fact_ventas f
JOIN dw.dim_producto p ON f.producto_key = p.producto_key
GROUP BY p.categoria
ORDER BY total_ventas DESC;
```

---

## 🧩 8. El potencial de Metabase

### 1️⃣ Editor visual — preguntas sin SQL

**+ Nuevo → Pregunta** (no "Consulta SQL"):

1. Datos: **Northwind DW → Fact Ventas**.
2. Resumir: **Número de valores distintos de → Pedido ID**.
3. Agrupado por: **País Envío**.
4. Visualizar → sale un gráfico de barras.

> 💡 Con el ícono **Ver SQL** se ve la consulta que Metabase escribió sola.

### 2️⃣ Drill-down — profundizar

Sobre el gráfico anterior, clic en la barra de **Germany**:

- **Ver estos registros** → las filas de ventas de Alemania.
- **Desglosar por… → Ciudad Envío** → los pedidos de Alemania por ciudad.

> ⚠️ El drill-down funciona bien con preguntas del **editor visual**. En preguntas SQL casi no ofrece opciones, porque Metabase no sabe cómo está armada la query.

### 3️⃣ X-ray — radiografía automática

**Datos → Bases de datos → Northwind DW → dw**, pasar el mouse sobre **Fact Ventas** y tocar el rayo ⚡. Metabase arma solo un dashboard con los gráficos que considera relevantes. Ideal para explorar una tabla que no conocemos.

### 4️⃣ Alertas y suscripciones

| Tipo          | Sobre qué            | Dónde                                                      |
| ------------- | -------------------- | ---------------------------------------------------------- |
| Suscripción   | El dashboard entero  | Dashboard → ✉️ → Suscripciones → email o Slack, frecuencia y destinatarios |
| Alerta        | Una pregunta         | Pregunta guardada → 🔔 → "avisame cuando haya resultados" o "cuando supere una meta" |

> ⚠️ En el Metabase local con Docker el correo no está configurado: hay que cargar un servidor SMTP en **Admin → Configuración → Email**. En una empresa eso lo configura el administrador.