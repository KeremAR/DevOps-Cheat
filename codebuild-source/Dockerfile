FROM alpine
RUN apk update && apk add apache2
EXPOSE 80
RUN echo "cmtr-zdv1y551" > /var/www/localhost/htdocs/index.html
CMD ["httpd", "-D", "FOREGROUND"] 