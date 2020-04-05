#! /bin/bash

PRGNAME="glib"

### GLib
# Библиотеки низкого уровня, которые включают подпрограммы поддержки C, такие
# как списки, деревья, хэши, распределение памяти и многое другое.

# http://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html

# Home page: https://www.gtk.org/
# Download:  http://ftp.gnome.org/pub/gnome/sources/glib/2.64/glib-2.64.0.tar.xz
# Patch:     http://www.linuxfromscratch.org/patches/blfs/svn/glib-2.64.0-skip_warnings-1.patch

# Required:    no
# Recommended: libxslt
#              pcre
# Optional:    dbus
#              bindfs
#              gdb
#              docbook-xml
#              docbook-xsl
#              gtk-doc
# Additional Runtime Dependencies: gobject-introspection

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# Во многих случаях приложения, которые используют эту библиотеку, прямо или
# косвенно через другие библиотеки, такие как GTK+-3, выводят многочисленные
# предупреждения при запуске из командной строки. Применение патча позволяет
# использовать переменную среды GLIB_LOG_LEVEL, которая подавляет нежелательные
# сообщения.
#    1 - Alert
#    2 - Critical
#    3 - Error
#    4 - Warning
#    5 - Notice
# Например, не выводить сообщения Warning и Notice
#    export GLIB_LOG_LEVEL=4
patch -Np1 -i /sources/glib-2.64.0-skip_warnings-1.patch || exit 1

mkdir build
cd build || exit 1

# устанавливать документацию
#    -Dman=true
# отключить поддержку selinux
#    -Dselinux=disabled
# устанавливать API документацию
#    -Ddoc=true
meson                  \
    --prefix=/usr      \
    -Dman=true         \
    -Dselinux=disabled \
    .. || exit 1

ninja || exit 1
# в конце сборки в консоль будут выводится ошибки типа:
# Error: no ID for constraint linkend: "G-VARIANT-TYPE-BOOLEAN:CAPS"
# Такие ошибки допустимы.

ninja install
DESTDIR=${TMP_DIR} ninja install

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${DOCS}"
mkdir -pv "${TMP_DIR}${DOCS}"

cp -vR ../docs/reference/{NEWS,gio,glib,gobject} "${DOCS}"
cp -vR ../docs/reference/{NEWS,gio,glib,gobject} "${TMP_DIR}${DOCS}"

# для запуска тестов требуются 2 пакета, которые пока не установлены
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
