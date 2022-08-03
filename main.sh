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
## Menú principal interactivo para acceder a las funcionalidades.
##

VERSION='0.1'

dir_Script=$(readlink -f $0)
WORKSCRIPT=$(dirname $dir_Script)

## Check if environment variables are set
if [[ ! -f "$WORKSCRIPT/.env" ]]; then
    echo "File .env not found, copy .env.example and set your environment"
    exit 1
fi

## Create template projects file.
if [[ ! -f "$WORKSCRIPT/projects.csv" ]]; then
  echo 'Nombre;Usuario;Servidor;' > $WORKSCRIPT/projects.csv
fi

## Create temporal folder.
if [[ ! -d "/tmp/${TOOL_ALIAS}" ]]; then
  mkdir "/tmp/${TOOL_ALIAS}"
fi

####################################
##            CONSTANT            ##
####################################
AM="\033[1;33m"  ## Color Amarillo
AZ="\033[1;34m"  ## Color Azul
BL="\033[1;37m"  ## Color Blanco
CY="\033[1;36m"  ## Color Cyan
GR="\033[0;37m"  ## Color Gris
MA="\033[1;35m"  ## Color Magenta
RO="\033[1;31m"  ## Color Rojo
VE="\033[1;32m"  ## Color Verde
CL="\e[0m"       ## Limpiar colores

####################################
##            IMPORTS             ##
####################################
source "${WORKSCRIPT}/.env"
source "${WORKSCRIPT}/functions/global.sh"
source "${WORKSCRIPT}/functions/projects.sh"
source "${WORKSCRIPT}/functions/ssh.sh"
source "${WORKSCRIPT}/functions/servers.sh"
source "${WORKSCRIPT}/functions/laravel.sh"
source "${WORKSCRIPT}/functions/mysql.sh"

####################################
##        PRECONFIGURATION        ##
####################################

## Read projects file and extract data: PROJECTS, PROJECTS_USERS, PROJECTS_SERVERS
readProjects

####################################
##           FUNCTIONS            ##
####################################
menuPrincipal() {
    while true :; do
        #clear
        echo ''

        local descripcion='Menú Principal
            1) Conectar a Servidor
            2) Actualizar repositorio master remoto
            3) Actualizar Storage desde Local a Remoto (Subir Storage)
            4) Actualizar Storage desde Remoto a Local (Descargar Storage)
            5) Backup de la Base de Datos local
            6) Backup de la Base de Datos remota (Aún no implementado)
            7) Inyectar Base de Datos Local en servidor remoto (Aún no implementado)
            8) Inyectar Base de Datos Remota en servidor local (Aún no implementado)

            a) Añadir nuevo servidor
            e) Editar servidor existente
            i) Instalar este script para todo el sistema
            k) Añadir clave SSH pública al servidor
            l) Limpiar caché de Laravel
            n) Nuevo Proyecto desde Laravel Base
            p) Publicar WEB (Aún no implementado)
            s) Crear clave ssh en tu equipo local

            0) Salir
        '
        echo -e "$AZ Versión del script →$RO $VERSION$CL"

        echo -e "$AZ Opciones Disponibles$CL"
        echo -e "$VE $descripcion$CL"

        echo -e "$RO"
        read -p '    Acción → ' entrada
        echo -e "$CL"

        case ${entrada} in

            1) sshConnect;;
            2) laravelUpdateRemoteRepository;;
            3) laravelUploadStorage;;
            4) laravelDownloadStorage;;
            5) mysqlBackupLocal;;

            a) addNewServer;;
            e) nano "${WORKSCRIPT}/projects.csv";;
            i) installTool;;
            k) sshAddKeyToRemoteServer;;
            l) laravelClearLocalCache;;
            n) nuevoProyectoLaravel;;
            s) sshCreateLocalKey;;


            0) ## SALIR
              clear
              echo -e "$RO Se sale del menú$CL"
              echo ''
              exit 0;;

            *)  ## Acción ante entrada no válida
              clear
              echo ""
              echo -e "                   $RO ATENCIÓN: Elección no válida$CL";;
        esac
    done
}

###########################
##       EJECUCIÓN       ##
###########################
menuPrincipal
