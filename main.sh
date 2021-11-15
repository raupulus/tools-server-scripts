#!/usr/bin/env bash

VERSION='0.1'

dir_Script=$(readlink -f $0)
WORKSCRIPT=$(dirname $dir_Script)

## Check if environment variables are set
if [[ ! -f "$WORKSCRIPT/.env" ]]; then
    echo "File .env not found, copy .env.example and set your environment"
    exit 1
fi

if [[ ! -f "$WORKSCRIPT/projects.csv" ]]; then
  echo 'Nombre;Usuario;Servidor;' >> $WORKSCRIPT/projects.csv
fi




############################
##       CONSTANTES       ##
############################
AM="\033[1;33m"  ## Color Amarillo
AZ="\033[1;34m"  ## Color Azul
BL="\033[1;37m"  ## Color Blanco
CY="\033[1;36m"  ## Color Cyan
GR="\033[0;37m"  ## Color Gris
MA="\033[1;35m"  ## Color Magenta
RO="\033[1;31m"  ## Color Rojo
VE="\033[1;32m"  ## Color Verde
CL="\e[0m"       ## Limpiar colores

############################
##     IMPORTACIONES      ##
############################
source "${WORKSCRIPT}/.env"
source "${WORKSCRIPT}/functions/global.sh"
source "${WORKSCRIPT}/functions/servers.sh"
source "${WORKSCRIPT}/functions/laravel.sh"

############################
##       FUNCIONES        ##
############################
menuPrincipal() {
    while true :; do
        clear

        local descripcion='Menú Principal
            1) Conectar a Servidor
            2) Actualizar Storage desde Local a Remoto (Subir Storage)
            3) Actualizar Storage desde Remoto a Local (Descargar Storage)
            4) Añadir clave SSH pública al servidor
            5) Actualizar repositorio master remoto
            6) Publicar WEB (Aún no implementado)
            7) Backup de la Base de Datos local (Aún no implementado)
            8) Backup de la Base de Datos remota (Aún no implementado)
            9) Inyectar Base de Datos Local en servidor remoto (Aún no implementado)
            10) Inyectar Base de Datos Remota en servidor local (Aún no implementado)

            a) Añadir nuevo servidor
            e) Editar servidor existente
            s) Crear clave ssh en tu equipo local
            l) Limpiar caché de Laravel
            n) Nuevo Proyecto desde Laravel Base
            i) Instalar este script para todo el sistema

            0) Salir
        '
        echo -e "$AZ Versión del script →$RO $VERSION$CL"

        echo -e "$AZ Opciones Disponibles$CL"
        echo -e "$VE $descripcion$CL"

        echo -e "$RO"
        read -p '    Acción → ' entrada
        echo -e "$CL"

        case ${entrada} in

            1) conectarServidor;;
            2) actualizarStorageRemoto;;
            3) actualizarStorageLocal;;
            4) agregarClaveSshServidor;;
            5) actualizarMasterRemoto;;

            #a) nano "${WORKSCRIPT}/projects.csv";;
            a) agregarServidor;;
            e) nano "${WORKSCRIPT}/projects.csv";;
            s) crearClaveSsh;;
            l) limpiarCacheLaravel;;
            n) nuevoProyectoLaravel;;
            i) crearLinks;;


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
