#! /bin/bash

PRGNAME="pytrash"

### pytrash (CLI implementation of the "trash")
# CLI-реализация корзины на Python3

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# /usr/bin/pytrash
USR_BIN="/usr/bin"
install -v -m755 -d "${TMP_DIR}${USR_BIN}"
install -v -m755    "src/${PRGNAME}" "${TMP_DIR}${USR_BIN}/"

# /usr/lib/site-packages/pytrash/*.py
PYTHON3_MAJ_VER="$(python3 -V | cut -d " " -f 2 | cut -d . -f 1,2)"
SITE_PACKAGES="/usr/lib/python${PYTHON3_MAJ_VER}/site-packages"
install -v -m755 -d       "${TMP_DIR}${SITE_PACKAGES}/${PRGNAME}"
install -v -m644 src/*.py "${TMP_DIR}${SITE_PACKAGES}/${PRGNAME}/"

# man
MAN="/usr/share/man/man8"
install -v -m755 -d "${TMP_DIR}${MAN}"
install -v -m644    "man/${PRGNAME}.8" "${TMP_DIR}${MAN}/"

# bash complition
BASH_COMPLETION="/usr/share/bash-completion/completions"
install -v -m755 -d "${TMP_DIR}${BASH_COMPLETION}"
install -v -m644    "etc/bash_completion.d/${PRGNAME}-bash-complition.sh" \
    "${TMP_DIR}${BASH_COMPLETION}/${PRGNAME}"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (CLI implementation of the "trash")
#
# pytrash - CLI implementation of the "trash"
#
# Home page: https://github.com/MyRequiem/${PRGNAME}
# Download:  https://github.com/MyRequiem/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
