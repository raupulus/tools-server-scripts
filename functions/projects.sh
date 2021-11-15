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
## Funciones para las operaciones sobre los proyectos.
##

####################################
##           FUNCTIONS            ##
####################################

##
## Lee los proyectos que hay en el archivo y los almacena en las variables
## PROJECTS, PROJECTS_USERS y PROJECTS_SERVERS.
##
readProjects() {
    echo -e "${VE}Leyendo proyectos${CL}"

    PROJECTS=()
    PROJECTS_USERS=()
    PROJECTS_SERVERS=()
    PROJECTS_REPOSITORIES=()

    ## Mete en un array la lista de todos los proyectos encontrados en projects
    while read project; do
        local key=${#PROJECTS[@]}
        local name=$(echo $project | cut -s -d ';' -f1)
        local user=$(echo $project | cut -s -d ';' -f2)
        local server=$(echo $project | cut -s -d ';' -f3)
        local repositoryName=$(echo $project | cut -s -d ';' -f4)

        ## Ignoro líneas de información
        if [[ "${name}" == 'Nombre' ]] || [[ "${name}" == 'Name' ]]; then
            continue
        fi

        PROJECTS_USERS+=("$user")
        PROJECTS_SERVERS+=("$server")
        PROJECTS_REPOSITORIES+=("$repositoryName")

        ## Añado elemento al array
        PROJECTS+=("${key};${name};${user};${server};${repositoryName}")

        #echo $todo
        #echo "${todo[@]:(-1)}"  ## Muestra el último elemento
        #echo "${#todo[@]}" ## Muestra longitud del array

        #echo -e "${RO}${#PROJECTS[@]}) ${VE}${name}${AZ} (${user}@${server})${CL}"
    done <"${WORKSCRIPT}/projects.csv"

    #echo ${PROJECTS[@]}  ## Muestra listado completo como string
}

##
## Muestra el listado de proyectos por pantalla.
##
showProjects() {
    readProjects

    ## Compruebo que haya proyectos.
    if [[ ${#PROJECTS[@]} -eq 0 ]] || [[ ${#PROJECTS[@]} -eq 1 ]]; then
        echo "No projects found, add new project to projects.csv file."
        return
    fi

    ## Recorro los proyectos y los muestro por pantalla.
    for i in "${PROJECTS[@]}" ; do
        local key=$(echo $i | cut -s -d ';' -f1)
        local name=$(echo $i | cut -s -d ';' -f2)
        local user=$(echo $i | cut -s -d ';' -f3)
        local server=$(echo $i | cut -s -d ';' -f4)

        echo -e "${RO}${key}) ${VE}${name}${AZ} (${user}@${server})${CL}"
    done
}


