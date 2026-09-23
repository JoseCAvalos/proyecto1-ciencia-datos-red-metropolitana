from pathlib import Path
import pandas as pd, json
IN=Path("data/input"); OUT=Path("data/outputs"); OUT.mkdir(parents=True,exist_ok=True)
expected=["tm_estaciones.csv","tu_paradas.csv","mr_estaciones.csv","am_estaciones.csv",
"transmetro_validaciones.csv","transurbano_transacciones.csv","metroriel_viajes.jsonl",
"aerometro_boardings.csv","cdc_padron_usuarios.csv"]
rows=[]
for name in expected:
    p=IN/name
    if not p.exists():
        rows.append([name,"FALTANTE",0,""]); continue
    if p.suffix==".jsonl":
        count=0; sample=[]
        with open(p,encoding="utf-8") as f:
            for line in f:
                count+=1
                if len(sample)<100: sample.append(json.loads(line))
        cols=list(pd.json_normalize(sample,sep="_").columns)
    else:
        df=pd.read_csv(p)
        count=len(df); cols=list(df.columns)
    rows.append([name,"OK",count," | ".join(cols)])
pd.DataFrame(rows,columns=["archivo","estado","filas","columnas"]).to_csv(
    OUT/"schema_report.csv",index=False,encoding="utf-8-sig")
print(pd.DataFrame(rows,columns=["archivo","estado","filas","columnas"]).to_string(index=False))
