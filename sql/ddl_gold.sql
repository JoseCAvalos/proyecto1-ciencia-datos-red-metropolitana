-- DDL lógico de la capa Gold. dbt materializa estas tablas.
CREATE TABLE dim_modo (
  modo_sk BIGINT PRIMARY KEY, codigo_modo VARCHAR UNIQUE NOT NULL, nombre_modo VARCHAR NOT NULL
);
CREATE TABLE dim_zona (
  zona_sk BIGINT PRIMARY KEY, zona_nombre VARCHAR UNIQUE NOT NULL
);
CREATE TABLE dim_tiempo (
  tiempo_sk BIGINT PRIMARY KEY, ts_hora TIMESTAMP, fecha DATE, hora INTEGER,
  dia_semana INTEGER, es_dia_habil BOOLEAN, es_hora_pico BOOLEAN
);
CREATE TABLE dim_usuario (
  usuario_sk BIGINT PRIMARY KEY, usuario_pseudo VARCHAR UNIQUE NOT NULL,
  perfil VARCHAR, zona_residencia VARCHAR, activo BOOLEAN
);
CREATE TABLE dim_estacion_parada (
  estacion_parada_sk BIGINT PRIMARY KEY, operador VARCHAR, codigo VARCHAR,
  nombre VARCHAR, ruta VARCHAR, zona_nombre VARCHAR, lat DOUBLE, lon DOUBLE
);
CREATE TABLE dim_ruta (
  ruta_sk BIGINT PRIMARY KEY, operador VARCHAR, ruta VARCHAR
);
CREATE TABLE fact_abordaje (
  abordaje_sk BIGINT PRIMARY KEY, evento_uid VARCHAR UNIQUE NOT NULL,
  usuario_sk BIGINT, tiempo_sk BIGINT, zona_sk BIGINT, modo_sk BIGINT,
  estacion_parada_sk BIGINT, ruta_sk BIGINT, monto_q DECIMAL(14,2),
  conteo_abordaje INTEGER
);
CREATE TABLE fact_viaje_metroriel (
  viaje_sk BIGINT PRIMARY KEY, viaje_uid VARCHAR UNIQUE NOT NULL,
  usuario_sk BIGINT, tiempo_salida_sk BIGINT, tiempo_llegada_sk BIGINT,
  origen_sk BIGINT, destino_sk BIGINT, modo_sk BIGINT, monto_q DECIMAL(14,2),
  duration_s BIGINT, conteo_viaje INTEGER
);
