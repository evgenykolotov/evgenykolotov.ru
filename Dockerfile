# Используем базовый образ Node.js 18.17 на Alpine Linux для сборки приложения
FROM node:18.17-alpine as builder
# Установка рабочего каталога в контейнере
WORKDIR /app
# Копирование файлов package.json и package-lock.json (если есть) в рабочую директорию
COPY package*.json ./
# Установка зависимостей
RUN npm install
# Копирование всех файлов проекта в рабочую директорию
COPY . .
# Сборка приложения
RUN npm run build

# Начало нового этапа сборки на базе того же образа Node.js
FROM node:18.17-alpine
# Установка рабочего каталога в контейнере
WORKDIR /app
# Копирование собранных файлов из предыдущего этапа
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
# Установка Nginx. Используем apk, т.к. это менеджер пакетов для Alpine
USER root
RUN apk update && apk add nginx
# Копирование конфигурационного файла Nginx в контейнер
COPY nginx.conf /etc/nginx/nginx.conf
# Объявление портов, которые будут прослушиваться при запуске контейнера
EXPOSE 80
EXPOSE 3000
# Команда для запуска Nginx и приложения Node.js
CMD ["sh", "-c", "nginx & npm start"]