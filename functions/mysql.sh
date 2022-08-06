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
## Funciones para las operaciones sobre MySQL.
##

####################################
##           FUNCTIONS            ##
####################################


mysqlBackup() {
  local host=$1
  local user=$2
  local password=$3
  local database=$4
  local port=$5

  if [[ -z "$port" ]]; then
    port=3306
  fi

  if [[ -z "$user" ]]; then
    user=root
  fi

  if [[ -z "$password" ]]; then
    password=
  fi

  if [[ -z "$database" ]]; then
    echo "No database specified"
    return 1
  fi

  if [[ -z "$host" ]]; then
    echo "No host specified"
    return 1
  fi

  if [[ ! -d "/tmp/${TOOL_ALIAS}/mysql" ]]; then
    mkdir -p "/tmp/${TOOL_ALIAS}/mysql"
  fi

  backupName="Backup-${database}-$(date +%F_%H.%M.%S)"

  echo -e "${RO}Backing up${RO} ${database}${CL}"

  mysqldump -h $host -P $port -u $user -p$password $database > "/tmp/${TOOL_ALIAS}/mysql/${backupName}" && cp "/tmp/${TOOL_ALIAS}/mysql/${backupName}" "${PATH_BACKUPS}/$backupName"
}

mysqlBackupLocal() {
    showProjects

    while true :; do
        read -p 'Introduce proyecto para crear el backup → ' input

        if [[ $input -lt "${#PROJECTS[@]}" ]] ||
           [[ $input -eq "${#PROJECTS[@]}" ]]; then

            database=${PROJECTS_USERS[$input]}

            checkIfExists=`mysql -u $MYSQL_USER -p --skip-column-names \
             -e "SHOW DATABASES LIKE '${database}'"`

            if [[ -z "${PROJECTS[$input]}" ]] || [[ -z $checkIfExists ]]; then
                echo -e "${VE}No existe la base de datos${RO} ${PROJECTS_USERS[${input}]}${CL}"
                continue
            fi

            echo -e "${VE}Se generará un backup de la DB ${PROJECTS_USERS[${input}]}"
            echo ''
            echo -e "${RO}¿Seguro que quieres continuar?${CL}"
            read -p '  s/N → ' SN

            ## Realizo el backup con los datos
            if [[ $SN == 's' ]] || [[ $SN == 'S' ]]; then
                mysqlBackup 'localhost' $MYSQL_USER '' $database
            fi

            echo -e "${VE}Proceso de Backup concluido, pulsa intro para continuar${CL}"
            read in

            break
        fi
    done
}
