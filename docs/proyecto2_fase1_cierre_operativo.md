# Proyecto 2 · Fase 1 · Estado y ejecución

## Evidencia observada en Mac (no repetir como prueba de ejecución remota)
- Prefect completo en ~4m04s, nueve archivos y 3,405,575 registros Bronze, diferencias = 0.
- 20 modelos dbt y 20 pruebas dbt correctos tras corregir la identidad numérica.
- Poblaciones preliminares de features: A 59,505; B 58,115; C 57,701.
- Invariancia A: mismas 59,505 identidades, diferencias relevantes = 0 (diferencias DOUBLE <= 1.14e-13).
- **El 12.26% y los 7,295 abandonos previamente reportados correspondían a 28 días posteriores; NO son la etiqueta final. El enunciado requiere 30 días posteriores.**
- Modelo de identidad: un mismo número normalizado TM/TU/MR se trata como misma unidad, sujeto a verificación documental; AM se conserva como identidad separada.
- CDC: se usa última operación conocida antes de cada corte. No se excluyen identidades sin CDC; revisar el costo de enlaces erróneos.

## Arquitectura y archivos nuevos
- `features_usuario_p2.sql`: creado **localmente en Mac**; no estaba todavía en GitHub cuando se prepararon estos cambios. Debe añadirse al repositorio.
- `scripts/p2_02_ajustar_decimales.py`: ajusta 4 conversiones DOUBLE a DECIMAL(18,2) y redondea el promedio.
- `scripts/p2_03_verificar_invariancia.py`: recalcula A con fuentes censuradas y exporta comparación.
- `dbt/models/phase2/etiquetas_usuario_p2.sql`: etiqueta A a 30 días; B queda NULL por defecto, C siempre NULL.
- `scripts/p2_04_baselines.py`: dos baselines y CV estratificada 5-fold para L1/L2, AP vs lambda, coeficientes. Solo A.

## Ejecutar desde la raíz del Proyecto2_Fase1

**Antes**: confirmar que `git status --short` no contiene conflictos ni cambios a descartar. El commit local `73ba9e9` no se había enviado a GitHub; se debe sincronizar sin descartar trabajo local ni sobrescribir `data/outputs`.

```bash
git pull --no-rebase origin proyecto2-fase1
python scripts/p2_02_ajustar_decimales.py
dbt compile --project-dir dbt --profiles-dir dbt --select features_usuario_p2 etiquetas_usuario_p2
dbt run --project-dir dbt --profiles-dir dbt --select features_usuario_p2 etiquetas_usuario_p2
python scripts/p2_03_verificar_invariancia.py
python -m pip install scikit-learn pandas numpy matplotlib
python scripts/p2_04_baselines.py
```

Si hay conflicto de integración Git, detenerse y resolverlo antes de continuar. Nunca usar `git reset --hard`, `git clean -fd` o `git add .` en esta copia.

## Pruebas de aceptación recomendadas
- `SELECT corte, COUNT(*) FROM features_usuario_p2 GROUP BY 1` coincide con A/B/C registrados.
- `SELECT corte, abandono_30d, COUNT(*) FROM etiquetas_usuario_p2 GROUP BY 1,2`: A tiene 0/1; B/C tienen NULL.
- Invariancia A: cero diferencias significativas y cero identidades diferentes.
- CV: exactamente cinco folds por combinación L1/L2 y cuatro lambdas, sin filas B en entrenamiento.
- Reportar AP promedio ± desviación estándar y coeficientes del modelo seleccionado.
- Agregar un test dbt de unicidad de (corte, usuario_pseudo) y control de no nulos para el corte A.
- Guardar documentación del costo de identidad TM/TU/MR frente a AM e incertidumbre de CDC.

## Advertencias
- Estos cambios en GitHub **no se han ejecutado contra DuckDB del Mac**; las métricas de AP aún son desconocidas.
- El artefacto final de Fase 2, predicciones de C, test B único y análisis PCA/KMeans permanecen pendientes.
- No crear tag `fase-1` hasta verificar ejecución, evidencias y entregables del profesor.
