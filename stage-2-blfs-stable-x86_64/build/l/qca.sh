#! /bin/bash

PRGNAME="qca"

### Qca (Qt Cryptographic Architecture)
# Простой кроссплатформенный криптографический API, использующий типы данных и
# соглашения Qt

# Required:    make-ca
#              cmake
#              qt6
#              which
# Recommended: no
# Optional:    cyrus-sasl
#              gnupg
#              libgcrypt
#              libgpg-error
#              nss
#              nspr
#              p11-kit
#              doxygen
#              botan            (https://botan.randombit.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим путь к CA-сертификатам
sed -i 's@cert.pem@certs/ca-bundle.crt@' CMakeLists.txt

mkdir build
cd build || exit 1

cmake                                          \
    -D CMAKE_INSTALL_PREFIX="${QT6DIR}"        \
    -D CMAKE_BUILD_TYPE=Release                \
    -D QT6=ON                                  \
    -D QCA_INSTALL_IN_QT_PREFIX=ON             \
    -D QCA_MAN_INSTALL_DIR:PATH=/usr/share/man \
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
# Package: ${PRGNAME} (Qt Cryptographic Architecture)
#
# Qca aims to provide a straightforward and cross-platform crypto API, using Qt
# datatypes and conventions. Qca separates the API from the implementation,
# using plugins known as Providers
#
# Home page: https://github.com/KDE/${PRGNAME}
# Download:  https://download.kde.org/stable/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
