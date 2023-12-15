#! /bin/bash

PRGNAME="python3-pyatspi2"
ARCH_NAME="pyatspi"

### python3-pyatspi2 (Python bindings for core components of the GNOME Accessibility)
# Python bindings для основных компонентов GNOME Accessibility

# Required:    python3
#              python3-pygobject3
# Recommended: at-spi2-core
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --with-python=/usr/bin/python3 || exit 1

# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python bindings for core components of the GNOME Accessibility)
#
# The PyAtSpi2 package contains Python bindings for the core components of the
# GNOME Accessibility
#
# Home page: https://gitlab.gnome.org/GNOME/${ARCH_NAME}2
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
