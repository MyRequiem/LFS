#! /bin/bash

PRGNAME="python-pytest"
ARCH_NAME="pytest"

### pytest (simple powerful testing with Python)
# Полнофункциональный инструмент для тестирования Python программ.

# Required:    python2
#              python3
#              python3-six
#              python-scandir
#              python-setuptools-scm
#              python-py
#              python3-attrs
#              python-pluggy
#              python-more-itertools
#              python-atomicwrites
#              python-funcsigs
#              python-pathlib2
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
# Package: ${PRGNAME} (simple powerful testing with Python)
#
# A mature full-featured Python testing tool. Helps you write better programs.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/8f/c4/e4a645f8a3d6c6993cb3934ee593e705947dfafad4ca5148b9a0fde7359c/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
