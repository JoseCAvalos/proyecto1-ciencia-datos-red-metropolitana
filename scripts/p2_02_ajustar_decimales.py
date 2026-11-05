#!/usr/bin/env python3
"""Corrige importes de features_usuario_p2.sql sin tocar otros modelos."""
from pathlib import Path

ruta = Path("dbt/models/phase2/features_usuario_p2.sql")
if not ruta.exists():
    raise SystemExit(f"No existe {ruta}. Conserva el archivo creado localmente.")
texto = ruta.read_text(encoding="utf-8")
antes = "CAST(s.monto_q AS DOUBLE)"
despues = "CAST(s.monto_q AS DECIMAL(18, 2))"
n = texto.count(antes)
if n == 4:
    texto = texto.replace(antes, despues)
elif n == 0 and texto.count(despues) == 4:
    print("Conversión de importes ya aplicada.")
else:
    raise SystemExit(f"Patrón monetario inesperado: DOUBLE={n}, DECIMAL={texto.count(despues)}")

promedio_original = "AVG(COALESCE(monto_q, 0)) AS gasto_promedio_q"
promedio_nuevo = "ROUND(AVG(COALESCE(monto_q, 0)), 2) AS gasto_promedio_q"
if promedio_original in texto:
    texto = texto.replace(promedio_original, promedio_nuevo)
elif promedio_nuevo not in texto:
    raise SystemExit("No se encontró la expresión de gasto promedio esperada.")

ruta.write_text(texto, encoding="utf-8")
print(f"Corrección monetaria guardada: {ruta}")
