# Métricas locales de rendimiento y almacenamiento - Fase 2

Este documento define cómo medir rendimiento y almacenamiento sin estimar valores manualmente.

## Requisitos

Ejecutar desde la raíz del repositorio, con el entorno virtual activo y variables cargadas:

```bash
source .venv/bin/activate
set -a
source .env
set +a
```

## Construcción y pruebas

```bash
dbt run --project-dir dbt --profiles-dir dbt --select silver gold phase2
dbt test --project-dir dbt --profiles-dir dbt --select silver gold phase2
```

La prueba singular `assert_zonas_normalizadas` falla si vuelven a existir zonas duplicadas solo por mayúsculas/minúsculas o si reaparecen valores como `MIXCO`, `VILLA NUEVA`, `SAN MIGUEL PETAPA` o `SANTA CATARINA PINULA`.

## Exportación y métricas

```bash
python scripts/09_exportar_fase2.py
python scripts/10_metricas_fase2.py
```

El segundo script mide tiempos de consulta sobre los marts de Fase 2 y escribe:

- `data/outputs/fase2/metricas_fase2.csv`
- `data/outputs/fase2/almacenamiento_fase2.csv`

## Reporte esperado

Actualizar `docs/fase2_resultados_medidos.md` solo con valores generados por los comandos anteriores. No completar tamaños, tiempos ni conteos desde estimaciones.
