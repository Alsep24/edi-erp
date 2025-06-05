FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
WORKDIR /app/edi-frontend
RUN npm install
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/edi-frontend/dist/spa /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
