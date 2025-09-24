#! /bin/bash

PRGNAME="bind-utils"
ARCH_NAME="bind"

### bind-utils (collection client side programs from BIND)
# Набор клиентских утилит, входящих в состав BIND: nslookup, dig и host

# Required:    liburcu
#              libuv
# Recommended: json-c
#              nghttp2
# Optional:    libcap           (собранный с PAM)
#              libxml2
#              python3-sphinx

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN1="/usr/share/man/man1"
MAN8="/usr/share/man/man8"
mkdir -pv "${TMP_DIR}"{"${MAN1}","${MAN8}"}

./configure \
    --prefix=/usr || exit 1

make -C lib/isc      && \
make -C lib/dns      && \
make -C lib/ns       && \
make -C lib/isccfg   && \
make -C lib/isccc    && \
make -C bin/dig      && \
make -C bin/nsupdate && \
make -C bin/rndc     && \
make -C doc || exit 1

# пакет не имеет набора тестов

make -C lib/isc      install DESTDIR="${TMP_DIR}" && \
make -C lib/dns      install DESTDIR="${TMP_DIR}" && \
make -C lib/ns       install DESTDIR="${TMP_DIR}" && \
make -C lib/isccfg   install DESTDIR="${TMP_DIR}" && \
make -C lib/isccc    install DESTDIR="${TMP_DIR}" && \
make -C bin/dig      install DESTDIR="${TMP_DIR}" && \
make -C bin/nsupdate install DESTDIR="${TMP_DIR}" && \
make -C bin/rndc     install DESTDIR="${TMP_DIR}" || exit 1

cp -v doc/man/{dig.1,host.1,nslookup.1,nsupdate.1} "${TMP_DIR}${MAN1}"
cp -v doc/man/rndc.8                               "${TMP_DIR}${MAN8}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (collection client side programs from BIND)
#
# BIND Utilities is not a separate package, it is a collection of the client
# side programs that are included with BIND. The BIND package includes the
# client side programs nslookup, dig and host. If you install BIND server,
# these programs will be installed automatically. This section is for those
# users who dont need the complete BIND server, but need these client side
# applications.
#
# Home page: https://www.isc.org/${ARCH_NAME}/
# Download:  https://ftp.isc.org/isc/${ARCH_NAME}9/${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
