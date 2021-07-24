#! /bin/bash

PRGNAME="python3-pyxdg"
ARCH_NAME="pyxdg"

### python-pyxdg (Python XDG Library)
# Библиотека Python для доступа к стандартам freedesktop.org

# Required:    python3
# Recommended: no
# Optional:    python2

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python XDG Library)
#
# PyXDG is a Python library to access freedesktop.org standards
#
# Home page: http://freedesktop.org/wiki/Software/${ARCH_NAME}
# Download:  https://files.pythonhosted.org/packages/6f/2e/2251b5ae2f003d865beef79c8fcd517e907ed6a69f58c32403cec3eba9b2/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
