#! /bin/bash

PRGNAME="pcmanfm-qt"

### pcmanfm-qt (file and desktop icon manager)
# Файловый менеджер и менеджер значков на рабочем столе (Qt порт pcmanfm и
# libfm)

# Required:    plasma           (пакет layer-shell-qt)
#              liblxqt
#              libfm-qt
#              lxqt-menu-data
# Recommended: gvfs             (runtime)
#              oxygen-icons     (или другая тема на выбор, т.к.в некоторых случаях могут отсутствовать иконки)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# чтобы pcmanfm-qt было легче найти в меню, изменим .desktop файл
sed -e '/Categories=/s/=/=System;FileTools;/'   \
    -e '/Name=/s/=.*/=File Manager PCManFM-Qt'/ \
    -i "${TMP_DIR}/usr/share/applications/pcmanfm-qt.desktop" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (file and desktop icon manager)
#
# The pcmanfm-qt is a file manager and desktop icon manager (a Qt port of
# pcmanfm and libfm)
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
