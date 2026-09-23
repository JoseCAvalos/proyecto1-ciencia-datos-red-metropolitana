from pathlib import Path
import subprocess,sys,pandas as pd,hashlib
OUT=Path("data/outputs"); OUT.mkdir(parents=True,exist_ok=True)
def run():
    subprocess.run(["dbt","run","--project-dir","dbt","--profiles-dir","dbt"],check=True)
    subprocess.run([sys.executable,"scripts/05_validar_resultados.py"],check=True)
    p=OUT/"conteos_pipeline.csv"
    return p.read_bytes(),pd.read_csv(p)
b1,d1=run()
b2,d2=run()
ok=d1.equals(d2)
pd.concat([d1.assign(corrida=1),d2.assign(corrida=2)]).to_csv(
    OUT/"evidencia_idempotencia.csv",index=False,encoding="utf-8-sig")
print("IDEMPOTENCIA:", "OK - CONTEOS IDÉNTICOS" if ok else "FALLÓ - REVISAR")
print(pd.concat([d1.assign(corrida=1),d2.assign(corrida=2)]).to_string(index=False))
if not ok: raise SystemExit(2)
