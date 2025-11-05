# --- Dockerfile Tối ưu cho Next.js và Hot Reloading qua Volume Mount ---
FROM node:20-alpine

# Thêm libc6-compat để hỗ trợ các binary native, ví dụ như Sharp (dùng cho next/image)
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy file lock để cache npm tối ưu
COPY package*.json ./

# Dùng npm ci (tốt hơn npm install) để cài dependencies
RUN npm ci

# Copy source (cần thiết cho lần build đầu, sau đó bị đè bởi volume mount khi chạy dev)
COPY . .

# 🌟 CÁC BIẾN MÔI TRƯỜNG QUAN TRỌNG CHO HOT RELOAD (Next.js) 🌟
# 1. Bật Polling cho các thư viện file watcher Node.js (Chokidar)
ENV CHOKIDAR_USEPOLLING=true

# 2. Đặt polling interval ngắn hơn (đơn vị ms)
ENV CHOKIDAR_INTERVAL=500 

# 3. Ép Next.js/Webpack sử dụng Polling
# Đây là biến quan trọng nhất để fix lỗi Hot Reload của Next.js trong Docker.
ENV NEXT_MANUAL_POLLING=true

# 4. Định rõ host cho Dev Server (cần thiết cho một số môi trường)
# Next.js sẽ tự động sử dụng 0.0.0.0 nếu không có biến này, nhưng đặt rõ ràng an toàn hơn.
ENV HOST=0.0.0.0

EXPOSE 3000

# Dev server (dùng npm run dev)
CMD ["npm", "run", "dev"]