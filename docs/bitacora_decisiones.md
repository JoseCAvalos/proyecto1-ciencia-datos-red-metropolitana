# Bitácora de decisiones de diseño

## Arquitectura

**Bronze en lake local:** carpetas particionadas por fecha para preservar datos crudos y separar ingestión de transformación.

**Transurbano por batch:** la fuente se entrega como archivo cerrado. La consecuencia es mayor latencia frente a streaming, pero mejora reproducibilidad.

**Kafka para Transmetro y Aerómetro:** streaming simulado publicando los CSV línea por línea.

**Staging ephemeral:** staging adapta formatos y no necesita persistir.

## Calidad e integración

**Cuarentena:** los registros inválidos se conservan con motivo de rechazo.

**Identidad:** TM, TU y MR se aproximan por el componente numérico de sus llaves. Aerómetro permanece separado porque no existe una correspondencia con su hash.

**SCD Tipo 2:** el padrón conserva historial; las bajas no eliminan físicamente registros.

## Modelo dimensional

**Grano principal:** una fila por abordaje válido para TM, TU y AM.

**MetroRiel:** se modela en una segunda tabla de hechos porque registra viajes completos origen-destino.

**Gold solo desde Silver:** mantiene separación de responsabilidades y trazabilidad.

## Fase 2

**Marts para Tableau:** demanda, cobertura, multimodalidad y MetroRiel derivados de Gold.

**Features desde Silver:** se construyen desde el detalle atómico requerido para feature engineering.

**Fecha de corte:** timestamp máximo observado en eventos válidos.

**Normalización de zonas:** se agrega macro dbt `normalizar_zona` y se aplica en estaciones/paradas y padrón Silver para evitar dimensiones duplicadas por diferencias de mayúsculas/minúsculas. Esto protege `dim_zona`, `dim_estacion_parada`, `mart_cobertura_zona`, `mart_metroriel_zonas` y `features_usuario`.

**Métricas locales:** los tamaños de DuckDB/CSV y tiempos de consulta se miden con `scripts/10_metricas_fase2.py`. No se registran valores inventados cuando el archivo local de base de datos no está disponible.

## Seguridad

**Seudonimización:** SHA-256 más `PSEUDONYM_SALT` antes de Gold.

**Acceso:** analistas consumen Gold/agregados; el detalle individual queda restringido.

**Retención:** 12 meses de detalle individual antes de agregar o anonimizar, salvo necesidad justificada.
