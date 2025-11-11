#! /bin/bash

PRGNAME="libnotify"

### libnotify (notification library)
# Библиотека libnotify используется для отправки уведомлений рабочего стола на
# демон уведомлений (notification-daemon), в соответствии со спецификацией. Эти
# уведомления могут использоваться для информирования пользователя о событии
# или отображения некоторой информации, не мешая пользователю.

# Required:    gtk+3
#              --- runtime ---
#              notification-daemon или xfce4-notifyd или lxqt-notificationd
# Recommended: no
# Optional:    glib
#              python3-gi-docgen
#              xmlto

### NOTE:
# GNOME Shell и KDE KWin предоставляют свои собственные демоны уведомлений

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                  \
    --prefix=/usr            \
    --buildtype=release      \
    -D gtk_doc=false         \
    -D man=false             \
    -D tests=false           \
    -D docbook_docs=disabled \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (notification library)
#
# The libnotify general library is used to send desktop notifications to a
# notification daemon, as defined in the Desktop Notifications spec. These
# notifications can be used to inform the user about an event or display some
# form of information without getting in the users way.
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
