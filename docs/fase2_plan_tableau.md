# Fase 2 - Plan del tablero Tableau

El tablero se conecta a Gold y debe responder:

1. Demanda por modo, zona y hora.
2. Zonas sin servicio.
3. Usuarios que usan más de un sistema.
4. Caso MetroRiel en zonas 12, 8, 1, 6 y 17.

## Fuentes listas para Tableau

- mart_demanda_dashboard
- mart_cobertura_zona
- mart_transbordo_usuario
- mart_metroriel_zonas

## Hojas

### Demanda por modo
Barras: nombre_modo vs SUM(cantidad).

### Demanda por hora
Línea: hora vs SUM(cantidad), color por nombre_modo.

### Demanda por zona
Barras horizontales: zona_nombre vs SUM(cantidad).

### Cobertura
Tabla: zona_nombre, cantidad_modos, modos_disponibles, tiene_servicio.

### Usuarios multimodales
KPI:
- COUNT(usuario_sk)
- SUM(IF [usa_mas_de_un_sistema] THEN 1 ELSE 0 END)
- porcentaje multimodal.

### Caso MetroRiel
Barras: zona_nombre vs demanda_total; mostrar estaciones_metroriel y atendida_por_metroriel.

## Dashboard

Fila superior: demanda total, usuarios multimodales, zonas sin servicio.
Centro: demanda por modo y hora.
Inferior: demanda/cobertura por zona y caso MetroRiel.

Filtros globales: modo, zona, fecha, hora pico.

## Trazabilidad

Tableau -> marts Fase 2 -> Gold -> Silver -> Staging -> Bronze.
