#! /bin/bash

PRGNAME="xdotool"

### xdotool (fake X11 keyboard/mouse input)
# Утилита предоставляет возможности для имитации ввода с клавиатуры и
# активность мыши, перемещение и изменение размера окон и т.д.

# Required:    xorg-libraries
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make WITHOUT_RPATH_FIX=1 || exit 1
# пакет не имеет набора тестов
make PREFIX=/usr INSTALLMAN=/usr/share/man install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (fake X11 keyboard/mouse input)
#
# The xdotool package provides the capabilities to simulate keyboard input and
# mouse activity, move and resize windows, etc. It does this using X11’s XTEST
# extension and other Xlib functions
#
# Home page: https://github.com/jordansissel/${PRGNAME}/
# Download:  https://github.com/jordansissel/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
