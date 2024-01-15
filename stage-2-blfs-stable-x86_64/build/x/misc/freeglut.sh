#! /bin/bash

PRGNAME="freeglut"

### Freeglut (alternative GLUT library)
# Полностью открытый и 100% совместимый клон библиотеки OpenGL Utility Toolkit
# (GLUT). GLUT - это независимый от Window System инструментарий для написания
# OpenGL-программ, реализующий простой оконный API, что делает достаточно
# легким обучение OpenGL-программированию.

# Required:    cmake
#              mesa
# Recommended: glu
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# отключим создание дополнительных демонстрационных программ (рекомендуется)
#    -DFREEGLUT_BUILD_DEMOS=OFF
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr       \
    -DCMAKE_BUILD_TYPE=Release        \
    -DFREEGLUT_BUILD_DEMOS=OFF        \
    -DFREEGLUT_BUILD_STATIC_LIBS=OFF  \
    -Wno-dev .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (alternative GLUT library)
#
# freeglut is a completely OpenSourced alternative to the OpenGL Utility
# Toolkit (GLUT) library. GLUT (and hence freeglut) allows the user to create
# and manage windows containing OpenGL contexts on a wide range of platforms
# and also read the mouse, keyboard, and joystick functions.
#
# Home page: http://freeglut.sourceforge.net/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
