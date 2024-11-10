# Use an official Nginx image as the base image
FROM nginx:alpine


COPY ./html /usr/share/nginx/html


EXPOSE 80


CMD ["nginx", "-g", "daemon off;"]