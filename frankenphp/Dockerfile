FROM dunglas/frankenphp:1-php8.4

LABEL maintainer="David Goodwin <david@codepoets.co.uk> (@DavidGoodwin)"

ARG POSTFIXADMIN_VERSION=4.0.6
ARG POSTFIXADMIN_SHA512=8ad191cbd56f8413a7442a2f6c63e559fd5bfa59424e42960350946eeafed383f7715872ac57a169fbe3269d91067d442efda45eb3e0414cdca4f7da2f4f91fb

ENV POSTFIXADMIN_VERSION="${POSTFIXADMIN_VERSION}" \
    POSTFIXADMIN_SHA512="${POSTFIXADMIN_SHA512}" \
    COMPOSER_ALLOW_SUPERUSER=1 \
    SERVER_NAME=:80 \
    SERVER_ROOT=/var/www/html/public

WORKDIR /var/www/html

#
# Runtime dependencies used by docker-entrypoint.sh.
#
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    gosu \
    ; \
    rm -rf /var/lib/apt/lists/*

#
# PHP extensions required by PostfixAdmin.
#
# install-php-extensions automatically installs and removes the necessary
# system build dependencies.
#
RUN install-php-extensions \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pgsql \
    gd \
    ;

RUN printf '%s\n' \
    'output_buffering = 4096' \
    'session.use_strict_mode = 1' \
    'expose_php = Off' \
    > /usr/local/etc/php/conf.d/postfixadmin.ini

#
# Download PostfixAdmin.
#
RUN set -eux; \
    curl -fsSL \
    -o /tmp/postfixadmin.tar.gz \
    "https://github.com/postfixadmin/postfixadmin/archive/v${POSTFIXADMIN_VERSION}.tar.gz"; \
    \
    echo "${POSTFIXADMIN_SHA512} */tmp/postfixadmin.tar.gz" \
    | sha512sum -c -; \
    \
    mkdir -p /var/www/html; \
    tar \
    -xf /tmp/postfixadmin.tar.gz \
    -C /var/www/html \
    --strip-components=1; \
    rm /tmp/postfixadmin.tar.gz; \
    \
    mkdir -p /var/www/html/templates_c; \
    chown -R www-data:www-data /var/www/html

#
# Install Composer dependencies.
#
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    unzip \
    ; \
    \
    export COMPOSER_HOME="$(mktemp -d)"; \
    composer install \
    --ignore-platform-req=ext-mysqli \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --working-dir=/var/www/html; \
    rm -rf "${COMPOSER_HOME}"; \
    \
    apt-get purge -y --auto-remove \
    -o APT::AutoRemove::RecommendsImportant=false \
    unzip; \
    rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
