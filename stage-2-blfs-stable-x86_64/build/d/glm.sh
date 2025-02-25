#! /bin/bash

PRGNAME="glm"

### glm (OpenGL Mathematics)
# C++ библиотека математических вычислений для OpenGL, предоставляющая
# программисту структуры и функции, позволяющие использовать данные для OpenGL

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/include"

# пакет содержит только заголовочные файлы, поэтому просто скопируем их
rm -f glm/CMakeLists.txt
cp -r glm "${TMP_DIR}/usr/include/"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (OpenGL Mathematics)
#
# OpenGL Mathematics (GLM) is a header only C++ mathematics library for
# graphics software based on the OpenGL Shading Language (GLSL) specification.
# GLM provides classes and functions designed and implemented with the same
# naming conventions and functionalities than GLSL so that when a programmer
# knows GLSL, he knows GLM as well which makes it really easy to use.
#
# Home page: https://github.com/g-truc/${PRGNAME}
# Download:  https://github.com/g-truc/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
