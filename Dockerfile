FROM node:alpine AS builder
# Set the working directory    
WORKDIR /app
#Copy package and install dependencies
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install --network-timeout=300000
COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
USER nginxuser
RUN yarn build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
# Switch to the non-root user
USER nginxuser
# Expose port 80
EXPOSE 80
# Start Nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]
