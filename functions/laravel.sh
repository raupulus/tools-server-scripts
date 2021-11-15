#!/usr/bin/env bash

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
    git clone LARAVEL_BASE_GIT_URL "${rutaGIT}/${nombreProyecto}"
    cd "${rutaGIT}/${nombreProyecto}"

    ## Cambiar remoto
    git remote set-url origin "${urlRepositorio}"

    ## Subir datos al nuevo remoto
    git push

    ## Editar .env local
    cp .env.example .env
    nano .env

    #TOFIX → Parametrizar a configuración por tipo de proyecto/servidor
    composer1 install || composer install

    if [[ $LARAVEL_PHP_POST_INSTALL_COMMAND != '' ]]; then
        eval "$LARAVEL_PHP_POST_INSTALL_COMMAND"
    fi

    ## Añadir clave a servidor ssh
    ssh-copy-id -p "${puertoRemoto}" -i "${clavePublicaSsh}" \
                "${usuarioRemoto}@${servidoRemoto}"

    ## TODO → Conectar al remoto, desplegar y configurar
    read -p '¿Subir al remoto? s/N → ' input
    if [[ "$input" = 's' ]] || [[ "$input" = 'S' ]]; then
        echo 'no implementada esta parte'
    fi

    ## Añado el proyecto a la lista de proyectos: projects.csv
    echo "${nombreProyecto};${nombreProyecto};${servidoRemoto};" >> "${WORKSCRIPT}/projects.csv"
}

conectarServidor() {
    todo=()
    usuarios=()
    servidores=()

    ## Meter en un array lista de todos los proyectos encontrados en projects
    while read project; do
        nombre=$(echo $project | cut -s -d ';' -f1)
        usuario=$(echo $project | cut -s -d ';' -f2)
        servidor=$(echo $project | cut -s -d ';' -f3)

        if [[ "$nombre" = 'Nombre' ]]; then
            continue
        fi

        usuarios+=("$usuario")
        servidores+=("$servidor")

        todo+=("$project")  ## Añado elemento al array
        #echo ${todo[@]}  ## Muestra todo

        echo -e "${RO}${#todo[@]}) ${VE}${nombre}${AZ} (${usuario}@${servidor})${CL}"
    done < "${WORKSCRIPT}/projects.csv"

    #echo $todo
    #echo "${todo[@]:(-1)}"  ## Muestra el último elemento
    #echo "${#todo[@]}" ## Muestra longitud del array

    ## foreach a $todo y crear un menú con while

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#todo[@]}" ]] ||
           [[ $input -eq "${#todo[@]}" ]]; then
            echo -e "${VE}Accediendo con el usuario:${RO} ${usuarios[${input}-1]}$CL"
            echo -e "${VE}Servidor:${RO} ${servidores[${input}-1]}$CL"
            sleep 2
            if [[ -f "$clavePrivadaSsh" ]]; then
                ssh -i "$clavePrivadaSsh" \
                        ${usuarios[${input}-1]}@${servidores[${input}-1]} \
                        -p 51514
            else
                ssh ${usuarios[${input}-1]}@${servidores[${input}-1]} -p 51514
            fi
            break
        fi
    done
}

## Añade la clave pública de ssh al servidor.
agregarClaveSshServidor() {
    todo=()
    usuarios=()
    servidores=()

    ## Meter en un array lista de todos los proyectos encontrados en projects
    while read project; do
        nombre=$(echo $project | cut -s -d ';' -f1)
        usuario=$(echo $project | cut -s -d ';' -f2)
        servidor=$(echo $project | cut -s -d ';' -f3)

        if [[ "$nombre" = 'Nombre' ]]; then
            continue
        fi

        usuarios+=("$usuario")
        servidores+=("$servidor")

        todo+=("$project")  ## Añado elemento al array

        echo -e "${RO}${#todo[@]}) ${VE}${nombre}${AZ} (${usuario}@${servidor})${CL}"
    done < "${WORKSCRIPT}/projects.csv"

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#todo[@]}" ]] ||
           [[ $input -eq "${#todo[@]}" ]]; then
              echo -e "${AM}Añadiendo clave ssh al servidor$CL"
              echo -e "${VE}Accediendo con el usuario:${RO} ${usuarios[${input}-1]}$CL"
              echo -e "${VE}Servidor:${RO} ${servidores[${input}-1]}$CL"
              sleep 2
              if [[ -f "$clavePublicaSsh" ]]; then
                   ssh-copy-id -i "$clavePublicaSsh" \
                        ${usuarios[${input}-1]}@${servidores[${input}-1]} \
                        -p 51514
            else
                echo -e "${AM}Añadiendo clave ssh al servidor$CL"
            fi
            break
        fi
    done
}

