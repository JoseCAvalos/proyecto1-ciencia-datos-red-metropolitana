from prefect import flow, task
from pathlib import Path
import csv
import os
import socket
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[1]


@task
def cmd(args):
    print("EJECUTANDO:", " ".join(map(str, args)))
    subprocess.run(args, check=True, cwd=ROOT)


@task
def levantar_kafka():
    subprocess.run(
        ["docker", "compose", "up", "-d"],
        check=True,
        cwd=ROOT
    )

    host = os.getenv("KAFKA_HOST", "localhost")
    port = int(os.getenv("KAFKA_PORT", "9092"))

    for _ in range(60):
        try:
            with socket.create_connection((host, port), timeout=1):
                print(f"Kafka disponible en {host}:{port}")
                return
        except OSError:
            time.sleep(1)

    raise RuntimeError(
        f"Kafka no estuvo disponible en {host}:{port} después de 60 segundos"
    )


def contar_csv(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return sum(1 for _ in csv.DictReader(f))


def contar_jsonl_stream(topic):
    total = 0

    patron = (
        ROOT
        / "data"
        / "bronze"
    )

    for archivo in patron.glob(
        f"ingestion_date=*/{topic}_stream.jsonl"
    ):
        with open(archivo, encoding="utf-8") as f:
            total += sum(1 for linea in f if linea.strip())

    return total


@task
def asegurar_stream(archivo_csv, topic):
    origen = ROOT / "data" / "input" / archivo_csv

    if not origen.exists():
        raise FileNotFoundError(
            f"No existe el archivo de entrada: {origen}"
        )

    esperados = contar_csv(origen)
    actuales = contar_jsonl_stream(topic)

    print(
        f"{topic}: fuente={esperados:,} "
        f"bronze={actuales:,}"
    )

    if actuales == esperados:
        print(
            f"{topic}: Bronze completo. "
            "No se republica Kafka."
        )
        return

    if actuales != 0:
        raise RuntimeError(
            f"{topic}: Bronze está parcialmente cargado "
            f"({actuales:,}/{esperados:,}). "
            "Se detiene para evitar republicar eventos "
            "y romper la idempotencia."
        )

    print(f"{topic}: iniciando publicación Kafka")

    subprocess.run(
        [
            sys.executable,
            "scripts/03_publicar_kafka.py",
            f"data/input/{archivo_csv}",
            topic,
        ],
        check=True,
        cwd=ROOT,
    )

    subprocess.run(
        [
            sys.executable,
            "scripts/04_consumir_kafka.py",
            topic,
        ],
        check=True,
        cwd=ROOT,
    )

    finales = contar_jsonl_stream(topic)

    print(
        f"{topic}: Bronze después de Kafka="
        f"{finales:,}"
    )

    if finales != esperados:
        raise RuntimeError(
            f"{topic}: se esperaban {esperados:,} "
            f"eventos y Bronze contiene {finales:,}"
        )


@flow(name="red-metropolitana-fase1")
def pipeline():

    # 1. Verificar fuentes
    cmd([sys.executable, "scripts/01_inspeccionar.py"])

    # 2. Levantar infraestructura Kafka
    levantar_kafka()

    # 3. Batch + CDC hacia Bronze
    cmd([sys.executable, "scripts/02_bronze.py"])

    # 4. Streaming Kafka hacia Bronze
    asegurar_stream(
        "transmetro_validaciones.csv",
        "transmetro_validaciones",
    )

    asegurar_stream(
        "aerometro_boardings.csv",
        "aerometro_boardings",
    )

    # 5. Catálogos mínimos de usuarios
    cmd([sys.executable, "scripts/08_catalogos_usuarios.py"])

    # 6. Silver + Gold + cuarentena
    cmd([
        "dbt",
        "run",
        "--project-dir",
        "dbt",
        "--profiles-dir",
        "dbt",
    ])

    # 7. Pruebas de calidad dbt
    cmd([
        "dbt",
        "test",
        "--project-dir",
        "dbt",
        "--profiles-dir",
        "dbt",
    ])

    # 8. Validación final de conteos
    cmd([sys.executable, "scripts/05_validar_resultados.py"])


if __name__ == "__main__":
    pipeline()
