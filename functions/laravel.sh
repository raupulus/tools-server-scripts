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
    git clone $LARAVEL_BASE_GIT_URL "${rutaGIT}/${nombreProyecto}"
    cd "${rutaGIT}/${nombreProyecto}"

    ## Cambiar remoto
    git remote set-url origin "${urlRepositorio}"

    ## Subir datos al nuevo remoto
    git push

    ## Almaceno el nombre del repositorio creado para crear la base de datos
    local repositoryName=$(echo $urlRepositorio | rev | cut -s -d '/' -f1 | rev | cut -s -d '.' -f1)

    ## Almaceno si existe la base de datos
    echo -e "${VE}Comprobando si existe la DB local${RO} ${repositoryName}${VE}, introduce la clave mysql:${CL}"
    checkIfExists=`mysql -u $MYSQL_USER -p --skip-column-names \
                     -e "SHOW DATABASES LIKE '${repositoryName}'"`

    ## Crear base de datos en caso de no existir
    if [[ -z $checkIfExists ]]; then
        echo -e "${VE}Creando base de datos${RO} ${repositoryName}${CL}"
        mysql -u $MYSQL_USER -p -e "CREATE DATABASE ${repositoryName}"
    fi

    local ENV_FILE="${PWD}/.env"

    if [[ ! -f "${ENV_FILE}" ]]; then
        cp "${PWD}/.env.example" "${ENV_FILE}"
    fi

    ## Edita variables de entorno del archivo .env
    strFileReplace 's/^#?[[:space:]]*APP_NAME[[:space:]]*=.*$/APP_NAME='${repositoryName}'/g' $ENV_FILE
    strFileReplace 's/^#?[[:space:]]*APP_ENV[[:space:]]*=.*$/APP_ENV=local/g' $ENV_FILE
    strFileReplace 's/^#?[[:space:]]*APP_ENV[[:space:]]*=.*$/APP_ENV=local/g' $ENV_FILE
    strFileReplace 's/^#?[[:space:]]*APP_DEBUG[[:space:]]*=.*$/APP_DEBUG=true/g' $ENV_FILE
    strFileReplace 's/^#?[[:space:]]*APP_URL[[:space:]]*=.*$/APP_URL=http://localhost:8000/g' $ENV_FILE
    strFileReplace 's/^#?[[:space:]]*DB_DATABASE[[:space:]]*=.*$/DB_DATABASE='${repositoryName}'/g' $ENV_FILE
    strFileReplace 's/^#?[[:space:]]*DB_USERNAME[[:space:]]*=.*$/DB_USERNAME='${$MYSQL_USER}'/g' $ENV_FILE
    strFileReplace 's/^#?[[:space:]]*DB_PASSWORD[[:space:]]*=.*$/DB_PASSWORD='${$MYSQL_USER}'/g' $ENV_FILE

    nano .env

    #TODO → Parametrizar la configuración por tipo de proyecto/servidor?
    composer1 install || composer install

    if [[ $LARAVEL_PHP_POST_INSTALL_COMMAND != '' ]]; then
        eval "$LARAVEL_PHP_POST_INSTALL_COMMAND"
    fi

    ## Añadir clave a servidor ssh
    ssh-copy-id -p "${puertoRemoto}" -i "${clavePublicaSsh}" \
        "${usuarioRemoto}@${servidoRemoto}"

    ## Añado el proyecto a la lista de proyectos: projects.csv
    echo "${nombreProyecto};${usuarioRemoto};${servidoRemoto};${repositoryName}" >>"${WORKSCRIPT}/projects.csv"

    ## Sube al servidor remoto el repositorio y despliega el proyecto
    read -p '¿Subir al remoto? s/N → ' input
    if [[ "$input" == 's' ]] || [[ "$input" == 'S' ]]; then

        ## TODO → Pedir datos de la db en servidor y crearla, también editar .env

        url=''
        while [[ "$url" == '' ]]; do
            read -p 'Introduce la URL de la web final → ' url
        done

        dbuser="${usuarioRemoto}_user"
        while [[ "$dbuser" == '' ]]; do
            read -p 'Introduce el usuario de la base de datos en el servidor → ' $dbuser
        done

        dbname="${usuarioRemoto}_mysql"
        while [[ "$dbname" == '' ]]; do
            read -p 'Introduce el nombre de la base de datos en el servidor → '  $dbname
        done

        dbpassword=''
        while [[ "$dbpassword" == '' ]]; do
            read -p 'Introduce la contraseña de la base de datos en el servidor → ' $dbpassword
        done

        ssh -t -p "${puertoRemoto}" -i "${clavePrivadaSsh}" \
            "${usuarioRemoto}@${servidoRemoto}" \
            'bash -s' < "${WORKSCRIPT}/scripts/laravel/deploy-on-remoty-from-git-repository.sh ${urlRepositorio} ${url} ${dbuser} ${dbpassword} ${dbname}"
    fi
}

##
## Actualiza el storage remoto subiendo los archivos locales.
##
laravelUploadStorage() {
    if [[ ! -d "${PWD}/storage" ]]; then
        echo -e "${RO}No se encuentra el directorio storage en este proyecto$CL"
        read -p "Asegúrate de estar en el directorio raíz del proyecto. (Enter para volver)"

        return
    fi

    showProjects

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#PROJECTS[@]}" ]] ||
            [[ $input -eq "${#PROJECTS[@]}" ]]; then
            echo -e "${VE}Se copiará:${RO} storage/app/ en ${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}:/home/${PROJECTS_USERS[${input}]}/laravel/storage"
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

            ## Corrige permisos para archivos subidos
            echo -e "${VE}Corrigiendo Permisos tras la subida${CL}"
            sshConnectAndExecuteCommands ${PROJECTS_SERVERS[${input}]} ${PROJECTS_USERS[${input}]} 'find  $HOME/laravel/ -type d -exec chmod 755 {} \;'

            sshConnectAndExecuteCommands ${PROJECTS_SERVERS[${input}]} ${PROJECTS_USERS[${input}]} 'find  $HOME/laravel/ -type f -exec chmod 644 {} \;'

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
