from pathlib import Path
import duckdb

DB = Path("data/outputs/red_metropolitana.duckdb")
OUT = Path("data/outputs/fase2")
OUT.mkdir(parents=True, exist_ok=True)

TABLAS = [
    "mart_demanda_dashboard",
    "mart_cobertura_zona",
    "mart_transbordo_usuario",
    "mart_metroriel_zonas",
    "features_usuario",
]

if not DB.exists():
    raise SystemExit(f"No existe la base DuckDB: {DB}")

con = duckdb.connect(str(DB), read_only=True)

for tabla in TABLAS:
    destino = OUT / f"{tabla}.csv"
    con.execute(
        f"COPY (SELECT * FROM {tabla}) "
        f"TO '{destino.as_posix()}' (HEADER, DELIMITER ',')"
    )
    n = con.execute(f"SELECT COUNT(*) FROM {tabla}").fetchone()[0]
    print(f"{tabla}: {n:,} filas -> {destino}")

con.close()
print("Exportación Fase 2 completada.")
