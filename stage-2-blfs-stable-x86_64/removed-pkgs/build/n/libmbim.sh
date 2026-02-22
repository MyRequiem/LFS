#! /bin/bash

PRGNAME="libmbim"

### libmbim (library for talking to WWAN modems)
# Библиотека на основе GLib для взаимодействия с модемами WWAN, поддерживающие
# протокол широкополосной модели мобильного интерфейса (MBIM)

# Required:    glib
# Recommended: no
# Optional:    gtk-doc
#              bash-completion    (https://github.com/scop/bash-completion)
#              help2man           (https://ftpmirror.gnu.org/gnu/help2man/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..              \
    --prefix=/usr           \
    --buildtype=release     \
    -D bash_completion=true \
    -D man=true || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for talking to WWAN modems)
#
# The libmbim package contains a GLib-based library for talking to WWAN modems
# and devices which speak the Mobile Interface Broadband Model (MBIM) protocol
#
# Home page: https://gitlab.freedesktop.org/mobile-broadband/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/mobile-broadband/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
