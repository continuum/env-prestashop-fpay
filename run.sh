#!/usr/bin/env bash
ENV_FILE=".env"
ENV_TMP_FILE=".env-tmp"
ROOT_DIR=$PWD

function _clean_install {
  rm -rf ./db/mariadb/data
  rm -rf ./prestashop/html_data
}


function build {
  echo "Creando build para contendores Fpay - Prestashop"
  docker-compose --env-file ./.env.inst up --build --force-recreate --no-deps
}


function start {
  echo "✅ Iniciando Servicios 🚀 "
  if [ "$1" = "-d" ];then
    echo "🖇️  Mode detach  ***Para detener ejecutar comando \"run.sh stop\""
    docker-compose --env-file ./.env up -d && \
    echo "
    ========================================
          🌎 Web server: http://localhost:8080
          ⚙️ Admin: http://localhost:8080/adminop
                user: admin@admin.com
                password: password
    ========================================"
  printf "\n"
  else
    docker-compose --env-file ./.env up
  fi
}


function stop {
  echo "Deteniendo Servicios ..."
  docker-compose down && \
  echo "Contenedores removidos correctamente ✅"
}


function test {
  echo "Ejecutar Test..."
}


function help {
  printf "$0 <Options> [args]\n"
  printf "\nOptions:\n"
  compgen -A function | grep -v "^_" | cat -n
  printf "\n"
}


${@:-help}
