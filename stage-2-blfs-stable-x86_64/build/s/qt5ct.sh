#! /bin/bash

PRGNAME="qt5ct"

### qt5ct (Qt5 configuration utility)
# Утилита для настройки параметров Qt5 (тема, шрифт, значки, и т.д.) под DE/WM
# без интеграции с Qt

# Required:    python3
#              libxkbcommon
#              qt5
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

QMAKE_CFLAGS="-O2 -fPIC"   \
QMAKE_CXXFLAGS="-O2 -fPIC" \
qmake-qt5 || exit 1

make || exit 1
make install INSTALL_ROOT="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qt5 configuration utility)
#
# This program allows users to configure Qt5 settings (theme, font, icons,
# etc.) under DE/WM without Qt integration.
#
# Home page: http://${PRGNAME}.sourceforge.net
# Download:  http://prdownloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
