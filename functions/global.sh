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
## Funciones globales para todos los scripts y/o la herramienta.
##

####################################
##           FUNCTIONS            ##
####################################

##
## Instala la herramienta para el usuario actual generando un enlace simbólico
## para ejecutarlo desde cualquier directorio mediante "tss"
##
installTool() {
    ## Crear enlace en ~/.local/bin/tss
    echo -e "$RO Creando enlace de la herramienta desde ${PWD}/main.sh a ${HOME}/.local/bin/tss"

    sleep 2

    if [[ -z $TOOL_ALIAS ]]; then
        echo -e "$RO NO HAY ALIAS ESTABLECIDO EN EL ARCHIVO$AM .env$RO REVÍSALO$CL"
        return
    fi

    if [[ -L "${HOME}/.local/bin/tss" ]]; then
        rm "${HOME}/.local/bin/tss"
    fi

    ln -s "${PWD}/main.sh" "${HOME}/.local/bin/tss"
}
