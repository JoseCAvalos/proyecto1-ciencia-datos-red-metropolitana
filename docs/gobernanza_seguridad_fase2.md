# Gobernanza, documentación y seguridad

## Definiciones oficiales

**Viaje/abordaje:** TM, TU y AM usan evento válido de abordaje; MR usa viaje completo válido.

**Usuario activo:** usuario con al menos un evento válido en el periodo analizado. No confundir con el estado administrativo `activo` del padrón CDC.

**Demanda:** suma de `cantidad` en `mart_demanda_dashboard`.

**Usuario multimodal:** usuario observado en más de un modo. Aerómetro no puede empatarse de forma confiable con los otros operadores.

## Dueños por dominio

| Dominio | Dueño propuesto |
|---|---|
| Usuario | Gestión de Usuarios |
| Zona | Planificación Territorial |
| Tiempo | Analítica |
| Modo/Ruta | Operaciones |
| Estación/Parada | Infraestructura |
| Hechos de movilidad | Analítica de Movilidad |

## Linaje

Tableau -> marts Fase 2 -> Gold -> Silver -> Staging -> Bronze.

## Calidad

Registros inválidos se conservan en cuarentena con motivo.

## Seguridad

1. No se versionan secretos; `.env` está excluido.
2. Usuario seudonimizado con SHA-256 + `PSEUDONYM_SALT`.
3. Analistas usan Gold/agregados; detalle individual solo para perfiles autorizados.
4. Retención propuesta: 12 meses de detalle individual; después agregar o anonimizar salvo necesidad justificada.
