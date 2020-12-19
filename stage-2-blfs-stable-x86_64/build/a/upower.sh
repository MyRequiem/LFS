#! /bin/bash

PRGNAME="upower"

### UPower (power management abstraction daemon)
# Интерфейс для предоставления списка устройств питания, прослушивание событий
# этих устройств, запросов истории и статистики. Любое приложение или служба в
# системе может получить доступ к службе org.freedesktop.UPower через системную
# шину сообщений. Некоторые операции (например приостановка системы) ограничены
# использованием PolicyKit.

# Required:    dbus-glib
#              libgudev
#              libusb
#              polkit
# Recommended: no
# Optional:    gobject-introspection
#              gtk-doc
#              python-pygobject3
#              python3-dbusmock
#              umockdev (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
# command -v gtkdoc-check  &>/dev/null && GTK_DOC="--enable-gtk-doc"

# включим устаревший функционал, который все еще требуется некоторым
# приложениям
#    --enable-deprecated
./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --enable-deprecated  \
    "${GTK_DOC}"         \
    --disable-static || exit 1

make || exit 1

# тестовый набор должен запускаться из локальной GUI сессии с запущенным
# dbus-launch
#
# make check

make install DESTDIR="${TMP_DIR}"

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
# Home page: http://upower.freedesktop.org/
# Download:  https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/uploads/93cfe7c8d66ed486001c4f3f55399b7a/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
