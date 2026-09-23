import csv,json,time,os,sys
from confluent_kafka import Producer
if len(sys.argv)<3:
    raise SystemExit("Uso: python scripts/03_publicar_kafka.py <archivo.csv> <topic>")
p=Producer({"bootstrap.servers":os.getenv("KAFKA_BOOTSTRAP_SERVERS","localhost:9092")})
with open(sys.argv[1],encoding="utf-8-sig",newline="") as f:
    for row in csv.DictReader(f):
        p.produce(sys.argv[2],json.dumps(row,ensure_ascii=False).encode())
        p.poll(0)
p.flush()
print("PUBLICADO:",sys.argv[2])
