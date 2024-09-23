FROM node:18 AS builder
#Create a non-root user
RUN group -r dkrflow && useradd -r -g dkrflow -s /bin/false dkrflow

#Create an Application directory andd set permissions
RUN mkdir /app && chown dkrflow:dkrflow /app
RUN mkdir /home/dkrflow && chown dkrflow:dkrflow /home/dkrflow

#Update package list,install reuired package and clean up
RUN apt-get update \
    && apt-get install -y libnghttp2-14 libde265-0 \
    && apt-get clean
    
# Set the working directory    
WORKDIR /app

#Copy package and install dependencies
COPY ./package.json .
COPY ./yarn.lock .

#Either npm or yarn-- Yarn is faster so using yarn
#RUN npm install
RUN yarn install --network-timeout=300000
COPY . .

#switch to non-root user
USER dkrflow

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
