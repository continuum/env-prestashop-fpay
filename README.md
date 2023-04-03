# Ambientes Prestashop Test FPay

### * Requerimientos
<ul>
  <li>Docker</li>
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

Si se desea desplegar sin visualizar los logs por pantalla en modo detach ejecutar con el parametro -d

```bash
./run.sh start -d
```