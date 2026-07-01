FROM node:22-alpine AS builder

WORKDIR /app

# Install all dependencies (dev + prod)
COPY package.json package-lock.json ./
RUN npm ci

# copy the rest of the app
COPY . .

# build Next.js
RUN npm run build


# ---------- Runner ----------
FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json

# Install only production dependencies
RUN npm ci --omit=dev

EXPOSE 3000
CMD ["node", "server.js"]
