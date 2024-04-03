#!/usr/bin/env bash

set +xe

apt-get update
apt-get install --yes git zip
docker-php-ext-install pdo_mysql
