#! /bin/bash

PRGNAME="network-configuration"

### Network Configuration (network configuration files)

# http://www.linuxfromscratch.org/lfs/view/stable/chapter07/network.html

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

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
# настраиваемого интерфейса вида ifconfig.xyz, где "xyz" - имя интерфейса
# (eth0, eth1, wlan0 и т.д). Эти файлы содержат атрибуты интерфейса, такие как
# IP-адрес, маску подсети и т.д.

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

# бэкапим конфиг /etc/sysconfig/ifconfig.eth0 перед его созданием, если он
# существует
IFCONFIG_ETH0="/etc/sysconfig/ifconfig.eth0"
if [ -f "${IFCONFIG_ETH0}" ]; then
    mv "${IFCONFIG_ETH0}" "${IFCONFIG_ETH0}.old"
fi

cat << EOF > "${IFCONFIG_ETH0}"
# Begin ${IFCONFIG_ETH0}

ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.7
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255

# End ${IFCONFIG_ETH0}
EOF

config_file_processing "${IFCONFIG_ETH0}"

### Создадим файл /etc/resolv.conf
# Системе понадобятся некоторые средства для преобразования доменных имен в
# IP-адреса и наоборот. Это достигается путем размещения IP-адреса DNS-сервера,
# доступного от интернет-провайдера или сетевого администратора в файле
# /etc/resolv.conf

# бэкапим /etc/resolv.conf перед его созданием, если он существует
RESOLV_CONF="/etc/resolv.conf"
if [ -f "${RESOLV_CONF}" ]; then
    mv "${RESOLV_CONF}" "${RESOLV_CONF}.old"
fi

cat << EOF > "${RESOLV_CONF}"
# Begin ${RESOLV_CONF}

# Google Public IPv4 DNS addresses
nameserver 8.8.8.8
nameserver 8.8.4.4

# End ${RESOLV_CONF}
EOF

config_file_processing "${RESOLV_CONF}"

### Конфигурация имени хоста
# В процессе загрузки файл /etc/hostname используется для установки имени хоста

# бэкапим /etc/hostname перед его созданием, если он существует
HOST_NAME="/etc/hostname"
if [ -f "${HOST_NAME}" ]; then
    mv "${HOST_NAME}" "${HOST_NAME}.old"
fi

echo "lfs" > "${HOST_NAME}"

config_file_processing "${HOST_NAME}"

### Настройка файла /etc/hosts
# бэкапим /etc/hosts перед его созданием, если он существует
HOSTS="/etc/hosts"
if [ -f "${HOSTS}" ]; then
    mv "${HOSTS}" "${HOSTS}.old"
fi

cat << EOF > "${HOSTS}"
# Begin ${HOSTS}

# IP-address        Full domain name            Alias
# ----------        ----------------            -----
127.0.0.1           localhost
127.0.0.1           lfs.myrequiem.net           lfs

# End ${HOSTS}
EOF

config_file_processing "${HOSTS}"

# пишем список файлов в /var/log/packages/network-configuration
cat << EOF > "/var/log/packages/${PRGNAME}"
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
