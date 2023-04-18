# Ambientes Prestashop y Wordpress Test FPay

### * Requerimientos
<ul>
  <li>Docker y cuenta valida en https://hub.docker.com</li>
  <li>docker-compose</li>
  <li>git</li>
</ul>


### Instalación rápida

```bash
git clone git@github.com:continuum/env-prestashop-fpay.git && cd env-prestashop-fpay && ./run.sh build
```

### Instalacion paso a paso
#### Clonar/Descargar repositorio

Debe clonar repositorio de github de la siguiente forma:
```bash
git clone git@github.com:continuum/env-prestashop-fpay.git
```
una vez descargado entrar en la carpeta del proyecto:
```bash
cd env-prestashop-fpay
```

#### Build
Para crear un ambiente con la configuración por defecto se debe ejecutar el siguiente comando en la terminal

```bash
./run.sh build
```

### Ejemplo de Build con parámetros
Para poder parametrizar el build con distintas veriones de PHP Prestashop y MySql se pueden agregar los siguientes flags:
<ul>
  <li>-p para versión de PHP ejemplo 7.4 </li>
  <li>-e para versión de Prestashop ejemplo 1.7.8.3 </li>
  <li>-m para versión de MariaDb  ejemplo 10.7.8 </li>
  <li>-y para versión de Mysql ejemplo 5.6 </li>
  <li>-w para versión de Wordpress ejemplo 1.7.8.3 </li>


</ul>

```bash
./run.sh build -p 7.3 -e 1.7.8.3 -y 5.6 #EXAMPLE PRESTASHOP
./run.sh build -p 7.4 -w 6.1 -m 10.7.3 #EXAMPLE WORDPRESS
```
#### Start

```bash
./run.sh start
```

Si desea desplegar sin visualizar los logs por pantalla en modo detach ejecutar con el parametro -d

```bash
./run.sh start -d
```

Si inicio con modo detach y necesita ver logs de los contendores ejecute lo siguiente

```bash
./run.sh logs
```

#### Stop
Para detener los contenedores desplegados ejecute el siguiente comando:

```bash
./run.sh stop
```

###  Valores por defecto
##### Versiones por defecto
La configuración por defecto del ecommerce y db se encuentran en el archivo ```.env```. Para crear este archivo ejecute:

```bash
./run.sh create_env
```

En este archivo encontrara las variables donde puede especificar las versiones por defecto que desea desplegar, los valores por defecto son:
```
#Default version
PHP_DEFAULT_version=7.4
Prestashop_DEFAULT_version=1.7.8.3
MariaDB_DEFAULT_version=10.7.8
```
##### Puertos por defecto

En  el archivo ```.env``` tambien encontrara las variables donde puede especificar los puertos por defecto que desea desplegar tanto de base de datos como de servidor web, los valores por defecto son:
```
PORT_DEFAULT_WEB=8080
PORT_DEFAULT_DB=3306
```

#### Eliminar datos
Para eliminar toda la data de los contenedores creados puede ejecutar el siguiente comando:

```bash
./run.sh _clean_all
```

######*** En ambientes linux como Ubuntu puede requerir permisos de super usuario o root (sudo) para eliminar estas carpetas.

######*** Ocupar con precaución, no es posible recuperar data una vez eliminada.