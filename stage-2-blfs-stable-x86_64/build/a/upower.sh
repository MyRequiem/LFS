#! /bin/bash

PRGNAME="upower"

### UPower (power management abstraction daemon)
# Интерфейс для предоставления списка устройств питания, прослушивание событий
# этих устройств, запросов истории и статистики. Любое приложение или служба в
# системе может получить доступ к службе org.freedesktop.UPower через системную
# шину сообщений. Некоторые операции (например приостановка системы) ограничены
# использованием PolicyKit.

# Required:    libgudev
#              libusb
# Recommended: no
# Optional:    glib
#              gtk-doc
#              libxslt
#              docbook-xsl
#              python3-pygobject3
#              python3-dbusmock
#              umockdev             (для тестов)
#              libimobiledevice     (https://libimobiledevice.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d v -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-v${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-v${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим ненужную зависимость из теста:
sed '/parse_version/d' -i src/linux/integration-test.py || exit 1

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix=/usr             \
    --buildtype=release       \
    -D gtk-doc=false          \
    -D man=true               \
    -Dsystemdsystemunitdir=no \
    -Dudevrulesdir=/usr/lib/udev/rules.d || exit 1

ninja || exit 1

# тестовый набор должен запускаться из локальной GUI сессии, запущенной с
# dbus-launch
# LC_ALL=C ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (power management abstraction daemon)
#
# UPower is an abstraction for enumerating power devices, listening to device
# events and querying history and statistics. Any application or service on the
# system can access the org.freedesktop.UPower service via the system message
# bus. Some operations (such as suspending the system) are restricted using
# PolicyKit.
#
# Home page: https://${PRGNAME}.freedesktop.org/
# Download:  https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/-/archive/v${VERSION}/${PRGNAME}-v${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