actualizarStorageRemoto() {
    if [[ ! -d "${PWD}/storage" ]]; then
        echo -e "${RO}No se encuentra el directorio storage en este proyecto$CL"
    fi

    todo=()
    usuarios=()
    servidores=()

    ## Meter en un array lista de todos los proyectos encontrados en projects
    while read project; do
        nombre=$(echo $project | cut -s -d ';' -f1)
        usuario=$(echo $project | cut -s -d ';' -f2)
        servidor=$(echo $project | cut -s -d ';' -f3)

        if [[ "$nombre" = 'Nombre' ]]; then
            continue
        fi

        usuarios+=("$usuario")
        servidores+=("$servidor")

        todo+=("$project")  ## Añado elemento al array
        #echo ${todo[@]}  ## Muestra todo

        echo -e "${RO}${#todo[@]}) ${VE}${nombre}${AZ} (${usuario}@${servidor})${CL}"
    done < "${WORKSCRIPT}/projects.csv"

    #echo $todo
    #echo "${todo[@]:(-1)}"  ## Muestra el último elemento
    #echo "${#todo[@]}" ## Muestra longitud del array

    ## foreach a $todo y crear un menú con while

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#todo[@]}" ]] ||
           [[ $input -eq "${#todo[@]}" ]]; then
            echo -e "${VE}Se copiará:${RO} storage/app/ en ${usuarios[${input}-1]}@${servidores[${input}-1]}:/home/${usuarios[${input}-1]}/laravel/storage"
            echo ''
            echo -e "${RO}¿Seguro que quieres continuar?"
            read -p '  s/N → ' SN

            if [[ $SN = 's' ]] || [[ $SN = 'S' ]]; then
                if [[ -f "$clavePrivadaSsh" ]]; then
                    echo "clave ${clavePrivadaSsh}"
                    scp -P "$puertoRemoto" \
                        -i $clavePrivadaSsh \
                        -r 'storage/app/' "${usuarios[${input}-1]}@${servidores[${input}-1]}:/home/${usuarios[${input}-1]}/laravel/storage"
                else
                    scp -P "$puertoRemoto" \
                        -r 'storage/app/' "${usuarios[${input}-1]}@${servidores[${input}-1]}:/home/${usuarios[${input}-1]}/laravel/storage"
                fi
            fi

            echo -e "${VE}Se ha terminado de copiar, pulsa intro para continuar${CL}"
            read in

            break
        fi
    done
}


##
## Actualiza el storage local a partir del remoto elegido.
##
actualizarStorageLocal() {
    if [[ ! -d "${PWD}/storage" ]]; then
        echo -e "${RO}No se encuentra el directorio storage en este proyecto$CL"
    fi

    todo=()
    usuarios=()
    servidores=()

    ## Meter en un array lista de todos los proyectos encontrados en projects
    while read project; do
        nombre=$(echo $project | cut -s -d ';' -f1)
        usuario=$(echo $project | cut -s -d ';' -f2)
        servidor=$(echo $project | cut -s -d ';' -f3)

        if [[ "$nombre" = 'Nombre' ]]; then
            continue
        fi

        usuarios+=("$usuario")
        servidores+=("$servidor")

        todo+=("$project")  ## Añado elemento al array
        #echo ${todo[@]}  ## Muestra todo

        echo -e "${RO}${#todo[@]}) ${VE}${nombre}${AZ} (${usuario}@${servidor})${CL}"
    done < "${WORKSCRIPT}/projects.csv"

    #echo $todo
    #echo "${todo[@]:(-1)}"  ## Muestra el último elemento
    #echo "${#todo[@]}" ## Muestra longitud del array

    ## foreach a $todo y crear un menú con while

    while true :; do
        read -p 'Introduce el servidor a conectar → ' input

        if [[ $input -lt "${#todo[@]}" ]] ||
           [[ $input -eq "${#todo[@]}" ]]; then
            echo -e "${VE}Se copiará:${RO} ${usuarios[${input}-1]}@${servidores[${input}-1]}:/home/${usuarios[${input}-1]}/laravel/storage en storage/app/"
            echo ''
            echo -e "${RO}¿Seguro que quieres continuar?"
            read -p '  s/N → ' SN

            if [[ $SN = 's' ]] || [[ $SN = 'S' ]]; then
                if [[ -f "$clavePrivadaSsh" ]]; then
                    echo "clave ${clavePrivadaSsh}"
                    scp -P "$puertoRemoto" \
                        -i $clavePrivadaSsh \
                        -r "${usuarios[${input}-1]}@${servidores[${input}-1]}:/home/${usuarios[${input}-1]}/laravel/storage/app" 'storage'
                else
                    scp -P "$puertoRemoto" \
                        -r "${usuarios[${input}-1]}@${servidores[${input}-1]}:/home/${usuarios[${input}-1]}/laravel/storage/app" 'storage'
                fi
            fi

            echo -e "${VE}Se ha terminado de copiar, pulsa intro para continuar${CL}"
            read in

            break
        fi
    done
}

crearClaveSsh() {
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

crearLinks() {
    ## Crear enlace en ~/.local/bin/tss
    echo -e "$RO Creando enlace de la herramienta desde ${PWD}/main.sh a ${HOME}/.local/bin/tss"

    sleep 2

    if [[ -h "${HOME}/.local/bin/tss" ]]; then
        rm "${HOME}/.local/bin/tss"
    fi

    ln -s "${PWD}/main.sh" "${HOME}/.local/bin/tss"
}

agregarServidor() {
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
  echo "${nombreProyecto};${usuarioRemoto};${servidoRemoto};" >> "${WORKSCRIPT}/projects.csv"
}

limpiarCacheLaravel() {
    php artisan clear-compiled
    php artisan cache:clear
    php artisan config:clear
    php artisan debugbar:clear
    php artisan ide-helper:generate
    php artisan ide-helper:meta
    php artisan ide-helper:models
    php artisan optimize:clear
    php artisan package:discover
    php artisan queue:flush
    php artisan route:clear
    php artisan view:clear

    composer dump-autoload
}

actualizarMasterRemoto() {
    ssh-copy-id -p "${puertoRemoto}" -i "${clavePublicaSsh}" \
                    "${usuarioRemoto}@${servidoRemoto}" git pull && \
                    php artsan clear && \
                    php artisan cache:clear && \
                    php artisan config:clear && \
                    php artisan route:clear && \
                    composer1 dump-autoload || composer dump-autoload
}
