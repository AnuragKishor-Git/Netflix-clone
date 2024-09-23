#FROM node:18 AS builder
FROM node:alpine AS builder
#Create a non-root user
RUN addgroup -S dkrflow && adduser -S dkrflow -G dkrflow \  
# Set the working directory    
WORKDIR /app
#Copy package and install dependencies
COPY ./package.json .
COPY ./yarn.lock .
#Either npm or yarn-- Yarn is faster so using yarn
#RUN npm install
RUN yarn install --network-timeout=300000
COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build

FROM nginx:stable-alpine
RUN chown -R dkrflow:dkrflow /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .

# Switch to the non-root user
USER dkrflow
# Expose port 80
EXPOSE 80
# Start Nginx
#CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["nginx", "-g", "daemon off;"]
