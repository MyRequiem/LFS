#! /bin/bash

PRGNAME="network-configuration"
LFS_VERSION="12.4"

### Network Configuration (network configuration files)

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

# Именование сетевых устройств
# ----------------------------
# Udev по умолчанию называет сетевые устройства в соответствии с данными
# прошивки/BIOS или физическими характеристиками, такими как шина, слот или
# MAC-адрес. Цель этого соглашения о присвоении имен состоит в том, чтобы
# гарантировать, что сетевые устройства именуются последовательно и не основаны
# на времени их обнаружения. Например, на компьютере с двумя сетевыми картами
# Intel и Realtek, сетевая карта Intel может стать eth0, а карта Realtek -
# eth1. В некоторых случаях после перезагрузки карты будут именоваться
# наоборот.
#
# В новой схеме именования типичные имена сетевых устройств будут выглядеть
# примерно так: enp5s0 или wlp3s0. Если такие имена нежелательны, то можно
# реализовать традиционную схему именования (eth0, eth1, wlan0, wlan1 и т.д.)
# путем передачи ядру параметра 'net.ifnames=0'. Это наиболее подходит для тех
# систем, которые имеют только одно сетевое устройство. Ноутбуки обычно имеют
# по одному интерфейсу Ethernet и WiFi, поэтому для них так же будет удобна
# традиционная схема: eth0 и wlan0

# Создание файлов конфигурации сетевого интерфейса
# -------------------------------------------------
# Какие интерфейсы запускаются и отключаются сетевыми скриптами, обычно зависит
# от файлов в /etc/sysconfig/ Этот каталог должен содержать файл для каждого
# настраиваемого интерфейса вида ifconfig.<interface_name>, где
# <interface_name> - имя интерфейса (eth0, eth1, wlan0 и т.д). Эти файлы
# содержат атрибуты интерфейса, такие как IP-адрес, маску подсети и т.д.

### Создадим конфиг для устройства eth0 со статическим IP-адресом
# ONBOOT    - интерфейс будет подниматься при загрузке системы, если значение
#               переменной == yes. Для отмены поднятия интерфейса при загрузке,
#               устанавливаем пустое значение. Интерфейс можно
#               запусть/отключить вручную с помощью команд ifup и ifdown
# IFACE     - определяет имя интерфейса. Эта переменная требуется для всех
#               файлов конфигурации сетевых устройств. Расширение имени файла
#               должно соответствовать этому значению
# SERVICE   - определяет метод, используемый для получения IP-адреса. Каждый
#               метод описан скриптом с названием метода в каталоге
#               /lib/services/
# GATEWAY   - должен содержать IP-адрес шлюза по умолчанию. Если шлюза нет, то
#               нужно закомментировать эту переменную
# PREFIX    - содержит количество битов, используемых в подсети. Если маска
#               подсети 255.255.255.0, то используются первые три октета
#               (24 бита). Если Маска подсети 255.255.255.240, она будет
#               использовать первые 28 бит. Приставки более чем 24 бита обычно
#               используются DSL провайдерами. Если переменная не указана, то
#               ее значение по умолчанию равно 24

IFCONFIG_ETH0="/etc/sysconfig/ifconfig.eth0"
cat << EOF > "${IFCONFIG_ETH0}"
# Begin ${IFCONFIG_ETH0}

ONBOOT=yes
IFACE=eth0

# The SERVICE variable defines the method used for obtaining the IP address.
# The LFS-Bootscripts package has a modular IP assignment format, and creating
# additional files in the /lib/services/ directory allows other IP assignment
# methods
SERVICE=ipv4-static

IP=192.168.1.7
PREFIX=24

# GATEWAY=
# BROADCAST=

# End ${IFCONFIG_ETH0}
EOF

### Создадим файл /etc/resolv.conf
# Системе понадобятся некоторые средства для преобразования доменных имен в
# IP-адреса и наоборот. Это достигается путем размещения IP-адреса DNS-сервера,
# доступного от интернет-провайдера или сетевого администратора в файле
# /etc/resolv.conf

RESOLV_CONF="/etc/resolv.conf"
cat << EOF > "${RESOLV_CONF}"
# Begin ${RESOLV_CONF}

# router
# nameserver 192.168.1.1

# Google Public IPv4 DNS addresses
# nameserver 8.8.8.8
# nameserver 8.8.4.4

# DNS from internet provider (login.beeline.ru)
# nameserver 83.102.180.175

# End ${RESOLV_CONF}
EOF

### Конфигурация имени хоста
# В процессе загрузки файл /etc/hostname используется для установки имени хоста
echo "lfs" > /etc/hostname

### Настройка файла /etc/hosts
HOSTS="/etc/hosts"
cat << EOF > "${HOSTS}"
# Begin ${HOSTS}

# IP-address        Fully Qualified Domain Name     Alias
# ----------        ---------------------------     -----
::1                 ip6-localhost                   ip6-loopback
127.0.0.1           localhost.lfs                   localhost
127.0.0.1           lfs.myrequiem.net               lfs

# End ${HOSTS}
EOF

# пишем список файлов в /var/log/packages/network-configuration-${VERSION}
cat << EOF > "/var/log/packages/${PRGNAME}-${LFS_VERSION}"
# Package: ${PRGNAME} (network configuration files)
#
#    /etc/hostname
#    /etc/hosts
#    /etc/resolv.conf
#    /etc/sysconfig/ifconfig.eth0
#
/etc/hostname
/etc/hosts
/etc/resolv.conf
/etc/sysconfig/ifconfig.eth0
EOF
