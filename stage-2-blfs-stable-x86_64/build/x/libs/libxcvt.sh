#! /bin/bash

PRGNAME="libxcvt"

### libxcvt (VESA CVT standard timing modeline generation library)
# Библиотека, предоставляющая автономную версию X-сервера стандартных временных
# моделей VESA CVT. Предназначена для прямой замены версии, ранее
# предоставляемой Xorg сервером.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson                         \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (VESA CVT standard timing modeline generation library)
#
# libxcvt is a library providing a standalone version of the X server
# implementation of the VESA CVT standard timing modelines generator. It is
# meant to be a direct replacement to the version formerly provided by the Xorg
# server.
#
# Home page: https://gitlab.freedesktop.org/xorg/lib/${PRGNAME}
# Download: https://www.x.org/pub/individual/lib/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
