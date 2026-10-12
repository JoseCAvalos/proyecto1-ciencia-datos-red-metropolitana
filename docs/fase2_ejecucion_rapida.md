# Fase 2 - Ejecución rápida

## Objetivo

Construir los entregables de Fase 2 sobre la arquitectura validada de Fase 1.

## 1. Actualizar la rama local

```bash
git fetch origin
git switch fase2-desarrollo
git pull origin fase2-desarrollo
```

## 2. Activar entorno y variables

```bash
source .venv/bin/activate
set -a
source .env
set +a
```

## 3. Construir Fase 2

```bash
dbt run --project-dir dbt --profiles-dir dbt --select phase2
dbt test --project-dir dbt --profiles-dir dbt --select phase2
```

## 4. Generar archivos para Tableau y features

```bash
python scripts/09_exportar_fase2.py
python scripts/10_metricas_fase2.py
```

Los CSV se generan en:

```text
data/outputs/fase2/
```

Archivos principales:
- mart_demanda_dashboard.csv
- mart_cobertura_zona.csv
- mart_transbordo_usuario.csv
- mart_metroriel_zonas.csv
- features_usuario.csv
- metricas_fase2.csv

## 5. Tableau

Usar los cuatro marts de dashboard como fuentes del libro de Tableau.

Consultar `docs/fase2_plan_tableau.md` para construir las hojas y el dashboard.

## 6. Recomendación

Ejecutar primero `scripts/10_metricas_fase2.py`.

Copiar las cifras medidas al borrador:

```text
docs/fase2_recomendacion_borrador.md
```

No inventar valores.

## 7. Features

El modelo `features_usuario.sql` sale exclusivamente de Silver.

Entregables:
- `data/outputs/fase2/features_usuario.csv`
- `docs/fase2_diccionario_features.md`

## 8. Gobernanza y seguridad

Documento base:

```text
docs/gobernanza_seguridad_fase2.md
```

El linaje debe generarse con:

```bash
dbt docs generate --project-dir dbt --profiles-dir dbt
dbt docs serve --project-dir dbt --profiles-dir dbt
```

## 9. Validación final

Antes de entregar confirmar:
- Tableau responde las cuatro preguntas obligatorias.
- Recomendación usa cifras del tablero.
- Features tiene una fila por usuario y fecha de corte declarada.
- No existen credenciales en Git.
- El tablero puede rastrearse hasta Gold y de Gold hacia Silver/Bronze mediante dbt.
