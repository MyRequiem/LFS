#! /bin/bash

PRGNAME="upower"

### UPower (power management abstraction daemon)
# Важная системная служба, которая неустанно следит за уровнем заряда батареи и
# состоянием электропитания. Она сообщает системе, когда нужно переходить в
# режим экономии или предупредить пользователя о разрядке.

# Required:    libgudev
#              libusb
# Recommended: no
# Optional:    glib
#              gtk-doc
#              libxslt                  (для создания man-страниц)
#              docbook-xsl              (для создания man-страниц)
#              python3-pygobject3
#              python3-dbusmock
#              umockdev                 (для тестов)
#              libimobiledevice         (https://libimobiledevice.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d v -f 2)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# если оба опциональных пакета libxslt и docbook-xsl не установлены, делаем
# -D man=false
meson setup ..                 \
    --prefix=/usr              \
    --buildtype=release        \
    -D gtk-doc=false           \
    -D man=true                \
    -D systemdsystemunitdir=no \
    -D udevrulesdir=/usr/lib/udev/rules.d || exit 1

ninja || exit 1

# тестовый набор должен запускаться в графической среде, запущенной с
# dbus-launch
# LC_ALL=C ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
