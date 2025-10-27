#!/bin/bash
# === Script de inicialización del cliente PostgreSQL ===
LOGFILE="/var/log/startup-cliente.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "==== [$(date)] Iniciando cliente PostgreSQL ===="

apt-get update -y
apt-get install -y postgresql-client

echo "Esperando a que el servidor PostgreSQL (${server_ip}) esté disponible..."

# Esperar hasta que el servidor acepte conexiones
while ! pg_isready -h "${server_ip}" -p 5432 -U usuario1 > /dev/null 2>&1; do
    echo "Servidor aún no disponible, reintentando en 5 segundos..."
    sleep 5
done

# Una vez disponible, probar conexión
echo "Servidor disponible, probando conexión..."
if PGPASSWORD="usuario" psql -h "${server_ip}" -U usuario1 -d prueba -c "\q" > /dev/null 2>&1; then
    echo "✅ Conexión exitosa al servidor PostgreSQL en ${server_ip}"
else
    echo "❌ Error al conectar con el servidor PostgreSQL en ${server_ip}"
fi

echo "==== [$(date)] Script completado ===="
