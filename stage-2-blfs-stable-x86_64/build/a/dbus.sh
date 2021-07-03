#! /bin/bash

PRGNAME="dbus"

### D-Bus (D-Bus message bus system)
# Системный демон событий (добавление нового оборудования, изменение очереди
# печати, вход пользователя и т.д.), а так же сеансовый демон для общих
# потребностей IPC пользовательских приложений.

# Required:    no
# Recommended: xorg-libraries
#              elogind
#              ---
#              Note:
#              Эти две зависимости кольцевые, т.е. сначала собираем без них,
#              затем пересобираем dbus после установки xorg-libraries, и затем
#              после установки elogind
#              ---
# Optional:    dbus-glib            (для тестов)
#              python-d-bus         (для тестов)
#              python-pygobject3    (для тестов)
#              valgrind
#              doxygen
#              xmlto
#              ducktype   (https://pypi.org/project/mallard-ducktype/)
#              yelp-tools (http://ftp.gnome.org/pub/gnome/sources/yelp-tools/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/"{lib,etc}

DOXYGEN="--disable-doxygen-docs"
XMLTO="--disable-xml-docs"
DUCKTYPE="--disable-ducktype-docs"

# command -v doxygen  &>/dev/null && DOXYGEN="--enable-doxygen-docs"
command -v xmlto    &>/dev/null && XMLTO="--enable-xml-docs"
# command -v ducktype &>/dev/null && DUCKTYPE="--enable-ducktype-docs"

./configure                                         \
    --prefix=/usr                                   \
    --sysconfdir=/etc                               \
    --localstatedir=/var                            \
    --enable-user-session                           \
    --disable-static                                \
    --with-systemduserunitdir=no                    \
    --with-systemdsystemunitdir=no                  \
    --with-console-auth-dir=/run/console            \
    --with-system-pid-file=/run/dbus/pid            \
    "${DOXYGEN}"                                    \
    "${XMLTO}"                                      \
    "${DUCKTYPE}"                                   \
    --disable-tests                                 \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    --with-system-socket=/run/dbus/system_bus_socket || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/var/run"

# переместим библиотеку libdbus-1.so из /usr/lib в /lib
mv -v "${TMP_DIR}/usr/lib/libdbus-1.so."* "${TMP_DIR}/lib"

# пересоздадим ссылку /usr/lib/libdbus-1.so -> /lib/libdbus-1.so.**
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libdbus-1.so)" libdbus-1.so
)

HELPER="/usr/libexec/dbus-daemon-launch-helper"
chown -v root:messagebus "${TMP_DIR}${HELPER}"
chmod -v 4750            "${TMP_DIR}${HELPER}"

# если установлен elogind создадим ссылку
#    /etc/machine-id -> /var/lib/dbus/machine-id
if command -v busctl &>/dev/null; then
    (
        cd "${TMP_DIR}/etc" || exit 1
        ln -svf ../var/lib/dbus/machine-id machine-id
    )
fi

###
# Тесты
###
# тесты dbus не могут быть запущены до тех пор, пока не будет установлен пакет
# dbus-glib, а так же должны запускаться от непривилегированного пользователя.
# Известно, что тест test-bus.sh не проходит. Также были сообщения о том, что
# тесты могут не пройти, если они выполняются внутри оболочки Midnight
# Commander. В ходе выполнения можно получать сообщения о нехватки памяти. Это
# нормально и такие сообщения могут быть безопасно проигнорированны.
# if command -v dbus-binding-tool &>/dev/null; then
#     make distclean &&
#     PYTHON=python3 ./configure  \
#         --enable-tests          \
#         --enable-asserts        \
#         --disable-doxygen-docs  \
#         --disable-ducktype-docs \
#         --disable-xml-docs || exit 1
#     make || exit 1
#     make check
# fi

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
# /usr/share/dbus-1/services, а в каталог /usr/local/share/dbus-1/services,
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

# сгенерируем D-Bus UUID, чтобы избежать предупреждений при компиляции других
# зависимых пакетов
dbus-uuidgen --ensure
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
# Home page: https://dbus.freedesktop.org/
# Download:  https://dbus.freedesktop.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
