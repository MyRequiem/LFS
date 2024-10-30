#! /bin/bash

PRGNAME="libtirpc"

### libtirpc (Transport-Independent RPC library)
# Библиотеки поддерживающие программы, которые используют API процедур
# удаленного вызова (RPC).

# Required:    no
# Recommended: no
# Optional:    mit-kerberos-v5 (для GSSAPI)

### NOTE:
# при обновлении этого пакета также необходимо обновить/пересобрать любую
# существующую версию пакета rpcbind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GSSAPI="--disable-gssapi"
command -v kadmin &>/dev/null && GSSAPI="--enable-gssapi"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    "${GSSAPI}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

NETCONFIG="/etc/netconfig"
if [ -f "${NETCONFIG}" ]; then
    mv "${NETCONFIG}" "${NETCONFIG}.old"
fi

BINDRESVPORT="/etc/bindresvport.blacklist"
if [ -f "${BINDRESVPORT}" ]; then
    mv "${BINDRESVPORT}" "${BINDRESVPORT}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${NETCONFIG}"
config_file_processing "${BINDRESVPORT}"

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
