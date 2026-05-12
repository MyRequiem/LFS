#! /bin/bash

PRGNAME="xdg-utils"

### xdg-utils (command line tools that assist applications)
# Коллекция системных команд, которые помогают программам интегрироваться в
# рабочий стол. Например, они отвечают за открытие ссылки в «браузере по
# умолчанию» или выбор нужного приложения для файла.

# Required:    xmlto
#              lynx или links или w3m    (http://w3m.sourceforge.net/)
#              xorg-applications         (runtime)
# Recommended: no
# Optional:    dbus

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "$VERSION" | cut -d v -f 2)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1

# тесты должны запускаться при запущенном сеансе Х. Не рекомендуется запускать
# от пользователя root
# make -k test

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command line tools that assist applications)
#
# Xdg-utils is a set of command line tools that assist applications with a
# variety of desktop integration tasks. About half of the tools focus on tasks
# commonly required during the installation of a desktop application and the
# other half focuses on integration with the desktop environment while the
# application is running. It is required for Linux Standards Base (LSB)
# conformance.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/xdg/${PRGNAME}/-/archive/v${VERSION}/${PRGNAME}-v${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
