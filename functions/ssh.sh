#!/usr/bin/env bash

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
    #sshpass -p "$password" ssh -p $port -o StrictHostKeyChecking=no $user@$host "$script"
}

sshConnectAndExecuteCommands() {
    local host=$1
    local commands=$2
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

    if [[ -z "$commands" ]]; then
        echo "No commands specified"
        return 1
    fi

    if [[ -z "$host" ]]; then
        echo "No host specified"
        return 1
    fi

    echo "Connecting to $host"
    #sshpass -p "$password" ssh -p $port -o StrictHostKeyChecking=no $user@$host "$commands"
}
