###########
# Backend #
###########

# Dev env base container
FROM phpdockerio/php80-fpm:latest AS backend-dev
WORKDIR "/application"

# Pre-deployment container. The deployed container needs some files generated by yarn
FROM backend-dev AS backend-deployment

ENV APP_ENV=prod
ENV SYMFONY_ENV=prod
ENV APP_SECRET=""

ENV GOOGLE_ANALYTICS=""

COPY bin/console /application/bin/
COPY composer.*  /application/

RUN composer install --no-dev --no-scripts; \
    composer clear-cache

COPY infrastructure/php-fpm/php-ini-overrides.ini  /etc/php/8.0/fpm/conf.d/z-overrides.ini
COPY infrastructure/php-fpm/opcache-prod.ini       /etc/php/8.0/fpm/conf.d/z-opcache.ini
COPY infrastructure/php-fpm/php-fpm-pool-prod.conf /etc/php/8.0/fpm/pool.d/z-optimised.conf

COPY config           ./config
COPY src              ./src
COPY templates        ./templates
COPY public/index.php ./public/

RUN composer dump-autoload --optimize --classmap-authoritative --no-scripts; \
    bin/console cache:warmup; \
    chown www-data:www-data var/ -Rf

############
# Frontend #
############
# Run bower install before we can install bundle's assets
FROM node:alpine AS bower-installer

COPY bower.json .
COPY .bowerrc .

RUN apk add git --no-cache; \
    npm i -g bower; \
    bower install --allow-root

## Actual deployable frontend image
FROM pagespeed/nginx-pagespeed:stable AS frontend-deployment

WORKDIR /application

RUN mkdir ./web; \
    touch ./web/app.php

COPY infrastructure/nginx/pagespeed.conf /etc/nginx/pagespeed.conf
COPY infrastructure/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# NGINX config: update php-fpm hostname to localhost (same pod in k8s), activate pagespeed config, deactivate SSL
RUN sed -i "s/php-fpm/localhost/g"       /etc/nginx/conf.d/default.conf; \
    sed -i "s/# %DEPLOYMENT //g"         /etc/nginx/conf.d/default.conf; \
    sed -i "s/listen 443/#listen 443/g"  /etc/nginx/conf.d/default.conf; \
    sed -i "s/ssl_/#ssl_/g"              /etc/nginx/conf.d/default.conf

COPY --from=bower-installer public/vendor public/vendor

COPY public/css public/css
COPY public/js  public/js
