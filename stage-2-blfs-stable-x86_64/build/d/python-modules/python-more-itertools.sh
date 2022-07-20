#! /bin/bash

PRGNAME="python-more-itertools"
ARCH_NAME="more-itertools"

### more-itertools (Python more itertools library)
# Позволяет создавать элегантные решения для функций, работающих с итерациями

# Required:    python2
#              python3
#              python-six
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python more itertools library)
#
# Python's itertools library is a gem - you can compose elegant solutions for a
# variety of problems with the functions it provides. In more-itertools we
# collect additional building blocks, recipes, and routines for working with
# Python iterables.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://pypi.python.org/packages/db/0b/f5660bf6299ec5b9f17bd36096fa8148a1c843fa77ddfddf9bebac9301f7/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
