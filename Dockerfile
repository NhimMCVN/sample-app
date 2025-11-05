# --- Dockerfile ---
FROM node:20-alpine

# Tăng tương thích native deps (ví dụ sharp)
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy file lock để cache npm tối ưu
COPY package*.json ./

# Dùng npm ci nếu có package-lock, fallback npm i khi không có
RUN npm ci || npm install

# Copy source (khi chạy dev với bind mount, cái này sẽ bị đè – không sao)
COPY . .

# Các biến giúp watcher/HMR hoạt động qua volume trên Windows/macOS
ENV PORT=3000 \
    CHOKIDAR_USEPOLLING=true \
    CHOKIDAR_INTERVAL=200 \
    WATCHPACK_POLLING=true \
    WDS_SOCKET_HOST=0.0.0.0 \
    WDS_SOCKET_PORT=3000 \
    VITE_HMR_HOST=localhost

EXPOSE 3000

# Dev server (Next/Vite/CRA đều dùng npm run dev)
CMD ["npm", "run", "dev"]
