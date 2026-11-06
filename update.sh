#!/bin/bash
set -euo pipefail

PHPVERSION="8.4"
POSTFIXADMIN_VERSION=4.0.6
POSTFIXADMIN_SHA512=8ad191cbd56f8413a7442a2f6c63e559fd5bfa59424e42960350946eeafed383f7715872ac57a169fbe3269d91067d442efda45eb3e0414cdca4f7da2f4f91fb

declare -A cmd=(
	[apache]='apache2-foreground'
	[fpm]='php-fpm'
	[fpm-alpine]='php-fpm'
	[frankenphp]='frankenphp", "run", "--config", "/etc/caddy/Caddyfile'
)

declare -A base=(
	[apache]='debian'
	[fpm]='debian'
	[fpm-alpine]='alpine'
	[frankenphp]='frankenphp'
)

for variant in apache fpm fpm-alpine frankenphp; do
	dir="$variant"
	template="Dockerfile-${base[$variant]}.template"
	mkdir -p "$dir"
	cp -a "docker-entrypoint.sh" "$dir/docker-entrypoint.sh"
	sed -r \
		-e 's!%%VARIANT%%!'"$variant"'!g' \
		-e 's!%%PHPVERSION%%!'"${PHPVERSION}"'!g' \
		-e 's!%%POSTFIXADMIN_VERSION%%!'"${POSTFIXADMIN_VERSION}"'!g' \
		-e 's!%%POSTFIXADMIN_SHA512%%!'"${POSTFIXADMIN_SHA512}"'!g' \
		-e 's!%%CMD%%!'"${cmd[$variant]}"'!g' \
		"Dockerfile-${base[$variant]}.template" > "$dir/Dockerfile"
	if [ $variant != "apache" ]; then
		sed -i -e '/APACHE_DOCUMENT_ROOT/d' "$dir/Dockerfile"
	fi
	sed -i -e 's/gosu/su-exec/g' "fpm-alpine/docker-entrypoint.sh"
done
