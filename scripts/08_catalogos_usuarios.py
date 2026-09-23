from pathlib import Path
import pandas as pd

INPUT = Path("data/input")
OUTPUT = Path("data/outputs")

OUTPUT.mkdir(parents=True, exist_ok=True)

# -----------------------------
# TRANSURBANO
# -----------------------------
tu = pd.read_csv(
    INPUT / "transurbano_transacciones.csv",
    dtype={"num_tarjeta": str}
)

usuarios_tu = (
    tu["num_tarjeta"]
    .dropna()
    .astype(str)
    .drop_duplicates()
    .sort_values()
)

pd.DataFrame({
    "llave_usuario": usuarios_tu
}).to_csv(
    OUTPUT / "usuarios_transurbano.csv",
    index=False,
    encoding="utf-8-sig"
)

# -----------------------------
# METRORIEL
# -----------------------------
mr = pd.read_json(
    INPUT / "metroriel_viajes.jsonl",
    lines=True
)

usuarios_mr = (
    mr["card"]
    .dropna()
    .astype(str)
    .drop_duplicates()
    .sort_values()
)

pd.DataFrame({
    "llave_usuario": usuarios_mr
}).to_csv(
    OUTPUT / "usuarios_metroriel.csv",
    index=False,
    encoding="utf-8-sig"
)

# -----------------------------
# AEROMETRO
# -----------------------------
am = pd.read_csv(
    INPUT / "aerometro_boardings.csv",
    dtype={"user_hash": str}
)

usuarios_am = (
    am["user_hash"]
    .dropna()
    .astype(str)
    .drop_duplicates()
    .sort_values()
)

pd.DataFrame({
    "llave_usuario": usuarios_am
}).to_csv(
    OUTPUT / "usuarios_aerometro.csv",
    index=False,
    encoding="utf-8-sig"
)

# -----------------------------
# RESUMEN
# -----------------------------
resumen = pd.DataFrame([
    {
        "operador": "Transurbano",
        "usuarios_unicos": len(usuarios_tu)
    },
    {
        "operador": "MetroRiel",
        "usuarios_unicos": len(usuarios_mr)
    },
    {
        "operador": "Aerometro",
        "usuarios_unicos": len(usuarios_am)
    }
])

resumen.to_csv(
    OUTPUT / "usuarios_unicos_resumen.csv",
    index=False,
    encoding="utf-8-sig"
)

print("\nCATALOGOS MINIMOS GENERADOS CORRECTAMENTE\n")
print(resumen.to_string(index=False))

print("\nArchivos creados:")
print(" - data/outputs/usuarios_transurbano.csv")
print(" - data/outputs/usuarios_metroriel.csv")
print(" - data/outputs/usuarios_aerometro.csv")
print(" - data/outputs/usuarios_unicos_resumen.csv")