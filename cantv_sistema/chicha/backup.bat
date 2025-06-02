@echo off

REM Ruta de destino del archivo de backup
set "backup_dir=C:\Program Files\PostgreSQL\15\bin"

REM Nombre del archivo de backup
set "backup_file=%backup_dir%\backup.sql"

REM Realizar el backup de la base de datos
pg_dump -U postgres -d sistema_canTv -f "%backup_file%"

REM Guardar el nuevo índice
echo %index% > backup_index.txt
