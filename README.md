# Proyecto 1 - Red Metropolitana de Transporte

Proyecto de Ciencia de Datos para integrar información de Transmetro, Transurbano, MetroRiel y Aerómetro mediante una arquitectura Bronze -> Staging -> Silver -> Gold, con orquestación, control de calidad, visualización en Tableau y una capa de features para ciencia de datos.

## Arquitectura

- **Streaming:** Kafka para Transmetro y Aerómetro.
- **Batch:** catálogos, MetroRiel y Transurbano.
- **CDC:** procesamiento de `cdc_padron_usuarios.csv`.
- **Bronze:** lake local particionado por fecha de ingesta.
- **Staging:** modelos `ephemeral` de dbt.
- **Silver:** estandarización, identidad, calidad, cuarentena y SCD Tipo 2.
- **Gold:** modelo dimensional con dimensiones conformadas y dos tablas de hechos.
- **Orquestación:** Prefect.
- **Visualización:** Tableau sobre marts derivados de Gold.
- **Features:** tabla por usuario construida exclusivamente desde Silver.

Gold no lee directamente de Bronze.

## Tecnologías

- Python 3
- Docker Desktop
- Apache Kafka
- DuckDB
- dbt
- Prefect
- Tableau Desktop

## Requisitos

Crear y activar un entorno virtual:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Crear un archivo `.env` local con:

```text
PSEUDONYM_SALT=<valor_privado>
```

El archivo `.env` no se versiona.

Cargar variables:

```bash
set -a
source .env
set +a
```

## Ejecución Fase 1

Con Docker Desktop iniciado:

```bash
python scripts/07_prefect_flow.py
```

El flujo ejecuta inspección, ingesta batch/CDC, verificación de streaming Kafka, catálogos, transformaciones dbt, pruebas y validación.

Prueba de idempotencia:

```bash
python scripts/06_prueba_idempotencia.py
```

## Ejecución Fase 2

Construir los modelos:

```bash
dbt run --project-dir dbt --profiles-dir dbt --select phase2
dbt test --project-dir dbt --profiles-dir dbt --select phase2
```

Exportar datasets:

```bash
python scripts/09_exportar_fase2.py
python scripts/10_metricas_fase2.py
```

Los archivos se generan en:

```text
data/outputs/fase2/
```

## Tableau

El tablero utiliza:

- `mart_demanda_dashboard`
- `mart_cobertura_zona`
- `mart_transbordo_usuario`
- `mart_metroriel_zonas`

El tablero responde:

1. dónde y cuándo se concentra la demanda;
2. qué zonas quedan sin servicio;
3. cuántos usuarios usan más de un sistema;
4. si MetroRiel atiende las zonas de mayor demanda.

## Resultados principales

- Demanda total: **1,647,569**
- Usuarios con actividad: **64,224**
- Usuarios multimodales: **16,849**
- Porcentaje multimodal: **26.23%**
- Zonas con servicio: **15**
- Zonas sin servicio: **1**
- Zona sin servicio: **Santa Catarina Pinula**
- Mayor demanda horaria: **07:00 (197,491 eventos)**
- Segundo pico: **17:00 (167,251 eventos)**

Las cinco zonas de mayor demanda son Zona 17, Zona 12, Zona 8, Zona 6 y Zona 1; coinciden con las zonas objetivo del trazado MetroRiel.

## Features

El modelo `features_usuario` tiene una fila por usuario y se construye exclusivamente desde Silver.

Incluye:

- viajes en 7, 30 y 90 días;
- modo más usado;
- cantidad de modos distintos;
- días desde el último viaje;
- proporción de viajes en hora pico;
- zona de origen más frecuente;
- gasto acumulado y promedio.

## Calidad

Los registros inválidos no se eliminan silenciosamente. Se conservan en cuarentena con motivo de rechazo.

## Identidad

Transmetro, Transurbano y MetroRiel aproximan una identidad común mediante el componente numérico de sus llaves. Aerómetro permanece separado porque entrega un hash sin tabla de correspondencia.

Esta limitación puede subestimar la multimodalidad real.

## Seguridad

- No se almacenan credenciales en Git.
- `.env` está excluido del repositorio.
- La llave de usuario se seudonimiza antes de Gold.
- Los analistas trabajan con Gold y agregados.
- El detalle individual queda restringido a perfiles autorizados.
- Se propone una retención de 12 meses para detalle individual antes de agregar o anonimizar.

## Linaje

Generar documentación dbt:

```bash
dbt docs generate --project-dir dbt --profiles-dir dbt
dbt docs serve --project-dir dbt --profiles-dir dbt
```

Trazabilidad principal:

```text
Tableau -> marts Fase 2 -> Gold -> Silver -> Staging -> Bronze
```

La tabla de features sigue:

```text
Silver -> features_usuario
```

## Documentación

Los documentos principales están en `docs/`, incluyendo:

- resultados medidos;
- recomendación;
- diccionario de features;
- diccionario Gold;
- gobernanza y seguridad;
- bitácora de decisiones.
