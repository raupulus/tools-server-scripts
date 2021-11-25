#!/usr/bin/env bash
# -*- ENCODING: UTF-8 -*-

## @author     Raúl Caro Pastorino
## @email      raul@fryntiz.dev
## @web        https://fryntiz.es
## @gitlab     https://gitlab.com/fryntiz
## @github     https://github.com/fryntiz
## @twitter    https://twitter.com/fryntiz
## @telegram   https://t.me/fryntiz

## @bash        5.1 or later
## Create Date: 2021
## Project Repository: https://gitlab.com/fryntiz/tools-server-scripts

##             Applied Style Guide:
## @style      https://gitlab.com/fryntiz/bash-guide-style

## Revision 0.01 - File Created
## Additional Comments:

## @license    https://wwww.gnu.org/licenses/gpl.txt
## @copyright  Copyright © 2021 Raúl Caro Pastorino
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>

####################################
##          INSTRUCTIONS          ##
####################################
##
## Script para desplegar en servidor remoto un proyecto de laravel.
##
## Recibe los siguientes parámetros:
${urlRepositorio} ${url} ${dbuser} ${dbpassword} ${dbname}
## $1 = URL del repositorio
## $2 = URL de la web
## $3 = Usuario de la base de datos
## $4 = Contraseña de la base de datos
## $5 = Nombre de la base de datos

####################################
##           FUNCTIONS            ##
####################################

if [[ -z "$1" ]]; then
    echo "No se ha especificado url del repositorio git"
    exit 1
fi

urlRepositorio="$1"

if [[ -z "$2" ]]; then
    echo "No se ha especificado url del proyecto"
    exit 1
fi

url="$2"

if [[ -z "$3" ]]; then
    echo "No se ha especificado el nombre de usuario"
    exit 1
fi

dbuser="$3"

if [[ -z "$4" ]]; then
    echo "No se ha especificado la contraseña de la DB"
    exit 1
fi

dbpassword="$4"

if [[ -z "$5" ]]; then
    echo "No se ha especificado el nombre de la DB"
    exit 1
fi

dbname="$5"

git clone "$url_git" "$HOME/laravel"
cd "$HOME/laravel"
cp "$HOME/laravel/.env.example.production" "$HOME/laravel/.env"

## TODO → Aplicar configuración de .env

nano "$HOME/laravel/.env"

## TODO →

php artisan key:generate
composer install --no-dev

## TODO → gitconfig --global ....

if [[ ! -d "$HOME/laravel/public/storage" ]]; then
    php artisan storage:link
fi

if [[ ! -d "${HOME}/${REMOTE_PATH_DEV}" ]]; then
    ln -s "${HOME}/${REMOTE_PATH_DEV}"
fi
