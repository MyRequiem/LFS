#! /bin/bash

PRGNAME="glib"

### GLib (library of C routines)
# Библиотеки низкого уровня, которые включают подпрограммы поддержки C, такие
# как списки, деревья, хэши, распределение памяти и многое другое.

# Required:    no
# Recommended: libxslt
#              pcre
# Optional:    dbus   (для некоторых тестов)
#              bindfs (для некоторых тестов) https://bindfs.org/
#              gdb
#              docbook-xml
#              docbook-xsl
#              gtk-doc (для сборки API документации, см. конфигурацию ниже)
#              glib-networking
#              gobject-introspection
#              shared-mime-info   (для тестов)
#              desktop-file-utils (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{"${DOCS}",/etc/profile.d}

# Во многих случаях приложения, которые используют эту библиотеку, прямо или
# косвенно через другие библиотеки, такие как GTK+-3, выводят многочисленные
# предупреждения при запуске из командной строки. Применение следующего патча
# позволяет использовать переменную среды GLIB_LOG_LEVEL, которая подавляет
# нежелательные сообщения.
#    1 - Alert
#    2 - Critical
#    3 - Error
#    4 - Warning
#    5 - Notice
# Например, не выводить сообщения Warning и Notice
#    export GLIB_LOG_LEVEL=4
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-skip_warnings-1.patch" || exit 1

mkdir build
cd build || exit 1

# если установлен пакет gtk-doc, то можно собрать и установить API документацию
GTK_DOC="-Dgtk_doc=false"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="-Dgtk_doc=true"

# устанавливать man-страницы
#    -Dman=true
# отключить поддержку selinux
#    -Dselinux=disabled
meson                  \
    --prefix=/usr      \
    -Dman=true         \
    -Dselinux=disabled \
    "${GTK_DOC}"       \
    .. || exit 1

ninja || exit 1
# в конце сборки в консоль могут выводится ошибки типа:
#    Error: no ID for constraint linkend: ...
# Такие ошибки допустимы и безвредны.

DESTDIR=${TMP_DIR} ninja install

# документация
cp -vR ../docs/reference/{gio,glib,gobject} "${TMP_DIR}${DOCS}"

# для запуска тестов требуются 2 установленных пакета:
#    shared-mime-info
#    desktop-file-utils
#
# ninja test

# устанавливаем переменные среды GLIB_LOG_LEVEL (см. выше), G_FILENAME_ENCODING
# и G_BROKEN_FILENAMES в /etc/profile.d/glib.sh

GLIB_SH="/etc/profile.d/glib.sh"
cat << EOF > "${TMP_DIR}${GLIB_SH}"
#! /bin/bash

# Begin ${GLIB_SH}

# adds a capabiility to skip printing warning messages using an environment
# variable: GLIB_LOG_LEVEL. The value of the variable is a digit that
# correponds to:
#    1 Alert
#    2 Critical
#    3 Error
#    4 Warning
#    5 Notice

# for instance GLIB_LOG_LEVEL=4 will skip output of Waring and Notice messages
# (and Info/Debug messages if they are turned on)

export GLIB_LOG_LEVEL=4

# G_FILENAME_ENCODING
#       this environment variable can be set to a comma-separated list of
#       character set names. GLib assumes that filenames are encoded in the
#       first character set from that list rather than in UTF-8. The special
#       token "@locale" can be used to specify the character set for the
#       current locale
#
# G_BROKEN_FILENAMES
#       if this environment variable is set, GLib assumes that filenames are
#       in the locale encoding rather than in UTF-8

# if the LANG you have set contains any form of "UTF-8", we will guess you are
# using a UTF-8 locale. Hopefully we're correct
if grep -iqE "export LANG=.*UTF-8\"$" /etc/profile.d/i18n.sh 2>/dev/null; then
    export G_FILENAME_ENCODING="@locale"
fi

# it doesn't hurt to export this since G_FILENAME_ENCODING takes priority over
# G_BROKEN_FILENAMES
export G_BROKEN_FILENAMES=1

# End ${GLIB_SH}
EOF

chmod 755 "${TMP_DIR}${GLIB_SH}"

if [ -f "${GLIB_SH}" ]; then
    mv "${GLIB_SH}" "${GLIB_SH}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${GLIB_SH}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library of C routines)
#
# The GLib package contains low-level libraries useful for providing data
# structure handling for C, portability wrappers and interfaces for such
# runtime functionality as an event loop, threads, dynamic loading and an
# object system.
#
# Home page: https://www.gtk.org/
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
