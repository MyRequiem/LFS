#! /bin/bash

PRGNAME="python-pies"
ARCH_NAME="pies"

### pies (Simple way to write Py2 and Py3 program)
# Самый простой способ написать одну программу, работающую на Python 2.6+ и
# Python3

# Required:    python2
#              python3
#              python2-pies2overrides
#              python2-enum34
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
# Package: ${PRGNAME} (Simple way to write Py2 and Py3 program)
#
# The simplest (and tastiest) way to write one program that runs on Python 2.6+
# and Python3
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://pypi.python.org/packages/54/d2/aab9e975477e75e47608417e9610a9e47721a7c889e42be5cc363280087f/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
