#!/usr/bin/env python3
"""Fase 1: baselines y logísticas L1/L2 con CV estratificada, SOLO corte A.

Uso: python scripts/p2_04_baselines.py
Dependencias: duckdb pandas numpy scikit-learn matplotlib
No lee las etiquetas B. Escribe evidencia en data/outputs/proyecto2/.
"""
from pathlib import Path
import csv
import json
import numpy as np
import duckdb

from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import average_precision_score
from sklearn.model_selection import StratifiedKFold
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

BASE = Path("data/outputs")
OUT = BASE / "proyecto2"
DB = BASE / "red_metropolitana.duckdb"
NUM = [
    "viajes_7d", "viajes_14d", "viajes_28d",
    "cantidad_modos_distintos", "dias_desde_ultimo_viaje",
    "proporcion_hora_pico", "gasto_28d_q", "gasto_promedio_q",
]
CAT = ["modo_mas_usado", "zona_origen_mas_frecuente"]


def modelo(penalizacion, c):
    pre = ColumnTransformer([
        ("num", Pipeline([
            ("imputar", SimpleImputer(strategy="median")),
            ("escalar", StandardScaler()),
        ]), NUM),
        ("cat", Pipeline([
            ("imputar", SimpleImputer(strategy="most_frequent")),
            ("codificar", OneHotEncoder(handle_unknown="ignore")),
        ]), CAT),
    ])
    return Pipeline([
        ("pre", pre),
        ("lr", LogisticRegression(
            penalty=penalizacion, C=c, solver="liblinear",
            max_iter=1500, random_state=2026,
        )),
    ])


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    if not DB.is_file():
        raise SystemExit(f"No existe la base {DB}")
    con = duckdb.connect(str(DB), read_only=True)
    try:
        filas = con.execute("""
            SELECT f.*, e.abandono_30d
            FROM features_usuario_p2 f
            INNER JOIN etiquetas_usuario_p2 e
              ON f.corte=e.corte AND f.usuario_pseudo=e.usuario_pseudo
            WHERE f.corte='A' AND e.corte='A'
              AND e.abandono_30d IS NOT NULL
        """).df()
    finally:
        con.close()

    if filas.empty or filas["usuario_pseudo"].duplicated().any():
        raise RuntimeError("Población A vacía o identidades duplicadas.")
    if filas["abandono_30d"].isna().any():
        raise RuntimeError("Hay etiquetas nulas en A.")
    X = filas[NUM + CAT].copy()
    y = filas["abandono_30d"].astype(int).to_numpy()
    if set(np.unique(y)) != {0, 1}:
        raise RuntimeError("A debe contener ambas clases.")
    folds = list(StratifiedKFold(
        n_splits=5, shuffle=True, random_state=2026,
    ).split(X, y))

    prevalencia = float(y.mean())
    resultados = []
    for k, (tr, te) in enumerate(folds, 1):
        # Baselines: prevalencia entrenamiento y ranking por baja frecuencia.
        p_train = float(y[tr].mean())
        resultados.append({
            "modelo": "prevalencia", "lambda": "",
            "fold": k, "ap": average_precision_score(
                y[te], np.full(len(te), p_train)
            ),
        })
        puntuacion = -X.iloc[te]["viajes_7d"].fillna(
            X.iloc[tr]["viajes_7d"].median()
        ).to_numpy()
        resultados.append({
            "modelo": "una_feature_viajes_7d", "lambda": "",
            "fold": k, "ap": average_precision_score(y[te], puntuacion),
        })

    lambdas = [0.01, 0.1, 1.0, 10.0]
    for penalizacion in ("l1", "l2"):
        for lam in lambdas:
            for k, (tr, te) in enumerate(folds, 1):
                pipe = modelo(penalizacion, 1.0 / lam)
                pipe.fit(X.iloc[tr], y[tr])
                pred = pipe.predict_proba(X.iloc[te])[:, 1]
                resultados.append({
                    "modelo": penalizacion, "lambda": lam,
                    "fold": k,
                    "ap": float(average_precision_score(y[te], pred)),
                })
            print(f"{penalizacion} lambda={lam} terminado")

    with (OUT / "p2_cv_folds_A.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["modelo", "lambda", "fold", "ap"])
        w.writeheader()
        w.writerows(resultados)

    agrupado = {}
    for r in resultados:
        llave = (r["modelo"], str(r["lambda"]))
        agrupado.setdefault(llave, []).append(float(r["ap"]))
    resumen = [
        {
            "modelo": k[0], "lambda": k[1],
            "ap_media": float(np.mean(v)),
            "ap_desv": float(np.std(v, ddof=1)),
        }
        for k, v in agrupado.items()
    ]
    resumen.sort(key=lambda r: (r["modelo"], str(r["lambda"])))
    with (OUT / "p2_cv_resumen_A.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=[
            "modelo", "lambda", "ap_media", "ap_desv",
        ])
        w.writeheader()
        w.writerows(resumen)

    candidatos = [r for r in resumen if r["modelo"] in ("l1", "l2")]
    ganador = max(candidatos, key=lambda r: r["ap_media"])
    final = modelo(ganador["modelo"], 1 / float(ganador["lambda"]))
    final.fit(X, y)
    columnas = final.named_steps["pre"].get_feature_names_out()
    pesos = final.named_steps["lr"].coef_[0]
    orden = sorted(
        zip(columnas, pesos), key=lambda r: abs(r[1]), reverse=True
    )
    with (OUT / "p2_coeficientes_A.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["caracteristica_transformada", "coeficiente"])
        w.writerows(orden)

    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    fig, ax = plt.subplots(figsize=(8, 5))
    for pen in ("l1", "l2"):
        filas_pen = sorted(
            (r for r in resumen if r["modelo"] == pen),
            key=lambda r: float(r["lambda"])
        )
        ax.errorbar(
            [float(r["lambda"]) for r in filas_pen],
            [r["ap_media"] for r in filas_pen],
            yerr=[r["ap_desv"] for r in filas_pen],
            marker="o", capsize=3, label=pen.upper()
        )
    ax.axhline(prevalencia, linestyle="--", label="Prevalencia A")
    ax.set_xscale("log")
    ax.set_xlabel("Lambda (regularización); C=1/lambda")
    ax.set_ylabel("Average Precision, media ± desv. estándar (5 folds)")
    ax.set_title("Corte A: comparación L1 y L2")
    ax.legend()
    fig.tight_layout()
    fig.savefig(OUT / "p2_ap_vs_lambda_A.png", dpi=160)
    plt.close(fig)

    manifiesto = {
        "corte_entrenamiento": "A",
        "tamano_A": len(y),
        "positivos_A": int(y.sum()),
        "prevalencia_A": prevalencia,
        "folds": 5,
        "random_state": 2026,
        "seleccion": ganador,
        "top_5_coeficientes": orden[:5],
        "advertencia": "B reservado. Resultados condicionados a identidad y CDC.",
    }
    (OUT / "p2_modelo_A_resumen.json").write_text(
        json.dumps(manifiesto, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(json.dumps(manifiesto, indent=2, ensure_ascii=False))
    print(f"Evidencias: {OUT}")


if __name__ == "__main__":
    main()
