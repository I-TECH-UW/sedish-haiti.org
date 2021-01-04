FROM nginx:stable 
 
COPY ./data/nginx.conf /etc/nginx/nginx.conf 
 
RUN useradd -u 1001 www 
 
RUN touch /var/run/nginx.pid && \ 
  chown -R www:www /var/run/nginx.pid && \ 
  chown -R www:www /var/cache/nginx 

USER www