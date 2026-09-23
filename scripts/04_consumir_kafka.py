import os
import sys
import json
import hashlib
from pathlib import Path
from datetime import datetime, timezone

from confluent_kafka import Consumer


if len(sys.argv) < 2:
    raise SystemExit(
        "Uso: python scripts/04_consumir_kafka.py <topic>"
    )

topic = sys.argv[1]

consumer = Consumer({
    "bootstrap.servers": os.getenv(
        "KAFKA_BOOTSTRAP_SERVERS",
        "localhost:9092"
    ),
    "group.id": f"red-metropolitana-bronze-v2-{topic}",
    "auto.offset.reset": "earliest",
    "enable.auto.commit": False
})

consumer.subscribe([topic])

part = datetime.now().strftime("%Y-%m-%d")

out = (
    Path("data/bronze")
    / f"ingestion_date={part}"
    / f"{topic}_stream.jsonl"
)

out.parent.mkdir(parents=True, exist_ok=True)

seen_offsets = set()

if out.exists():
    for line in out.read_text(
        encoding="utf-8"
    ).splitlines():
        try:
            obj = json.loads(line)
            seen_offsets.add(obj["_kafka_position"])
        except Exception:
            pass

idle = 0
nuevos = 0

with open(out, "a", encoding="utf-8") as f:

    while idle < 10:

        msg = consumer.poll(1.0)

        if msg is None:
            idle += 1
            continue

        if msg.error():
            print(msg.error())
            continue

        idle = 0

        kafka_position = (
            f"{msg.topic()}:"
            f"{msg.partition()}:"
            f"{msg.offset()}"
        )

        if kafka_position in seen_offsets:
            consumer.commit(
                message=msg,
                asynchronous=False
            )
            continue

        payload = msg.value().decode("utf-8")

        event_uid = hashlib.sha256(
            kafka_position.encode("utf-8")
        ).hexdigest()

        record = {
            "_event_uid": event_uid,
            "_kafka_position": kafka_position,
            "_ingestion_ts":
                datetime.now(timezone.utc).isoformat(),
            "_payload": json.loads(payload)
        }

        f.write(
            json.dumps(
                record,
                ensure_ascii=False
            ) + "\n"
        )

        seen_offsets.add(kafka_position)
        nuevos += 1

        consumer.commit(
            message=msg,
            asynchronous=False
        )

consumer.close()

print(
    "NUEVOS:",
    nuevos,
    "TOTAL ARCHIVO:",
    len(seen_offsets),
    "RUTA:",
    out
)