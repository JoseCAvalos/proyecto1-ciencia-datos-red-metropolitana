#!/usr/bin/env python3
"""Comprobación no destructiva de fuentes del Proyecto 2.

Uso: python scripts/p2_00_preflight.py --datos data/input
No elimina, transforma ni carga datos. Revisa los 9 nombres y reporta filas.
"""
from __future__ import annotations
import argparse
import csv
from pathlib import Path

FUENTES = (
    "tm_estaciones.csv",
    "tu_paradas.csv",
    "mr_estaciones.csv",
    "am_estaciones.csv",
    "transurbano_transacciones.csv",
    "metroriel_viajes.jsonl",
    "cdc_padron_usuarios.csv",
    "transmetro_validaciones.csv",
    "aerometro_boardings.csv",
)

def contar(ruta: Path) -> int:
    with ruta.open("r", encoding="utf-8-sig", newline="") as f:
        if ruta.suffix.lower() == ".csv":
            return sum(1 for _ in csv.DictReader(f))
        return sum(1 for linea in f if linea.strip())

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--datos", type=Path, default=Path("data/input"))
    parser.add_argument("--salida", type=Path, default=Path("data/outputs/proyecto2_fuentes_preflight.csv"))
    args = parser.parse_args()
    registros = []
    for nombre in FUENTES:
        ruta = args.datos / nombre
        estado = "OK" if ruta.is_file() else "FALTANTE"
        filas = ""
        if ruta.is_file():
            try:
                filas = contar(ruta)
            except (OSError, UnicodeError, csv.Error) as exc:
                estado = f"ERROR: {exc}"
        registros.append({"archivo": nombre, "estado": estado, "filas_fuente": filas,
                          "filas_esperadas": "", "diferencia": ""})
    args.salida.parent.mkdir(parents=True, exist_ok=True)
    with args.salida.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(registros[0]))
        writer.writeheader()
        writer.writerows(registros)
    for registro in registros:
        print(f'{registro["archivo"]}: {registro["estado"]}; filas={registro["filas_fuente"]}')
    print(f"Reporte: {args.salida}")
    return 0 if all(r["estado"] == "OK" for r in registros) else 1

if __name__ == "__main__":
    raise SystemExit(main())
