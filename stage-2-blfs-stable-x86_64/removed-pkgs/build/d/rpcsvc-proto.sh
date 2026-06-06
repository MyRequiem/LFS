#! /bin/bash

PRGNAME="rpcsvc-proto"

### rpcsvc-proto (rpcsvc protocol.x files and headers)
# Набор заголовочных файлов для настройки удаленного вызова процедур в сети
# (которые отсутствуют в пакете libtirpc). Они нужны для правильной сборки
# старых сетевых служб и обмена данными между компьютерами. Дополнительно пакет
# содержит rpcgen, который необходим для создания заголовочных файлов и
# исходников из прото файлов.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1
# пакет не содержит набота тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (rpcsvc protocol.x files and headers)
#
# This package contains rpcsvc proto.x files from glibc, which are missing in
# libtirpc. Additional it contains rpcgen, which is needed to create header
# files and sources from protocol files. This package is only needed, if glibc
# is installed without the deprecated sunrpc functionality and libtirpc should
# replace it.
#
# Home page: https://github.com/thkukuk/${PRGNAME}
# Download:  https://github.com/thkukuk/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
