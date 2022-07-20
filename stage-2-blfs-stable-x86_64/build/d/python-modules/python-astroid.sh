#! /bin/bash

PRGNAME="python-astroid"
ARCH_NAME="astroid"

### astroid (new abstract syntax tree from Python's ast)
# Общее базовое представление исходного кода Python таких проектов, как
# pychecker, pyreverse, pylint и др. На самом деле разработка этой библиотеки в
# основном регулируется потребностями pylint

# Required:    python2
#              python3
#              python-six
#              python2-lazy-object-proxy
#              python3-lazy-object-proxy
#              python-wrapt
#              python-setuptools-scm
#              python3-typed-ast

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
# Package: ${PRGNAME} (new abstract syntax tree from Python's ast)
#
# The aim of this module is to provide a common base representation of python
# source code for projects such as pychecker, pyreverse, pylint... Well,
# actually the development of this library is essentially governed by pylint's
# needs. It used to be called logilab-astng.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/40/89/d29f51ca63b25c488e8f12812d80a970d1f0897de22b175d8ff23f2dcbe7/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
