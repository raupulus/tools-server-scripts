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
  local backupFile=$5
  local port=$6

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

  if [[ -z "$backupFile" ]]; then
    echo "No backup file specified"
    return 1
  fi

  if [[ -z "$host" ]]; then
    echo "No host specified"
    return 1
  fi

  if [[ ! -d '/tmp/tss/mysql' ]]; then
    mkdir -p '/tmp/tss/mysql'
  fi

  backupName="Backup-${database}-$(date +%F_%H.%M.%S)"

  echo -e "${RO}Backing up $database${CL}"

  mysqldump -h $host -P $port -u $user -p$password $database > "/tmp/tss/mysql/${backupName}" && cp "/tmp/tss/mysql/${backupName}" $backupFile
}
