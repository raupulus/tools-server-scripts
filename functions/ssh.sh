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
## Funciones para las operaciones sobre ssh.
##

####################################
##           FUNCTIONS            ##
####################################


##
## Crea una clave privada SSH en el equipo local.
##
sshCreateLocalKey() {
    if [[ ! -f "${clavePrivadaSsh}" ]]; then
        echo -e "$RO Creando clave ssh en ${clavePrivadaSsh}${CL}"

        ## Crear clave SSH con cifrado ecdsa fuerte.
        ssh-keygen -f "${clavePrivadaSsh}" -t ecdsa -b 521

        ## Añadir clave al ssh-agent para conectar de forma transparente.
        ssh-add "${clavePrivadaSsh}"
    else
        echo -e "$RO Ya existe la clave ssh, elimínala para regenerarla${CL}"
        sleep 10
    fi
}

##
## Establece la conexión por SSH a un servidor remoto para el proyecto
## seleccionado.
##
sshConnect() {
    showProjects

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#PROJECTS[@]}" ]] ||
            [[ $input -eq "${#PROJECTS[@]}" ]]; then
            echo -e "${VE}Accediendo con el usuario:${RO} ${PROJECTS_USERS[${input}]}$CL"
            echo -e "${VE}Servidor:${RO} ${PROJECTS_SERVERS[${input}]}$CL"
            sleep 2
            if [[ -f "$clavePrivadaSsh" ]]; then
                ssh -i "$clavePrivadaSsh" \
                    ${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]} \
                    -p $puertoRemoto
            else
                ssh ${PROJECTS_USERS[${input} - 1]}@${PROJECTS_SERVERS[${input}]} -p $puertoRemoto
            fi
            break
        fi
    done
}

##
## Añade una clave pública de ssh al servidor de forma interactiva.
##
sshAddKeyToRemoteServer() {
    showProjects

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#PROJECTS[@]}" ]] ||
            [[ $input -eq "${#PROJECTS[@]}" ]]; then
            echo -e "${AM}Añadiendo clave ssh al servidor$CL"
            echo -e "${VE}Accediendo con el usuario:${RO} ${PROJECTS_USERS[${input}]}$CL"
            echo -e "${VE}Servidor:${RO} ${PROJECTS_SERVERS[${input}]}$CL"
            sleep 2
            if [[ -f "$clavePublicaSsh" ]]; then
                ssh-copy-id -p 51514 -i "$clavePublicaSsh" \
                    ${PROJECTS_USERS[${input}]}@${PROJECTS_SERVERS[${input}]}
            else
                echo -e "${AM}No existe la clave pública ${clavePublicaSsh}$CL"
            fi

            echo -e "$VE Pulsa cualquier tecla para continuar${CL}"

            read in
            break
        fi
    done
}

sshConnectAndExecuteScript() {
    local host=$1
    local script=$2
    local user=$3
    local password=$4
    local port=$5

    if [[ -z "$port" ]]; then
        port=22
    fi

    if [[ -z "$user" ]]; then
        user=root
    fi

    if [[ -z "$password" ]]; then
        password=
    fi

    if [[ -z "$script" ]]; then
        echo "No script specified"
        return 1
    fi

    if [[ -z "$host" ]]; then
        echo "No host specified"
        return 1
    fi

    echo "Connecting to $host"
    #ssh root@MachineB 'bash -s' < local_script.sh
    #sshpass -p "$password" ssh -p $port -o StrictHostKeyChecking=no $user@$host "$script"
}

##
## Envía uno o más comandos para ser ejecutados en el servidor.
##
## $1 Nombre o ip del servidor a conectar.
## $2 Nombre del usuario a conectar.
## $3 El comando o los comandos a ejecutar en el servidor, debe ser una cadena.
##
sshConnectAndExecuteCommands() {
    local host=$1
    local user=$2
    local commands=$3

    if [[ -z "$host" ]]; then
        echo "No host specified"

        return 1
    fi

    if [[ -z "$user" ]]; then
        echo "No user specified"

        return 1
    fi

    if [[ -z "$commands" ]]; then
        echo "No command specified"

        return 1
    fi

    echo "Connecting to $host"

    if [[ -f "$clavePrivadaSsh" ]]; then
        ssh -i "$clavePrivadaSsh" \
            -p $puertoRemoto \
            ${user}@${host} \
            "${commands}"
    else
        ssh -p $puertoRemoto ${user}@${host} "${commands}"
    fi
}
