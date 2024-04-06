#!/usr/bin/env bash

set +xe

## REF: https://hub.docker.com/_/php
## REF: https://serverpilot.io/docs/how-to-install-the-php-memcache-extension/
## REF: https://serverpilot.io/docs/how-to-install-the-php-redis-extension/

## already install dependencies: gcc make autoconf libc-dev pkg-config

apt-get update
apt-get install --yes git zip zlib1g-dev libmemcached-dev

docker-php-ext-install pdo_mysql

pecl install redis memcached
docker-php-ext-enable redis memcached
