#!/usr/bin/env python3
"""Prueba de invariancia A: compara features originales vs fuentes censuradas.

Requiere SQL compilado: dbt compile --select features_usuario_p2
No modifica tablas Silver. Reporta diferencias estructurales y numéricas.
"""
from pathlib import Path
import csv
import duckdb

DB = Path("data/outputs/red_metropolitana.duckdb")
OUT = Path("data/outputs/proyecto2/p2_invariancia_A.csv")
FECHAS = {
    "silver_tm_validaciones": "event_ts_local",
    "silver_transurbano": "event_ts_local",
    "silver_metroriel": "salida_ts_local",
    "silver_aerometro": "event_ts_local",
    "silver_padron_scd2": "commit_ts",
}
FLOATS = {"proporcion_hora_pico", "gasto_28d_q", "gasto_promedio_q"}


def main():
    candidatos = list(
        Path("dbt/target/compiled").rglob("features_usuario_p2.sql")
    )
    if len(candidatos) != 1:
        raise SystemExit(
            f"Esperaba un SQL compilado, encontré {len(candidatos)}. "
            "Ejecuta dbt compile --select features_usuario_p2."
        )
    sql = candidatos[0].read_text(encoding="utf-8").strip().rstrip(";")
    con = duckdb.connect(str(DB), read_only=True)
    con.execute(f"CREATE TEMP TABLE original_a AS SELECT * FROM ({sql}) q WHERE corte='A'")
    censurado = sql
    for tabla, columna in FECHAS.items():
        temporal = "temporal_" + tabla
        con.execute(
            f"CREATE TEMP VIEW {temporal} AS "
            f"SELECT * FROM main.{tabla} WHERE {columna} < TIMESTAMP '2026-07-01'"
        )
        ref = f'"red_metropolitana"."main"."{tabla}"'
        if ref not in censurado:
            raise RuntimeError(f"Referencia de modelo no encontrada: {tabla}")
        censurado = censurado.replace(ref, temporal)
    con.execute(
        f"CREATE TEMP TABLE censurado_a AS SELECT * FROM ({censurado}) q WHERE corte='A'"
    )

    total_o = con.execute("SELECT COUNT(*) FROM original_a").fetchone()[0]
    total_c = con.execute("SELECT COUNT(*) FROM censurado_a").fetchone()[0]
    diferencias_id = con.execute("""
        SELECT COUNT(*) FROM (
            (SELECT usuario_pseudo FROM original_a EXCEPT
             SELECT usuario_pseudo FROM censurado_a)
            UNION ALL
            (SELECT usuario_pseudo FROM censurado_a EXCEPT
             SELECT usuario_pseudo FROM original_a)
        )
    """).fetchone()[0]

    cols = [
        r[0] for r in con.execute("DESCRIBE original_a").fetchall()
        if r[0] != "usuario_pseudo"
    ]
    filas = []
    for campo in cols:
        exactas = con.execute(f"""
            SELECT COUNT(*) FROM original_a o
            JOIN censurado_a c USING (usuario_pseudo)
            WHERE o.{campo} IS DISTINCT FROM c.{campo}
        """).fetchone()[0]
        if campo in FLOATS:
            significativas = con.execute(f"""
                SELECT COUNT(*) FROM original_a o
                JOIN censurado_a c USING (usuario_pseudo)
                WHERE o.{campo} IS DISTINCT FROM c.{campo}
                  AND (
                      o.{campo} IS NULL OR c.{campo} IS NULL
                      OR ABS(o.{campo}-c.{campo}) >
                         1e-8 + 1e-10 * GREATEST(
                             ABS(o.{campo}), ABS(c.{campo})
                         )
                  )
            """).fetchone()[0]
        else:
            significativas = exactas
        filas.append({
            "columna": campo,
            "diferencias_exactas": exactas,
            "diferencias_significativas": significativas,
        })
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(filas[0]))
        writer.writeheader()
        writer.writerows(filas)
    con.close()
    n = sum(r["diferencias_significativas"] for r in filas)
    print(f"Original A: {total_o:,}; censurado A: {total_c:,}")
    print(f"Identidades distintas: {diferencias_id:,}")
    for fila in filas:
        if fila["diferencias_exactas"]:
            print(fila)
    print(f"Diferencias significativas: {n:,}")
    print(f"Reporte: {OUT}")
    if total_o != total_c or diferencias_id or n:
        raise SystemExit("FALLÓ: revisar diferencias antes de entrenar.")
    print("APROBADO: A invariante a fuentes posteriores al corte.")


if __name__ == "__main__":
    main()
