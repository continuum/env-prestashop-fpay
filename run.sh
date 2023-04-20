#!/usr/bin/env bash
ENV_FILE=".env"
ENV_TMP_FILE=".env-tmp"
ROOT_DIR=$PWD
SEDOPTION="-i"


function create_env {
  echo "Creando archivo $ENV_FILE"
  cp -v example.env $ENV_FILE && echo "Archivo $ENV_FILE creado"
}


function _clean_version {
  issudo="sudo"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    issudo=""
  fi
  # Parametro $1 para recibir nombre de db mas version,
  # ejemplos: mariadb/1.7.8.3-7.4-5.6  mysql/1.7.3.3-7.1-5.6
  "$issudo" rm -rf ./db/"$1"
  echo "elminada carpeta $issudo /db/$1"
  # Parametro $2 para recibir ecommerce mas version,
  # ejemplos: prestashop/1.7.8.3-7.4-5.6  wordpress/7.2.4-7.1-5.6
  "$issudo" rm -rf ./"$2"
  echo "elminada carpeta $issudo  $2"

}

function _load_env {
  if [ -f .env ];then
    . .env
  fi
}

function _clean_all {
  rm -rf ./db/mariadb/*
  rm -rf ./db/mysql/*
  rm -rf ./prestashop/*
  rm -rf ./wordpress/*
}

function _valida_imagen(){
  image_version="$1"
  printf "\n"
  echo "Validando imagen $image_version ..."
  docker manifest inspect $image_version > /dev/null ; is_valid=$?
  if [ "$is_valid" = "1" ];then
    echo "❌ Imagen $image_version No encontrada en dockerhub"
    exit 1
  fi
  if [ "$is_valid" = "0" ];then
    echo "✅ Imagen $image_version encontrada en dockerhub"
  fi
}

function _show_message_valida(){
  software_name=$1
  version=$2
  default_version=$3
  if [ "$version" = "" ];then
    echo "No se indico version para $software_name, se ocupara por defecto la version 1.7.8.3"
    #Prestashop_version="1.7.8.3"
  else
    echo "Version ingresada para $software_name: $version"
  fi
  return $version
}

function _set_sed_option(){
  if [[ "$OSTYPE" == "darwin"* ]]; then
    SEDOPTION="-i \'\' "
    echo "En OSX"
  else
    echo "En linux"
  fi
}

function _sed_envs(){
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/${1}/g" .env
  else
    sed -i "s/${1}/g" .env
  fi
}

function _sed_ui(){
  _uid="$(id -u)"
  _gid="$(id -g)"
  _sed_envs "UID=.*/UID=${_uid}"
  _sed_envs "GID=.*/GID=${_gid}"
}

function build(){
  if [ -f .env ];then
    echo "Archivo .env existe"
  else
    create_env
  fi
  _load_env
  #Se definen las siguientes variables
  printf "\n"
  Wordpress_version=""
  Prestashop_version=""
  PHP_version=""
  MYSQL_version=""
  MariaDB_version=""
  exist_folders_version=false
  ecommerce_deploy="prestashop" #ecoomerce by default
  db_deploy="mariadb" #db by default
  path_ecommerce_version=""
  path_db_version=""

  while getopts "w:e:p:y:m:" arg; do
    case $arg in
      w) Wordpress_version="${OPTARG}";;
      e) Prestashop_version="${OPTARG}";;
      p) PHP_version="${OPTARG}";;
      y) MYSQL_version="${OPTARG}";;
      m) MariaDB_version="${OPTARG}";;
      *) echo "Opcion ingresada no es valida"; exit 1 ;;
    esac
  done

  if [ "$Prestashop_version" = "" ];then
    if [ "$Wordpress_version" = "" ];then
      echo "No se indico version para Prestashop, se ocupara por defecto la version $Prestashop_DEFAULT_version"
      Prestashop_version="$Prestashop_DEFAULT_version"
    else
      echo "Version ingresada para Wordpress: $Wordpress_version"
      ecommerce_deploy="wordpress"
    fi
  else
    echo "Version ingresada para Prestashop: $Prestashop_version"
  fi


  if [ "$PHP_version" = "" ];then
    echo "No se indico version para PHP, se ocupara por defecto la version $PHP_DEFAULT_version"
    PHP_version="$PHP_DEFAULT_version"
  else
    echo "Version ingresada para PHP: $PHP_version"
  fi


  if [ "$MariaDB_version" = "" ];then
    if [ "$MYSQL_version" = "" ];then
      echo "No se indico version para MariaDB, se ocupara por defecto la version $MariaDB_DEFAULT_version"
      MariaDB_version="$MariaDB_DEFAULT_version"
    else
      echo "Version ingresada para MySql: $MYSQL_version"
      db_deploy="mysql"
    fi
  else
    echo "Version ingresada para MySql: $MariaDB_version"
  fi
  printf "\n"
  echo "validando imagenes ..."

  if [ "$ecommerce_deploy" = "prestashop" ];then
    _valida_imagen "prestashop/prestashop:$Prestashop_version-$PHP_version-apache"
   _sed_envs "IMAGE_ECOMMERCE=.*/IMAGE_ECOMMERCE=${ecommerce_deploy}\/${ecommerce_deploy}:${Prestashop_version}-${PHP_version}-apache"
    
      #sed -i "s/IMAGE_ECOMMERCE=.*/IMAGE_ECOMMERCE=${ecommerce_deploy}\/${ecommerce_deploy}:${Prestashop_version}-${PHP_version}-apache/g" .env
    path_ecommerce_version="$Prestashop_version"
  else
     _valida_imagen "wordpress:${Wordpress_version}-php$PHP_version-apache"
    _sed_envs "IMAGE_ECOMMERCE=.*/IMAGE_ECOMMERCE=${ecommerce_deploy}\:${Wordpress_version}-php${PHP_version}-apache"
    path_ecommerce_version="$Wordpress_version"
  fi
  # file_el=".env\""
  # rm -f "$file_el"

