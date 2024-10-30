#! /bin/bash

PRGNAME="libnsl"

### libnsl (the public client interface for NIS(YP) and NIS+)
# Пакет содержит библиотеку libnsl, которая включает в себя общедоступный
# клиенткий интерфейс для NIS(YP) и NIS+. Ранее данный код был частью glibc, но
# теперь существует отдельно для связи с TI-RPC и поддержки IPv6

# Required:    rpcsvc-proto
#              libtirpc
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/lib"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

if [ -d  "${TMP_DIR}/lib" ]; then
    cd "${TMP_DIR}" || exit 1
    rm -rf lib
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the public client interface for NIS(YP) and NIS+)
#
# Package contains the libnsl library. This library contains the public client
# interface for NIS(YP) and NIS+. This code was formerly part of glibc, but is
# now standalone to be able to link against TI-RPC for IPv6 support. The
# NIS(YP) functions are still maintained, the NIS+ part is deprecated and
# should not be used anymore.
#
# Home page: https://github.com/thkukuk/${PRGNAME}
# Download:  https://github.com/thkukuk/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
