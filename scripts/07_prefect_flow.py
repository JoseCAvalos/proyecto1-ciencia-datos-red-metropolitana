from prefect import flow,task
import subprocess,sys
@task
def cmd(args): subprocess.run(args,check=True)
@flow(name="red-metropolitana-fase1")
def pipeline():
    cmd([sys.executable,"scripts/01_inspeccionar.py"])
    cmd([sys.executable,"scripts/02_bronze.py"])
    cmd(["dbt","run","--project-dir","dbt","--profiles-dir","dbt"])
    cmd(["dbt","test","--project-dir","dbt","--profiles-dir","dbt"])
    cmd([sys.executable,"scripts/05_validar_resultados.py"])
if __name__=="__main__": pipeline()