#exit 0

  if [ "$db_deploy" = "mariadb" ];then
    _valida_imagen "mariadb:$MariaDB_version-focal"
    _sed_envs "IMAGE_DB=.*/IMAGE_DB=${db_deploy}\:${MariaDB_version}-focal"
    path_db_version="$MariaDB_version"
  else
    _valida_imagen "mysql:$MYSQL_version"
    _sed_envs "IMAGE_DB=.*/IMAGE_DB=${db_deploy}\:${MYSQL_version}"
    path_db_version="$MYSQL_version"
  fi

  _sed_envs "PATH_DATA_ECOMM=.*/PATH_DATA_ECOMM=${ecommerce_deploy}\/${path_ecommerce_version}-${PHP_version}-${path_db_version}\/html_data"
  _sed_envs "CONTAINER_NAME_ECOMMERCE=.*/CONTAINER_NAME_ECOMMERCE=FPAY_${ecommerce_deploy}-${path_ecommerce_version}-${PHP_version}-${path_db_version}"
  _sed_envs "PATH_DATA_DB=.*/PATH_DATA_DB=${db_deploy}\/${path_ecommerce_version}-${PHP_version}-${path_db_version}\/data"
  _sed_envs "CONTAINER_NAME_DB=.*/CONTAINER_NAME_DB=FPAY_${db_deploy}-${path_ecommerce_version}-${PHP_version}-${path_db_version}"


  if [ -d $ecommerce_deploy/$path_ecommerce_version-$PHP_version-$path_db_version ];then
    echo "❗️ $ecommerce_deploy/$path_ecommerce_version-$PHP_version-$path_db_version ya existe para esta versión"
    exist_folders_version=true
  fi

  if [ -d db/$db_deploy/$path_ecommerce_version-$PHP_version-$path_db_version ];then
    echo "❗️ Carpeta db/$db_deploy/$path_ecommerce_version-$PHP_version-$path_db_version ya existe para esta versión"
    exist_folders_version=true
  fi

  if $exist_folders_version ;then
    echo "❓ Desea eliminar datos anteriores de esta version?
   carpetas: $ecommerce_deploy/$path_ecommerce_version-$PHP_version-$path_db_version
            db/$db_deploy/$path_ecommerce_version-$PHP_version-$path_db_version"
    while true; do
      read -p "Ingresa tu respuesta si o no: " sn
      case $sn in
          [Ss]* ) _clean_version "$db_deploy/$path_ecommerce_version-$PHP_version-$path_db_version" "$ecommerce_deploy/$path_ecommerce_version-$PHP_version-$path_db_version"; break;;
          [Nn]* ) echo "Ok archivos se mantienen"; break;;
          * ) echo "Por favor responder con si o no.";;
      esac
    done
  fi

  _sed_envs "PHP_version=.*/PHP_version=${PHP_version}"
  _sed_envs "MYSQL_version=.*/MYSQL_version=${MYSQL_version}"
  _sed_envs "MariaDB_version=.*/MariaDB_version=${MariaDB_version}"
  _sed_envs "Wordpress_version=.*/Wordpress_version=${Wordpress_version}"
  _sed_envs "Prestashop_version=.*/Prestashop_version=${Prestashop_version}"

  _sed_ui

  # function build
  echo "Creando build para contendores Fpay - Prestashop"
  _sed_envs "PS_INSTALL_AUTO=.*/PS_INSTALL_AUTO=1"

  if [[ "$OSTYPE" == "darwin"* ]]; then
      docker-compose --env-file ./.env up --build --force-recreate --no-deps
  else
      docker-compose --env-file ./.env up --build --force-recreate --no-deps -d
      container_name="FPAY_${ecommerce_deploy}-${path_ecommerce_version}-${PHP_version}-${path_db_version}"
      container_data="${ecommerce_deploy}/${path_ecommerce_version}-${PHP_version}-${path_db_version}/html_data"

      while :;
        do
        if [ "$(docker inspect -f {{.State.Running}} ${container_name})" == "true" ]; then
          logs=$(docker logs ${container_name} 2>&1 | grep 'apache2 -D FOREGROUND')
          current_logs=$(docker logs ${container_name} 2>&1)
          if [ "${logs}" == "" ]; then
            printf "${current_logs} \n"
            sleep 1
          else
            printf "servicio web is running ...\n"
            break
          fi
        else
          printf "esperando que contendor inicie...\n"
          sleep 1
        fi
      done

      if [ "$ecommerce_deploy" = "prestashop" ];then
        sudo chown $(whoami):$(whoami) -R ${container_data}/modules/
      else
        sudo chown $(whoami):$(whoami) -R ${container_data}/wp-content/plugins/
      fi

      printf "Build finalizado \n"
      docker-compose logs -f
      stop
  fi
}

