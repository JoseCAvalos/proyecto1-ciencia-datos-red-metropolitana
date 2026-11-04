# Cierre de implementación Fase 1 — Estado verificable (3 nov 2026)

## Evidencia analítica ejecutada
- Nueve fuentes: 3,405,575 registros de origen, diferencias de conteo = 0.
- A: 59,498 unidades; 7,102 positivos (11.9365%).
- B: 58,115 unidades; 6,389 positivos (10.9937%). Etiquetas B reservadas para test posterior: no usadas en selección.
- C: 57,703 unidades; etiqueta no observable.
- Features: ocho variables, ventana hasta 28 días; 175,316 pares únicos de unidad y corte.
- Auditoría analítica A: 59,498 filas, siete agregados, 0 diferencias. Prueba adicional con 2 viajes y 1 DELETE futuros: 59,498 filas y 10 columnas idénticas; misma SHA-256.
- 5 folds estratificados exclusivos de A; Average Precision: L1 C=0.1, 0.406363 ± 0.012384; L2 C=0.1, 0.406124 ± 0.012237.
- Tarjeta individual: 2,404 de 10,813 positivos aparentes en A siguen viajando con otra tarjeta (22.23%); requiere reconciliar con Silver y CDC.

## Bloqueadores para declarar Fase 1 aprobada
1. Ejecución limpia real del proyecto heredado con Docker + Kafka + Prefect + dbt, con tiempos por etapa y conteos de Bronze de los nueve archivos. No realizada en el entorno de análisis.
2. Validar normalización de identidad entre operadores y semántica del estado CDC a cada fecha de corte contra dbt Silver.
3. Materializar tabla de features temporal en dbt y ejecutar prueba de recorte físico de Silver sin diferencias.
4. Confirmar que el baseline, tabla de modelos, gráfica y coeficientes se generan desde Silver y preparar informe final con esa evidencia.

No corresponde etiquetar `fase-1` todavía, ni afirmar que el apartado 1.1 está completado. La rama preserva `main`.
