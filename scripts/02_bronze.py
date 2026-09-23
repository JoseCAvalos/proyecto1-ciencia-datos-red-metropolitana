from pathlib import Path
from datetime import datetime, timezone
import hashlib, shutil, pandas as pd

IN=Path("data/input"); BR=Path("data/bronze"); OUT=Path("data/outputs")
OUT.mkdir(parents=True,exist_ok=True); BR.mkdir(parents=True,exist_ok=True)

# TM y Aerómetro NO entran por este script: deben llegar por Kafka.
BATCH_CDC_FILES = [
    "tm_estaciones.csv","tu_paradas.csv","mr_estaciones.csv","am_estaciones.csv",
    "transurbano_transacciones.csv","metroriel_viajes.jsonl","cdc_padron_usuarios.csv"
]

manifest_path=OUT/"bronze_manifest.csv"
if manifest_path.exists():
    old=pd.read_csv(manifest_path)
else:
    old=pd.DataFrame(columns=["archivo","sha256","filas","ingestion_ts","ruta_bronze","via"])

records=old.to_dict("records")
known=set(old["sha256"].astype(str)) if len(old) else set()
part=datetime.now().strftime("%Y-%m-%d")

for name in BATCH_CDC_FILES:
    p=IN/name
    if not p.exists():
        print("FALTANTE:",name); continue
    sha=hashlib.sha256(p.read_bytes()).hexdigest()
    if sha in known:
        print("YA INGESTADO:",p.name); continue
    dest=BR/f"ingestion_date={part}"/p.name
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(p,dest)
    if p.suffix==".csv":
        filas=len(pd.read_csv(p))
    else:
        filas=sum(1 for _ in open(p,encoding="utf-8"))
    via="CDC" if name=="cdc_padron_usuarios.csv" else "BATCH"
    records.append({"archivo":p.name,"sha256":sha,"filas":filas,
                    "ingestion_ts":datetime.now(timezone.utc).isoformat(),
                    "ruta_bronze":str(dest),"via":via})
    known.add(sha)

pd.DataFrame(records).to_csv(manifest_path,index=False,encoding="utf-8-sig")
print(pd.DataFrame(records)[["archivo","filas","via","ingestion_ts"]].to_string(index=False))