function _fix_permision_fpay(){
  _load_env
  printf "Validadando si carpeta $PATH_DATA_ECOMM existe\n"
  if [ -d "$PATH_DATA_ECOMM" ];then
    printf "Encontrada \n"
    ecommerce=${PATH_DATA_ECOMM:0:10}
    printf "ecoomerce encontrado: $ecommerce\n"
    if [ "$ecommerce" = "prestashop" ];then
      sudo chown $(whoami):www-data -R ${PATH_DATA_ECOMM}/modules/fpay/
      sudo chmod 777 -R ${PATH_DATA_ECOMM}//modules/fpay/src/logs/
    else
      sudo chown $(whoami):www-data -R ${container_data}/wp-content/plugins/fpay/
      sudo chmod 777 -R ${container_data}/wp-content/plugins/fpay/logs/
    fi
  fi
}


function _message_print(){
  if [ "$ecommerce_deploy" = "wordpress" ];then
    echo "
    ========================================
          🌎 Web server: http://localhost:8080
          ⚙️  Admin: http://localhost:8080/admin
    ========================================"
  else
    echo "
    ========================================
          🌎 Web server: http://localhost:8080
          ⚙️  Admin: http://localhost:8080/adminop
                user: admin@admin.com
                password: password
    ========================================"
  fi
  printf "\n"
}


function start {
  _sed_envs "PS_INSTALL_AUTO=.*/PS_INSTALL_AUTO=0"
  echo "✅ Iniciando Servicios 🚀"
  _load_env
  if [ "$Wordpress_version" = "" ] && [ "$Prestashop_version" = "" ]; then
    build
  else
    echo "Se cargan las siguientes variables"
    echo "PHP_version=${PHP_version}"
    echo "Wordpress_version=${Wordpress_version}"
    echo "Prestashop_version=${Prestashop_version}"
    echo "MYSQL_version=${MYSQL_version}"
    echo "MariaDB_version=${MariaDB_version}"
    echo "PORT_DEFAULT_WEB=${PORT_DEFAULT_WEB}"
    echo "PORT_DEFAULT_DB=${PORT_DEFAULT_DB}"

    if [ "$1" = "-d" ];then
      echo "🖇️  Mode detach  ***Para detener ejecutar comando \"run.sh stop\""
      docker-compose --env-file ./.env up -d && _message_print
    else
      docker-compose --env-file ./.env up
    fi
  fi
}


function stop {
  echo "Deteniendo Servicios ..."
  docker-compose down && \
  echo "Contenedores removidos correctamente ✅"
}

function logs {
  echo "Atachando a logs ..."
  docker-compose logs
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
