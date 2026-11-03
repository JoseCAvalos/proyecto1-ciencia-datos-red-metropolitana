# Proyecto 2 · Fase 1 · Plan de adaptación

**Estado:** preparación técnica, pendiente de fuentes del Proyecto 2 y conteos esperados. No confundir este documento con evidencia de ejecución.

## Arquitectura que se conserva
- `scripts/07_prefect_flow.py`: ingesta batch/CDC, Kafka y validación dbt.
- Silver: `silver_tm_validaciones`, `silver_transurbano`, `silver_metroriel`, `silver_aerometro`, `silver_padron_scd2`.
- Identidad heredada: TM/TU/MR por llave numérica normalizada, AM separado. Debe evaluarse costo de falsa atribución de abandono y tratamiento de bajas por CDC.
- El modelo `dbt/models/phase2/features_usuario.sql` **no cumple sin cambios**: usa `max(ts)` como corte, agrega historial entero y ventanas de 30/90 días.

## 1.1 Ingesta limpia (5 puntos)
1. Hacer copia de seguridad local del Proyecto 1; nunca ejecutar limpieza destructiva sin verificar rutas.
2. Obtener el ZIP del Proyecto 2, **reemplazar** las 9 fuentes (no anexar a la versión anterior).
3. Ejecutar `python scripts/p2_00_preflight.py --datos data/input`.
4. Preparar un runner único de limpieza **controlada** + Prefect y documentar el comando; medir duración por etapa.
5. Comparar Bronze con el archivo de conteos esperados. No rellenar valores faltantes con supuestos.

## 1.2 Unidad, población y etiqueta (8 puntos)
- Cortes: A=2026-07-01 00:00, B=2026-07-31 00:00, C=2026-08-30 00:00, hora local.
- Población: unidades con >=2 abordajes válidos en los 28 días previos y sin DELETE efectivo previo al corte.
- Etiqueta A/B: 1 si **cero** abordajes válidos de la unidad en cualquier operador durante [corte, corte+30 días); 0 de lo contrario. C: etiqueta nula.
- Elegir persona o tarjeta y medir el costo de la representación, incluyendo AM y enlaces no resueltos.

## 1.3 Features y fuga (12 puntos)
- Una fila por unidad y corte; fecha parametrizada; ventanas idénticas <=28 días.
- Eventos de features estrictamente anteriores al corte; etiqueta solo posterior; excluir cuarentena.
- Prueba: recalcular features de A con todas las fuentes y con fuentes recortadas hasta 2026-06-30 23:59:59; diferencias = 0.
- Exportar tabla de features, diccionario (nombre, descripción, ventana, origen Silver) y auditoría.

## 1.4 Validación (15 puntos)
- Baseline de prevalencia de A y baseline de una feature.
- Logísticas L1 y L2, C=1/lambda, validación estratificada 5-fold de **A** únicamente.
- Preprocesamiento (imputación, escala, codificación) **dentro** de cada fold con Pipeline/ColumnTransformer.
- Presentar media y desviación estándar de métrica, gráfica frente a lambda y 5 coeficientes explicados.
- **Prohibido** usar etiquetas B para seleccionar características, entrenar, validar o ajustar en Fase 1.

## Pendientes bloqueantes
- ZIP de fuentes del Proyecto 2 (nueve archivos) y tabla de conteos esperados.
- Inspección del CDC nuevo y disponibilidad de timestamps para establecer estado a cada corte.
- Ejecutar desde cero, comprobar resultados y anotar métricas **reales**.

## Entrega
Repositorio GitHub con etiqueta `fase-1` e informe con secciones 1.1–1.4. No crear la etiqueta final antes de verificar evidencias.
