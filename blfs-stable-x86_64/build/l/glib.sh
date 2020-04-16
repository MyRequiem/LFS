#! /bin/bash

PRGNAME="glib"

### GLib (library of C routines)
# Библиотеки низкого уровня, которые включают подпрограммы поддержки C, такие
# как списки, деревья, хэши, распределение памяти и многое другое.

# http://www.linuxfromscratch.org/blfs/view/stable/general/glib2.html

# Home page: https://www.gtk.org/
# Download:  http://ftp.gnome.org/pub/gnome/sources/glib/2.62/glib-2.62.4.tar.xz
# Patches:   http://www.linuxfromscratch.org/patches/blfs/9.1/glib-2.62.4-cve_2020_6750_fix-1.patch
#            http://www.linuxfromscratch.org/patches/blfs/9.1/glib-2.62.4-skip_warnings-1.patch

# Required:    no
# Recommended: libxslt
#              pcre
# Optional:    dbus   (для некоторых тестов)
#              bindfs (для некоторых тестов) https://bindfs.org/
#              gdb
#              docbook-xml
#              docbook-xsl
#              gtk-doc (для сборки API документации, см. конфигурацию ниже)
#              gobject-introspection
#              desktop-file-utils (для тестов)
#              shared-mime-info   (для тестов)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

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

# исправление уязвимости обхода прокси
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-cve_2020_6750_fix-1.patch" || exit 1

mkdir build
cd build || exit 1

# устанавливать man-страницы
#    -Dman=true
# отключить поддержку selinux
#    -Dselinux=disabled
meson                  \
    --prefix=/usr      \
    -Dman=true         \
    -Dselinux=disabled \
    .. || exit 1

# если установлен пакет gtk-doc, то можно собрать и установить API документацию
# добавив опцию конфигурации
#    -Ddoc=true

ninja || exit 1
# в конце сборки в консоль могут выводится ошибки типа:
#    Error: no ID for constraint linkend: ...
# Такие ошибки допустимы и безвредны.

ninja install
DESTDIR=${TMP_DIR} ninja install

mkdir -pv "${DOCS}"
cp -vR ../docs/reference/{NEWS,gio,glib,gobject} "${DOCS}"
cp -vR ../docs/reference/{NEWS,gio,glib,gobject} "${TMP_DIR}${DOCS}"

# для запуска тестов требуются 2 установленных пакета:
#    desktop-file-utils
#    shared-mime-info
#
# ninja test

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
