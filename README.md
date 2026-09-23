# Proyecto 1 - Red Metropolitana de Transporte
## Fase 1 - Arquitectura

### Decisiones
- Streaming: Kafka para Transmetro y Aerómetro.
- Batch: cuatro catálogos, MetroRiel y Transurbano.
- CDC: `cdc_padron_usuarios.csv`.
- Bronze: lake local por carpetas. Batch/CDC copian sus archivos crudos; Transmetro y Aerómetro llegan exclusivamente desde Kafka como JSONL con timestamp de ingesta. Todo queda particionado por fecha.
- Staging: modelos `ephemeral` de dbt; no persisten entre corridas.
- Silver/Gold: DuckDB + dbt.
- Orquestación: Prefect.
- Cuarentena: registros inválidos se conservan con motivo.
- Gold **solo** referencia modelos Silver.
- Identidad: TM/TU/MR se aproximan mediante el componente numérico de sus llaves; Aerómetro permanece separado porque solo entrega hash.
- Seudonimización: SHA-256 + `PSEUDONYM_SALT` antes de Gold.
