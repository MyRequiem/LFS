#! /bin/bash

PRGNAME="xbanish"

### xbanish (banish the mouse cursor when typing)
# Утилита, которая прячет курсор при наборе текста (при нажатии любой клавиши)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make || exit 1
make install                   \
    PREFIX=/usr                \
    X11BASE=/usr               \
    MANDIR=/usr/share/man/man1 \
    DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (banish the mouse cursor when typing)
#
# xbanish hides the mouse cursor when you start typing, and shows it again when
# the mouse cursor moves or a mouse button is pressed. This is similar to
# xterm's pointerMode setting, but xbanish works globally in the X11 session.
#
# Home page: https://github.com/jcs/${PRGNAME}
# Download:  https://github.com/jcs/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
