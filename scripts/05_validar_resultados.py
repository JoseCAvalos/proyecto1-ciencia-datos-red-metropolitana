from pathlib import Path
import pandas as pd, duckdb
OUT=Path("data/outputs")
db=OUT/"red_metropolitana.duckdb"
if not db.exists(): raise SystemExit("No existe la base. Ejecuta dbt primero.")
con=duckdb.connect(str(db),read_only=True)
queries={
"silver_tm":"select count(*) from silver_tm_validaciones",
"silver_tu":"select count(*) from silver_transurbano",
"silver_mr":"select count(*) from silver_metroriel",
"silver_am":"select count(*) from silver_aerometro",
"gold_fact_abordaje":"select count(*) from fact_abordaje",
"gold_fact_metroriel":"select count(*) from fact_viaje_metroriel",
"cuarentena":"select count(*) from cuarentena"
}
rows=[]
for name,q in queries.items():
    try: rows.append([name,con.execute(q).fetchone()[0]])
    except Exception as e: rows.append([name,f"ERROR: {e}"])
df=pd.DataFrame(rows,columns=["objeto","conteo"])
df.to_csv(OUT/"conteos_pipeline.csv",index=False,encoding="utf-8-sig")
print(df.to_string(index=False))
