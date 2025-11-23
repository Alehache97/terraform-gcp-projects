#!/bin/bash
LOGFILE="/var/log/startup-servidor.log"
exec > >(tee -a "$LOGFILE") 2>&1
set -e

echo "==== [$(date)] Configurando PostgreSQL en Debian 13 ===="

# Actualizar e instalar PostgreSQL
apt-get update -y
apt-get install -y postgresql postgresql-contrib

# Detectar versión instalada de PostgreSQL
PG_VERSION=$(ls /etc/postgresql | head -n1)
echo "Versión de PostgreSQL detectada: $PG_VERSION"

# Rutas de configuración
PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
PG_HBA="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"

# Crear usuario y base de datos
sudo -u postgres psql -c "CREATE USER usuario1 WITH PASSWORD 'usuario';"
sudo -u postgres psql -c "CREATE DATABASE prueba;"

# Configurar PostgreSQL para escuchar en todas las IPs
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Permitir acceso desde la subred privada
echo "host    all             all             10.0.2.0/24            md5" >> "$PG_HBA"

# Reiniciar PostgreSQL para aplicar cambios
systemctl restart postgresql

echo "PostgreSQL listo y escuchando en todas las interfaces."

# Crear tablas DEPT y EMP con datos
echo "==== Creando tablas DEPT y EMP en la base 'prueba' ===="
sudo -u postgres psql -d prueba << 'EOF'
CREATE TABLE dept (
    deptno INTEGER PRIMARY KEY,
    dname VARCHAR(14),
    loc   VARCHAR(13)
);

CREATE TABLE emp (
    empno   INTEGER PRIMARY KEY,
    ename   VARCHAR(10),
    job     VARCHAR(9),
    mgr     INTEGER,
    hiredate DATE,
    sal     NUMERIC(7,2),
    comm    NUMERIC(7,2),
    deptno  INTEGER REFERENCES dept(deptno)
);

-- Inserts: DEPT
INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept VALUES (20, 'RESEARCH', 'DALLAS');
INSERT INTO dept VALUES (30, 'SALES', 'CHICAGO');
INSERT INTO dept VALUES (40, 'OPERATIONS', 'BOSTON');

-- Inserts: EMP
INSERT INTO emp VALUES(7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800, NULL, 20);
INSERT INTO emp VALUES(7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600, 300, 30);
INSERT INTO emp VALUES(7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 30);
INSERT INTO emp VALUES(7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975, NULL, 20);
INSERT INTO emp VALUES(7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250, 1400, 30);
INSERT INTO emp VALUES(7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850, NULL, 30);
INSERT INTO emp VALUES(7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450, NULL, 10);
INSERT INTO emp VALUES(7788, 'SCOTT', 'ANALYST', 7566, '1982-12-09', 3000, NULL, 20);
INSERT INTO emp VALUES(7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10);
INSERT INTO emp VALUES(7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500, 0, 30);
INSERT INTO emp VALUES(7876, 'ADAMS', 'CLERK', 7788, '1983-01-12', 1100, NULL, 20);
INSERT INTO emp VALUES(7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950, NULL, 30);
INSERT INTO emp VALUES(7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000, NULL, 20);
INSERT INTO emp VALUES(7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300, NULL, 10);

-- Conceder todos los privilegios a usuario1 sobre el esquema public y sus tablas
GRANT USAGE, CREATE ON SCHEMA public TO usuario1;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO usuario1;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO usuario1;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO usuario1;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO usuario1;
EOF

echo "Tablas DEPT y EMP creadas y usuario1 con todos los permisos."
echo "==== [$(date)] Script completado ===="
