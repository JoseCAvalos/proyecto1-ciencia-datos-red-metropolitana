from pathlib import Path
import csv
import time
import duckdb

DB = Path("data/outputs/red_metropolitana.duckdb")
OUT = Path("data/outputs/fase2")
OUT.mkdir(parents=True, exist_ok=True)
SALIDA = OUT / "metricas_fase2.csv"

if not DB.exists():
    raise SystemExit(f"No existe la base DuckDB: {DB}")

con = duckdb.connect(str(DB), read_only=True)

consultas = {
    "demanda_total_red": "select coalesce(sum(cantidad),0) from mart_demanda_dashboard",
    "usuarios_multimodales": "select count(*) from mart_transbordo_usuario where usa_mas_de_un_sistema",
    "usuarios_con_modo_registrado": "select count(*) from mart_transbordo_usuario",
    "zonas_sin_servicio": "select count(*) from mart_cobertura_zona where not tiene_servicio",
    "zonas_con_servicio": "select count(*) from mart_cobertura_zona where tiene_servicio",
}

filas=[]
for nombre,sql in consultas.items():
    t0=time.perf_counter()
    valor=con.execute(sql).fetchone()[0]
    ms=(time.perf_counter()-t0)*1000
    filas.append((nombre,valor,round(ms,3)))
    print(f"{nombre}: {valor} ({ms:.3f} ms)")

print("\nDemanda por modo:")
for row in con.execute("""
    select nombre_modo, sum(cantidad) demanda
    from mart_demanda_dashboard
    group by 1
    order by demanda desc
""").fetchall():
    print(row)

print("\nTop zonas:")
for row in con.execute("""
    select zona_nombre, sum(cantidad) demanda
    from mart_demanda_dashboard
    where zona_nombre is not null
    group by 1
    order by demanda desc
    limit 10
""").fetchall():
    print(row)

print("\nZonas MetroRiel:")
for row in con.execute("""
    select zona_nombre, demanda_total, usuarios_distintos,
           estaciones_metroriel, atendida_por_metroriel
    from mart_metroriel_zonas
    order by demanda_total desc
""").fetchall():
    print(row)

with open(SALIDA,"w",newline="",encoding="utf-8") as f:
    w=csv.writer(f)
    w.writerow(["metrica","valor","tiempo_consulta_ms"])
    w.writerows(filas)

con.close()
print(f"\nMétricas guardadas en: {SALIDA}")
