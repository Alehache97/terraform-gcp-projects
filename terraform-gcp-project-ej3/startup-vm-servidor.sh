#!/bin/bash
LOGFILE="/var/log/startup-servidor.log"
exec > >(tee -a $LOGFILE) 2>&1
set -e

echo "Configurando PostgreSQL..."

apt-get update -y
apt-get install -y postgresql postgresql-contrib

sudo -u postgres psql -c "CREATE USER usuario1 WITH PASSWORD 'usuario';"
sudo -u postgres psql -c "CREATE DATABASE prueba OWNER usuario1;"

PG_CONF="/etc/postgresql/15/main/postgresql.conf"
PG_HBA="/etc/postgresql/15/main/pg_hba.conf"

# Escuchar en todas las IP
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF

# Permitir acceso desde la subred privada
echo "host    all             all             10.0.2.0/24            md5" >> $PG_HBA

systemctl restart postgresql
echo "PostgreSQL listo y escuchando en todas las interfaces."
