ARG NODE_VERSION=22

FROM node:${NODE_VERSION} AS builder
WORKDIR /opt/app
COPY package*.json ./

RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN npm run build

FROM gcr.io/distroless/nodejs22-debian13:nonroot AS runner

USER nonroot
WORKDIR /opt/app

COPY --from=builder --chown=nonroot:nonroot /opt/app/.next/standalone/ ./
COPY --from=builder --chown=nonroot:nonroot /opt/app/.next/static ./.next/static
COPY --from=builder --chown=nonroot:nonroot /opt/app/public ./public

ENV NODE_ENV=production

EXPOSE 3000

CMD ["server.js"]
