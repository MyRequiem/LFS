#! /bin/bash

PRGNAME="glu"

### GLU (Mesa OpenGL Utility library)
# Служебная библиотека Mesa OpenGL (libGLU)

# Required:    mesa
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

# shellcheck disable=SC2086
meson                     \
    --prefix=$XORG_PREFIX \
    --buildtype=release   \
    -Dgl_provider=gl      \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -f "${TMP_DIR}/usr/lib/libGLU.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Mesa OpenGL Utility library)
#
# glu is the Mesa OpenGL Utility library (libGLU)
#
# Home page: http://cgit.freedesktop.org/mesa/glu/
# Download:  ftp://ftp.freedesktop.org/pub/mesa/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
