#! /bin/bash

PRGNAME="deb2tgz"

### deb2tgz (convert Debian packages)
# Конвертирует пакеты Debian (.deb) в пакеты Slackware

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/bin"

cp "${PRGNAME}" "${TMP_DIR}/usr/bin"

/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (convert Debian packages)
#
# deb2tgz is a shell script that converts Debian packages to Slackware
# packages. It added support to other formats to the shell script deb2tgz that
# exists in https://code.google.com/archive/p/deb2tgz/
#
# Home page: https://github.com/vborrego/${PRGNAME}
# Download:  https://github.com/vborrego/${PRGNAME}/archive/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
