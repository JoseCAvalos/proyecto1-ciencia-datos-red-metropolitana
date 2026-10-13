# Gobernanza, documentación y seguridad

## Definiciones oficiales

**Viaje/abordaje:** TM, TU y AM usan evento válido de abordaje; MR usa viaje completo válido.

**Usuario activo:** usuario con al menos un evento válido en el periodo analizado. No confundir con el estado administrativo `activo` del padrón CDC.

**Demanda:** suma de `cantidad` en `mart_demanda_dashboard`.

**Usuario multimodal:** usuario observado en más de un modo. Aerómetro no puede empatarse de forma confiable con los otros operadores.

**Zona conformada:** nombre territorial normalizado en Silver mediante `normalizar_zona`. Las variantes por mayúsculas/minúsculas de un mismo municipio o zona se consolidan antes de construir Gold y marts.

## Dueños por dominio

| Dominio | Dueño propuesto |
|---|---|
| Usuario | Gestión de Usuarios |
| Zona | Planificación Territorial |
| Tiempo | Analítica |
| Modo/Ruta | Operaciones |
| Estación/Parada | Infraestructura |
| Hechos de movilidad | Analítica de Movilidad |

## Linaje

Tableau -> marts Fase 2 -> Gold -> Silver -> Staging -> Bronze.

## Calidad

Registros inválidos se conservan en cuarentena con motivo.

Controles incluidos:

1. Pruebas de unicidad y no nulidad en llaves principales de Gold y marts.
2. Prueba singular `assert_zonas_normalizadas` para evitar duplicados como `Mixco/MIXCO`, `Villa Nueva/VILLA NUEVA` y `San Miguel Petapa/SAN MIGUEL PETAPA`.
3. Separación explícita entre datos crudos, staging, Silver, Gold, marts de Tableau y features.

## Seguridad

1. No se versionan secretos; `.env` está excluido.
2. Usuario seudonimizado con SHA-256 + `PSEUDONYM_SALT`.
3. Analistas usan Gold/agregados; detalle individual solo para perfiles autorizados.
4. Retención propuesta: 12 meses de detalle individual; después agregar o anonimizar salvo necesidad justificada.

## Evidencia operativa

Los tiempos de consulta y tamaños de archivos deben generarse localmente con `scripts/10_metricas_fase2.py`, porque dependen del archivo DuckDB y del sistema de archivos usado para la entrega.
