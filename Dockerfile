# --- Etapa 1: Compilar ---
FROM node:20-alpine AS builder
WORKDIR /app

# Instalar OpenSSL para Prisma
RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
RUN npm run build

# Verificar que el build generó el dist
RUN ls -la dist/

# --- Etapa 2: Producción ---
FROM node:20-alpine
WORKDIR /app

# Instalar OpenSSL para Prisma
RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm install --omit=dev

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY prisma ./prisma
COPY start.sh .
RUN chmod +x start.sh

# Verificar que dist existe antes de arrancar
RUN ls -la dist/

EXPOSE 3000
CMD ["sh", "start.sh"]