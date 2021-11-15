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
## Funciones para las operaciones sobre servidores.
##

####################################
##           FUNCTIONS            ##
####################################


##
## Añade un nuevo proyecto al archivo projects.csv de forma interactiva.
##
addNewServer() {
    read -p "Introduce el usuario ssh remoto → " usuarioRemoto
    read -p "Introduce el servidor ssh remoto → " servidoRemoto
    read -p "Introduce el nombre del proyecto → " nombreProyecto

    echo -e "${AZ}Has introducido lo  s siguientes datos:$CL"
    echo -e "${VE}Nombre del proyecto:${RO} $nombreProyecto$CL"
    echo -e "${VE}Usuario servidor ssh:${RO} $usuarioRemoto$CL"
    echo -e "${VE}URL o IP servidor ssh:${RO} $servidoRemoto$CL"

    echo -e "${RO}¿Continuar?$CL"
    read -p "s/N  → " input

    if [[ "$input" != 's' ]] && [[ "$input" != 'S' ]]; then
        exit 0
    fi

    ## Añado el proyecto a la lista de proyectos: projects.csv
    echo "${nombreProyecto};${usuarioRemoto};${servidoRemoto};" >>"${WORKSCRIPT}/projects.csv"
}
