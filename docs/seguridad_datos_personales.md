# Seguridad y manejo de datos personales

## Credenciales y secretos
No se almacenan credenciales ni valores sensibles en el repositorio. El archivo `.env` está excluido mediante `.gitignore`; solo se conserva un archivo de ejemplo sin valores reales.

## Seudonimización
La identidad del usuario se transforma con SHA-256 y una sal privada definida por `PSEUDONYM_SALT` antes de llegar a Gold. El tablero no necesita conocer la tarjeta original para reconocer recurrencia de un mismo usuario.

## Acceso por rol
- Analista BI: acceso a Gold, marts y agregados.
- Equipo de datos: acceso a Silver y Gold para mantenimiento y calidad.
- Auditor autorizado: acceso al detalle individual solo cuando exista una necesidad de auditoría o investigación.
- Usuarios generales del tablero: acceso únicamente a visualizaciones agregadas.

## Retención
Se propone conservar el detalle individual durante **12 meses**, suficiente para análisis de demanda, estacionalidad y auditoría operativa. Después debe agregarse o anonimizarse, salvo obligación legal o necesidad documentada.

## Justificación
Aunque los datos utilizados en el proyecto son generados, un sistema real de transporte contiene patrones de ubicación, horario y frecuencia asociados a individuos. Por ello se aplican minimización de acceso, seudonimización, separación por roles y retención limitada.
