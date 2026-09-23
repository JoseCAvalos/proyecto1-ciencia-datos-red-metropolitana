# Capturas que debe tomar el estudiante

1. `docker compose ps` mostrando Kafka activo.
2. Terminal publicando Transmetro a Kafka.
3. Terminal consumiendo Transmetro desde Kafka.
4. Terminal publicando/consumiendo Aerómetro.
5. Salida de `python scripts/01_inspeccionar.py`.
6. Salida de `python scripts/02_bronze.py` y estructura `data/bronze/ingestion_date=...`.
7. `dbt run` exitoso.
8. `dbt test` exitoso.
9. `dbt docs generate` y grafo/linaje abierto en navegador.
10. `python scripts/05_validar_resultados.py`.
11. `python scripts/06_prueba_idempotencia.py`, mostrando `IDEMPOTENCIA: OK`.
12. Captura de las tablas de Gold en DuckDB (opcional si el profesor solicita evidencia visual adicional).

No edites los conteos para que coincidan: si difieren, revisa la causa.
