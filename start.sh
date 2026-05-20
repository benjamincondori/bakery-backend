#!/bin/sh
echo "Ejecutando migraciones..."
npx prisma migrate deploy
echo "Iniciando servidor..."
node dist/main