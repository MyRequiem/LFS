#! /bin/bash

PRGNAME="libtirpc"
LIB_VERSION="3.0.0"

### libtirpc (Transport-Independent RPC library)
# Библиотеки поддерживающие программы, которые используют API процедур
# удаленного вызова (RPC).

# http://www.linuxfromscratch.org/blfs/view/stable/basicnet/libtirpc.html

# Home page: http://sourceforge.net/projects/libtirpc/
# Download:  https://downloads.sourceforge.net/libtirpc/libtirpc-1.2.5.tar.bz2

# Required: no
# Optional: mit-kerberos-v5 (для gssapi)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/lib"

### NOTE:
# при обновлении этого пакета также необходимо обновить любую существующую
# версию пакета rpcbind

GSSAPI="--disable-gssapi"
command -v kadmind &>/dev/null && GSSAPI="--enable-gssapi"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    "${GSSAPI}" || exit 1

make || exit 1

NETCONFIG="/etc/netconfig"
if [ -f "${NETCONFIG}" ]; then
    mv "${NETCONFIG}" "${NETCONFIG}.old"
fi

BINDRESVPORT="/etc/bindresvport.blacklist"
if [ -f "${BINDRESVPORT}" ]; then
    mv "${BINDRESVPORT}" "${BINDRESVPORT}.old"
fi

# пакет не имеет набора тестов
make install
make install DESTDIR="${TMP_DIR}"

config_file_processing "${NETCONFIG}"
config_file_processing "${BINDRESVPORT}"

# переместим библиотеки из /usr/lib в /lib, чтобы они были доступны до
# монтирования /usr
mv -v /usr/lib/libtirpc.so.* /lib
mv -v "${TMP_DIR}/usr/lib/libtirpc.so".* "${TMP_DIR}/lib"

# восстановим ссылку /usr/lib/libtirpc.so -> ../../lib/libtirpc.so.3.0.0
ln -svf "../../lib/libtirpc.so.${LIB_VERSION}" /usr/lib/libtirpc.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf "../../lib/libtirpc.so.${LIB_VERSION}" libtirpc.so
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Transport-Independent RPC library)
#
# Libtirpc is a port of Sun's Transport-Independent RPC library to Linux. You
# will need this library if you plan to use RPC with a GLIBC version newer than
# 2.13, because the RPC stack has been removed from GLIBC versions newer than
# 2.13. This libraries support programs that use the Remote Procedure Call
# (RPC) API. It replaces the RPC, but not the NIS library entries that used to
# be in glibc.
#
# Home page: http://sourceforge.net/projects/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
