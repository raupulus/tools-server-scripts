# Tools Server Scripts

Herramientas para solucionar mis tareas repetitivas en servidores para 
proyectos que gestiono o desarrollo principalmente en web con PHP y laravel.

## Description

Esta herramienta facilita el acceso, generar proyecto, conectar a servidores,
mover assets bidireccionalmente entre servidor/local, actualizar repositorio 
remoto, actualizar db remota/local.

## Installation

Primero descargamos el proyecto desde el repositorio oficial a un directorio
dónde no lo vayamos a mover más, para posteriormente enlazarlo mediante un 
comando para el usuario.

```bash
git clone https://gitlab.com/fryntiz/tools-server-scripts.git
cd tools-server-scripts
```

Ahora copiamos el archivo .env.example al .env y editamos los valores que 
contiene estableciendo los que deseamos utilizar.

```bash
cp .env.example .env
```

Ejecutamos el script y lo instalamos para el sistema, realmente se instalará
para el usuario dentro de ${HOME}/.local/bin/tss

```bash
./main.sh
```

Una vez dentro de la herramienta, instalamos introduciendo la letra "i" y 
pulsando enter. Esto generará el enlace hacia el directorio actual 
permitiendo ejecutarlo desde cualquier lugar usando el comando **tss**.

## Usage

WIP

## Contributing

WIP

## License

GPLv3

## Project status

Desarrollo inicial. Pruebas sobre una base recién desarrollada.

## Collaborators
