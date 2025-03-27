FROM nginx:1.27
# ARG UID=1051
# ARG GID=1051

# # RUN addgroup -S null && adduser -S null -G null
# # RUN apk add -i --no-cache certbot && apk add -i --no-cache openssl
# # RUN addgroup -S vps-adminer && adduser -S vps -G vps-adminer --uid 1051

# RUN groupadd -g "${GID}" vps \
#   && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" vps
# # RUN addgroup -S vps-adminer && adduser -S vps -G vps-adminer --uid 1002

# RUN chown -R "${UID}":"${GID}" /app && chmod -R 755 /app && \
# chown -R "${UID}":"${GID}" /var/cache/nginx && \
# chown -R "${UID}":"${GID}" /var/log/nginx && \
# chown -R "${UID}":"${GID}" /etc/nginx/conf.d
# RUN touch /var/run/vps.pid && \
# chown -R "${UID}":"${GID}" /var/run/nginx.pid
# RUN chown "${UID}":"${GID}" /script/docker-entrypoint.sh

# ENTRYPOINT [ "/bin/sh", "nginx -g "daemon off;" & NGINX_PID=$!" ]

# USER vps
EXPOSE 80
EXPOSE 443
EXPOSE 27017
ENV NB_DAYS_FOR_RENEW=${NB_DAYS_FOR_RENEW:-10}
ENV TIMER_HOURS_RENEW=${TIMER_HOURS_RENEW:-24}

# USER null




# RUN addgroup -S null && adduser -S null -G null
# RUN apk add -i --no-cache certbot && apk add -i --no-cache openssl
# RUN addgroup -S vps-adminer && adduser -S vps -G vps-adminer --uid 1051
# RUN chown -R vps:vps-adminer /var/ && chown -R vps:vps-adminer /tmp/ && chown -R vps:vps-adminer /var/log/letsencrypt && chown -R vps:vps-adminer /var/log/nginx && chown -R vps:vps-adminer /etc/crontabs/
# RUN mkdir /var/www/ && mkdir /var/www/certbot
# RUN touch /etc/crontabs/vps && chmod 775 /etc/crontabs/vps
# COPY --chmod=777 ./script/ /script/
# RUN certbot certonly -v --Webroot --agree-tos --renew-by-default --preferred-challenges http-01 --email vaxelaire.yohem@gmail.com --webroot-path /var/www/certbot -d minepiece.fr
# RUN certbot --nginx -d example.com
# RUN apk add --update python3 py3-pip
# RUN certbot --nginx -m vaxelaire.yohem@gmail.com --debug-challenges --agree-tos -d  test.gites-hautes-vosges.fr
# -d DOMAIN, --domains DOMAIN, --domain DOMAIN
# RUN echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
