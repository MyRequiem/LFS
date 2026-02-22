#! /bin/bash

PRGNAME="avahi"

### Avahi (service discovery aka Zeroconf)
# Система, которая облегчает обнаружение служб на машинах в локальной сети

# Required:    glib
# Recommended: gtk+3
#              libdaemon
# Optional:    python3-dbus
#              libevent
#              doxygen
#              gtk+2            (https://download.gnome.org/sources/gtk+/2.24/)
#              xmltoman         (для документации) https://sourceforge.net/projects/xmltoman/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# добавим группу avahi, если не существует
! grep -qE "^avahi:" /etc/group  && \
    groupadd -fg 84 avahi

# добавим пользователя avahi, если не существует
! grep -qE "^avahi:" /etc/passwd && \
    useradd -c "Avahi Daemon Owner" \
            -d /run/avahi-daemon    \
            -g avahi                \
            -s /bin/false           \
            -u 84 avahi

# должна существовать группа netdev
! grep -qE "^netdev:" /etc/group  && \
    groupadd -fg 86 netdev

# исправим регрессию, которая возникает по протоколу IPv6 в системе с
# несколькими сетевыми адаптерами
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-ipv6_race_condition_fix-1.patch" || exit 1

# исправим уязвимость в безопастности
sed -i '426a if (events & AVAHI_WATCH_HUP) { \
client_free(c); \
return; \
}' avahi-daemon/simple-protocol.c || exit 1

./configure                        \
    --prefix=/usr                  \
    --sysconfdir=/etc              \
    --localstatedir=/var           \
    --disable-static               \
    --enable-libevent              \
    --disable-mono                 \
    --disable-monodoc              \
    --disable-python               \
    --disable-qt3                  \
    --disable-qt4                  \
    --disable-qt5                  \
    --disable-core-docs            \
    --with-distro=none             \
    --disable-tests                \
    --with-systemdsystemunitdir=no \
    --with-dbus-system-address='unix:path=/run/dbus/system_bus_socket' || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/run"

# установим загрузочный скрипт
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-avahi DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (service discovery aka Zeroconf)
#
# The Avahi package is a system which facilitates service discovery on a local
# network
#
# Home page: https://${PRGNAME}.org/
# Download:  https://github.com/lathiat/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
