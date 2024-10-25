FROM node:20-alpine AS base

FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN  npm ci

FROM base AS builder

ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM base AS runner

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN apk add --no-cache nginx supervisor curl

WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# COPY --from=builder /app/public ./public

RUN mkdir .next
RUN chown nextjs:nodejs .next

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

RUN mkdir -p /run/nginx
RUN mkdir -p /var/cache/nginx
RUN mkdir -p /var/log/nginx
RUN chown -R nextjs:nodejs /run/nginx
RUN chown -R nextjs:nodejs /var/lib/nginx
RUN chown -R nextjs:nodejs /var/log/nginx
RUN chown -R nextjs:nodejs /var/cache/nginx

COPY nginx.conf /etc/nginx/nginx.conf
RUN chown nextjs:nodejs /etc/nginx/nginx.conf

RUN mkdir -p /var/log/supervisor
RUN chown -R nextjs:nodejs /var/log/supervisor

COPY supervisord.conf /etc/supervisord.conf

USER nextjs

EXPOSE 80

ENV PORT=3000

ENV HOSTNAME="0.0.0.0"
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
