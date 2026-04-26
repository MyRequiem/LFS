#! /bin/bash

PRGNAME="sdl12-compat"
ARCH_NAME="sdl12-compat-release"

### sdl12-compat-release (Simple DirectMedia Layer Version 1)
# Кроссплатформенная библиотека, предназначенная для обеспечения
# низкоуровневого доступа к аудио, клавиатуре, мыши, джойстику и графическому
# оборудованию через OpenGL

# Required:    cmake
#              glu
#              sdl2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=RELEASE  \
    ..  || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# удалим статическую библиотеку
rm -vf "${TMP_DIR}/usr/lib/libSDLmain.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple DirectMedia Layer Version 1)
#
# Simple DirectMedia Layer Version 1 is a cross-platform library designed to
# provide low-level access to audio, keyboard, mouse, joystick, and graphics
# hardware via OpenGL
#
# Home page: https://libsdl.org/
# Download:  https://github.com/libsdl-org/${PRGNAME}/archive/release-${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
