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
## Script para las operaciones sobre laravel.
##

####################################
##           FUNCTIONS            ##
####################################


nuevoProyectoLaravel() {
    read -p "Introduce el nombre del proyecto → " nombreProyecto
    read -p "Introduce el repositorio remoto → " urlRepositorio
    read -p "Introduce el usuario ssh remoto → " usuarioRemoto
    read -p "Introduce el servidor ssh remoto → " servidoRemoto

    echo -e "${AZ}Has introducido los siguientes datos:$CL"
    echo -e "${VE}Nombre del proyecto:${RO} $nombreProyecto$CL"
    echo -e "${VE}URL repositorio Remoto:${RO} $urlRepositorio$CL"
    #echo -e "${VE}Usuario servidor ssh:${RO} $usuarioRemoto$CL"
    #echo -e "${VE}URL o IP servidor ssh:${RO} $servidoRemoto$CL"

    echo -e "${RO}¿Continuar?$CL"
    read -p "s/N  → " input

    if [[ "$input" != 's' ]] && [[ "$input" != 'S' ]]; then
        exit 0
    fi

    ## Clonar laravel-base
    git clone LARAVEL_BASE_GIT_URL "${rutaGIT}/${nombreProyecto}"
    cd "${rutaGIT}/${nombreProyecto}"

    ## Cambiar remoto
    git remote set-url origin "${urlRepositorio}"

    ## Subir datos al nuevo remoto
    git push

    ## Editar .env local
    cp .env.example .env
    nano .env

    #TOFIX → Parametrizar la configuración por tipo de proyecto/servidor
    composer1 install || composer install

    if [[ $LARAVEL_PHP_POST_INSTALL_COMMAND != '' ]]; then
        eval "$LARAVEL_PHP_POST_INSTALL_COMMAND"
    fi

    ## Añadir clave a servidor ssh
    ssh-copy-id -p "${puertoRemoto}" -i "${clavePublicaSsh}" \
        "${usuarioRemoto}@${servidoRemoto}"

    ## TODO → Conectar al remoto, desplegar y configurar
    read -p '¿Subir al remoto? s/N → ' input
    if [[ "$input" == 's' ]] || [[ "$input" == 'S' ]]; then
        echo 'no implementada esta parte'
    fi

    ## Añado el proyecto a la lista de proyectos: projects.csv
    echo "${nombreProyecto};${nombreProyecto};${servidoRemoto};" >>"${WORKSCRIPT}/projects.csv"
}

##
## Actualiza el storage remoto subiendo los archivos locales.
##
laravelUploadStorage() {
    if [[ ! -d "${PWD}/storage" ]]; then
        echo -e "${RO}No se encuentra el directorio storage en este proyecto$CL"
    fi

    showProjects

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#PROJECTS[@]}" ]] ||
            [[ $input -eq "${#PROJECTS[@]}" ]]; then
            echo -e "${VE}Se copiará:${RO} storage/app/ en ${PROJECTS_USERS[${input} - 1]}@${PROJECTS_SERVERS[${input}]}:/home/${PROJECTS_USERS[${input}]}/laravel/storage"
            echo ''
            echo -e "${RO}¿Seguro que quieres continuar?"
            read -p '  s/N → ' SN

            if [[ $SN == 's' ]] || [[ $SN == 'S' ]]; then
                if [[ -f "$clavePrivadaSsh" ]]; then
                    echo "clave ${clavePrivadaSsh}"
                    scp -P "$puertoRemoto" \
                        -i $clavePrivadaSsh \
                        -r 'storage/app/' "${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}:/home/${PROJECTS_USERS[${input}]}/laravel/storage"
                else
                    scp -P "$puertoRemoto" \
                        -r 'storage/app/' "${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}:/home/${PROJECTS_USERS[${input}]}/laravel/storage"
                fi
            fi

            echo -e "${VE}Se ha terminado de copiar, pulsa intro para continuar${CL}"
            read in

            break
        fi
    done
}

##
## Actualiza el storage local a partir del remoto elegido.
##
laravelDownloadStorage() {
    if [[ ! -d "${PWD}/storage" ]]; then
        echo -e "${RO}No se encuentra el directorio storage en este proyecto$CL"
    fi

    showProjects

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#PROJECTS[@]}" ]] ||
            [[ $input -eq "${#PROJECTS[@]}" ]]; then
            echo -e "${VE}Se copiará:${RO} ${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}:/home/${PROJECTS_USERS[${input}]}/laravel/storage en storage/app/"
            echo ''
            echo -e "${RO}¿Seguro que quieres continuar?"
            read -p '  s/N → ' SN

            if [[ $SN == 's' ]] || [[ $SN == 'S' ]]; then
                if [[ -f "$clavePrivadaSsh" ]]; then
                    echo "clave ${clavePrivadaSsh}"
                    scp -P "$puertoRemoto" \
                        -i $clavePrivadaSsh \
                        -r "${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}:/home/${PROJECTS_USERS[${input}]}/laravel/storage/app" 'storage'
                else
                    scp -P "$puertoRemoto" \
                        -r "${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}:/home/${PROJECTS_USERS[${input}]}/laravel/storage/app" 'storage'
                fi
            fi

            echo -e "${VE}Se ha terminado de copiar, pulsa intro para continuar${CL}"
            read in

            break
        fi
    done
}

##
## Limpia el caché local de Laravel
##
laravelClearLocalCache() {
    echo -e "$RO Limpiando cache de Laravel$CL"

    bash "${WORKSCRIPT}/scripts/laravel/clear-cache.sh"

    echo ""
    echo -e "${VE}Se ha terminado de limpiar, pulsa intro para continuar${CL}"

    read in
}

##
## Actualiza el repositorio remoto en un servidor.
##
laravelUpdateRemoteRepository() {
    showProjects

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#PROJECTS[@]}" ]] ||
            [[ $input -eq "${#PROJECTS[@]}" ]]; then
            echo -e "${VE}Se ejecutará:${RO}
ssh -p ${puertoRemoto} -i ${clavePublicaSsh} ${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}
git pull &&
php artisan clear &&
php artisan cache:clear &&
php artisan config:clear &&
php artisan route:clear;
composer1 dump-autoload || composer dump-autoload"
            echo ''
            echo -e "${RO}¿Seguro que quieres continuar?${CL}"
            read -p '  s/N → ' SN

            if [[ $SN == 's' ]] || [[ $SN == 'S' ]]; then
                if [[ -f "$clavePrivadaSsh" ]]; then
                    echo "clave ${clavePrivadaSsh}"

                    ssh -t -p "${puertoRemoto}" -i "${clavePrivadaSsh}" \
                        ${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]} \
                        "cd laravel; git pull
                      php artisan clear && \
                      php artisan cache:clear && \
                      php artisan config:clear && \
                      php artisan route:clear && \
                      composer1 dump-autoload || composer dump-autoload"

                else

                    ssh -t -p "${puertoRemoto}" \
                        ${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]} \
                        "cd laravel; git pull
                      php artisan clear && \
                      php artisan cache:clear && \
                      php artisan config:clear && \
                      php artisan route:clear; \
                      composer1 dump-autoload || composer dump-autoload"
                fi
            fi

            echo -e "${VE}Se ha terminado de ejecutar, pulsa intro para continuar${CL}"
            read in

            break
        fi
    done

}
