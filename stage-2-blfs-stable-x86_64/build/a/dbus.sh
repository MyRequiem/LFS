#! /bin/bash

PRGNAME="dbus"

### D-Bus (D-Bus message bus system)
# Системный демон событий (добавление нового оборудования, изменение очереди
# печати, вход пользователя и т.д.), а так же сеансовый демон для общих
# потребностей IPC пользовательских приложений.

# Required:    no
# Recommended: xorg-libraries
# Optional:    --- для тестов ---
#              python3-dbus
#              python3-pygobject3
#              valgrind
#              --- для документации ---
#              doxygen
#              xmlto                (для сборки man-страниц)
#              python3-ducktype     (https://pypi.org/project/mallard-ducktype/)
#              yelp-tools           (http://ftp.gnome.org/pub/gnome/sources/yelp-tools/)

###
# WARNING:
# Пакет собирать в чистой LFS по двум причинам:
#   - на хосте уже запущен DBus, а при установке данного пакета в chroot среде
#     запустится еще один экземпляр, что нам не нужно
#   - для корректной генерации UUID D-Bus (/var/lib/dbus/machine-id)
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

mkdir build
cd build || exit 1

meson setup                \
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
    -D systemd=disabled    \
    .. || exit 1

ninja || exit 1

# тесты проводятся после установки пакета в систему и запуска DBus сервиса
# meson configure     \
#     -D asserts=true \
#     -D intrusive_tests=true || exit 1
#
# ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/run"
rm -rf "${TMP_DIR}/var/run"
rm -rf "${TMP_DIR}/usr/share/doc"

# создадим ссылку в /etc/
#    machine-id -> /var/lib/dbus/machine-id
ln -svf ../var/lib/dbus/machine-id "${TMP_DIR}/etc/machine-id"

###
# Конфигурация D-Bus
###
#
#    /etc/dbus-1/session.conf
#    /etc/dbus-1/system.conf
#    /etc/dbus-1/system.d/*
#
# перечисленные файлы конфигурации, вероятно, не следует изменять, и если
# изменения необходимы, нужно создать
#    /etc/dbus-1/session-local.conf
# и/или
#    /etc/dbus-1/system-local.conf
# и именно там вносить любые изменения

# некоторые пакеты устанавливают файлы *.service D-Bus не по стандартному пути
# /usr/share/dbus-1/services/, а в каталог /usr/local/share/dbus-1/services/,
# поэтому этот каталог нужно добавить в пути поиска
SESSION_LOCAL_CONF="/etc/dbus-1/session-local.conf"
cat << EOF > "${TMP_DIR}${SESSION_LOCAL_CONF}"
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>

  <!-- Search for .service files in /usr/local -->
  <servicedir>/usr/local/share/dbus-1/services</servicedir>

</busconfig>
EOF

# для автозапуска демона D-Bus при загрузке системы установим скрипт
# инициализации /etc/rc.d/init.d/dbus
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-dbus DESTDIR="${TMP_DIR}"
)

# Скрипт /etc/rc.d/init.d/dbus запускает только системный демон D-Bus. Каждый
# пользователь требующий доступа к сервисам D-Bus также должен будет запустить
# демон для своего сеанса. Для этого можно использовать несколько методов:
#
#  * запуск dbus-launch из ~/.xinitrc, например при запуске оконного менеджера
#    i3
#        exec dbus-launch /usr/bin/i3
#
#  * из файла ~/.xsession с тем же синтаксисом
#
#  * запуск сессионного демона без указания программы
#
#       # Start the D-Bus session daemon
#       eval `dbus-launch`
#       export DBUS_SESSION_BUS_ADDRESS
#
#    этот метод не остановит демон сеанса при выходе из оболочки, поэтому нам
#    нужно добавить в ~/.bash_logout
#
#       # Kill the D-Bus session daemon
#       kill $DBUS_SESSION_BUS_PID
#
#  * другие примеры для KDM с KDE
#       http://www.linuxfromscratch.org/hints/downloads/files/starting-and-stopping-dbus-with-kdm.txt

if [ -f "${SESSION_LOCAL_CONF}" ]; then
    mv "${SESSION_LOCAL_CONF}" "${SESSION_LOCAL_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SESSION_LOCAL_CONF}"

# если сначала устанавливали во временный каталог (DESTDIR), то нужно исправить
# владельца и разрешения для dbus-daemon-launch-helper
HELPER="/usr/libexec/dbus-daemon-launch-helper"
chown -v root:messagebus "${HELPER}"
chmod -v 4750            "${HELPER}"

# остановим D-Bus сервис (если запущен), и запустим заново
/etc/rc.d/init.d/dbus restart

cp -v /var/lib/dbus/machine-id "${TMP_DIR}/var/lib/dbus/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (D-Bus message bus system)
#
# D-Bus supplies both a system daemon (for events such as "new hardware device
# added" or "printer queue changed") and a per user login session daemon (for
# general IPC needs among user applications). Also, the message bus is built on
# top of a general one-to-one message passing framework, which can be used by
# any two apps to communicate directly (without going through the message bus
# daemon).
#
# Home page: https://${PRGNAME}.freedesktop.org/
# Download:  https://${PRGNAME}.freedesktop.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
