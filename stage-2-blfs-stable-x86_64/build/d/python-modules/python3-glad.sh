#! /bin/bash

PRGNAME="python3-glad"
ARCH_NAME="glad"

### Glad (a generator for loading Vulkan, OpenGL, EGL, GLES, and GLX)
# Содержит генератор для загрузки контекстов Vulkan, OpenGL, EGL, GLES и GLX

# Required:    no
# Recommended: no
# Optional:    --- для тестов ---
#              python3-pytest
#              rustc
#              xorg-libraries
#              glfw             (https://www.glfw.org/)
#              wine             (https://www.winehq.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links=dist   \
    --no-cache-dir      \
    --no-user           \
    "${ARCH_NAME}2" || exit 1

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a generator for loading Vulkan, OpenGL, EGL, GLES, and GLX)
#
# The Glad package contains a generator for loading Vulkan, OpenGL, EGL, GLES, and GLX contexts.
#
# Home page: https://github.com/Dav1dde/${ARCH_NAME}/
# Download:  https://github.com/Dav1dde/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
