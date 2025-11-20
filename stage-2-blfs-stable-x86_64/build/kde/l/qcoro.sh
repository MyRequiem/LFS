#! /bin/bash

PRGNAME="qcoro"

### qcoro (tools to make use of C++20 coroutines with Qt)
# Инструменты для использования сопрограмм C++20 с Qt

# Required:    qt6
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                   \
    -D CMAKE_INSTALL_PREFIX="${QT6DIR}" \
    -D CMAKE_BUILD_TYPE=Release         \
    -D BUILD_TESTING=OFF                \
    -D QCORO_BUILD_EXAMPLES=OFF         \
    -D BUILD_SHARED_LIBS=ON             \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

###
# WARNINIG
###
# Пакет по умолчанию устанавливается с префиксом ${QT6DIR}, т.е. в
# /opt/qt6 - ссылка на директорию qt6-x.x.x
#
# В данном случае пакет установлен в директорию DESTDIR/opt/qt6, поэтому при
# копировании директории DESTDIR/opt/qt6 в корень системы произойдет ошибка,
# т.к. существует ссылка /opt/qt6
#
# Переименуем DESTDIR/opt/qt6 в qt6-x.x.x
REAL_QT6DIR="/opt/$(readlink "${QT6DIR}")"
mv "${TMP_DIR}${QT6DIR}" "${TMP_DIR}${REAL_QT6DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tools to make use of C++20 coroutines with Qt)
#
# This package provides a set of tools to make use of C++20 coroutines with Qt
#
# Home page: https://github.com/danvratil/${PRGNAME}/
# Download:  https://github.com/danvratil/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
