#! /bin/bash

PRGNAME="kdsoap"

### kdsoap (Qt-based client/server-side SOAP component)
# Компонент протокола SOAP (Simple Object Access Protocol) на стороне клиента и
# сервера на основе Qt. Может использоватся для создания клиентских приложений
# для веб-сервисов

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

cmake                                                              \
    -D CMAKE_INSTALL_PREFIX=/usr                                   \
    -D CMAKE_BUILD_TYPE=Release                                    \
    -D KDSoap_QT6=ON                                               \
    -D CMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qt-based client/server-side SOAP component)
#
# The kdsoap is Qt-based client-side and server-side SOAP component. It can be
# used to create client applications for web services and also provides the
# means to create web services without the need for any further component such
# as a dedicated web server
#
# Home page: https://github.com/KDAB/KDSoap/
# Download:  https://github.com/KDAB/KDSoap/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
