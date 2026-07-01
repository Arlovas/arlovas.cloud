FROM node:22-alpine AS builder

WORKDIR /app
RUN corepack enable

# Install all dependencies (dev + prod)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# copy the rest of the app
COPY . .

# build Next.js
RUN pnpm build


# ---------- Runner ----------
FROM node:22-alpine AS runner

WORKDIR /app
RUN corepack enable

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml

# Install only production dependencies
RUN pnpm install --prod --frozen-lockfile

EXPOSE 3000
# CMD ["pnpm", "run", "start"]
CMD ["node", "server.js"]