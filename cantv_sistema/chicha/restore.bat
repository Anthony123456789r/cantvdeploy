@echo off

REM Ruta del archivo de backup a restablecer
set "backup_file=C:\Program Files\PostgreSQL\15\bin\backup.sql"

REM Restablecer el backup en la base de datos utilizando psql
psql -h localhost -p 5432 -U postgres -f "%backup_file%" sistema_canTv
