#!/bin/bash
set -euo pipefail

PHPVERSION="8.4"
POSTFIXADMIN_VERSION=4.0.7
POSTFIXADMIN_SHA512=07d08f631a922b313cc72db130343213a769602787751f92c01f67f69b3a72cffce958884b94a13d9f2eaf1899dcef43bfce4f11c37721897d42ab1fc9ddda2b

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
