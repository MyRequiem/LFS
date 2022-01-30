#! /bin/bash

PRGNAME="bind-utils"
ARCH_NAME="$(echo "${PRGNAME}" | cut -d - -f 1)"

### bind-utils (collection client side programs from BIND)
# Набор клиентских утилит, входящих в состав BIND: nslookup, dig и host

# Required:    libuv
# Recommended: json-c
# Optional:    libcap
#              libxml2
#              sphinx (https://www.sphinx-doc.org/en/master/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN_DIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}${MAN_DIR}"

# устраним необходимость в неиспользуемом модуле Python
#    --without-python
./configure       \
    --prefix=/usr \
    --without-python || exit 1

# собираем библиотеки, необходимые для клиентских программ
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
make -C lib/dns                  || exit 1
make -C lib/isc                  || exit 1
make -C lib/bind"${MAJ_VERSION}" || exit 1
make -C lib/isccfg               || exit 1
make -C lib/irs                  || exit 1
# собираем клиентские программы (dig, host, nslookup)
make -C bin/dig || exit 1
# собираем man-страницы
make -C doc || exit 1

# данная часть пакета не имеет набора тестов

make -C bin/dig install DESTDIR="${TMP_DIR}"
cp -v doc/man/{dig,host,nslookup}.1 "${TMP_DIR}${MAN_DIR}"

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
# Download:  ftp://ftp.isc.org/isc/${ARCH_NAME}${MAJ_VERSION}/${VERSION}/${ARCH_NAME}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
