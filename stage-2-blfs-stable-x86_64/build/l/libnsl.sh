#! /bin/bash

PRGNAME="libnsl"

### libnsl (the public client interface for NIS(YP) and NIS+)
# Пакет содержит библиотеку libnsl, которая включает в себя общедоступный
# клиенткий интерфейс для NIS(YP) и NIS+. Ранее данный код был частью glibc, но
# теперь существует отдельно для связи с TI-RPC и поддержки IPv6

# http://www.linuxfromscratch.org/blfs/view/stable/basicnet/libnsl.html

# Home page: https://github.com/thkukuk/libnsl
# Download:  https://github.com/thkukuk/libnsl/archive/v1.2.0/libnsl-1.2.0.tar.gz

# Required: rpcsvc-proto
#           libtirpc
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/lib"

autoreconf -fi || exit 1
./configure \
    --sysconfdir=/etc || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

mv /usr/lib/libnsl.so.* /lib
mv "${TMP_DIR}/usr/lib/libnsl.so".* "${TMP_DIR}/lib"

# определим версию перемещенной библиотеки
LIB_VERSION="$(find "${TMP_DIR}/lib" -type f -name "libnsl.so.*" | rev | \
    cut -d / -f 1 | rev | cut -d . -f 3-)"

# переместим библиотеку в /lib, чтобы она была доступна до монтирования /usr
ln -svf "../../lib/libnsl.so.${LIB_VERSION}" /usr/lib/libnsl.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf "../../lib/libnsl.so.${LIB_VERSION}" libnsl.so
)

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
# Download:  https://github.com/thkukuk/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
