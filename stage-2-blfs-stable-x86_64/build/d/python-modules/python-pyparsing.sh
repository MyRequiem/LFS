#! /bin/bash

PRGNAME="python-pyparsing"
ARCH_NAME="pyparsing"

### pyparsing (parsing module for python)
# Альтернативный подход к созданию и выполнению простой грамматики (синтаксиса)
# вместо традиционного подхода lex/yacc или использования обычных выражений.
# Модуль pyparsing предоставляет библиотеку классов, которые клиент использует
# для построения грамматики непосредственно в коде Python

# Required:    no
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
# Package: ${PRGNAME} (parsing module for python)
#
# The pyparsing module is an alternative approach to creating and executing
# simple grammars, vs. the traditional lex/yacc approach, or the use of regular
# expressions. The pyparsing module provides a library of classes that client
# code uses to construct the grammar directly in Python code.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://github.com/${ARCH_NAME}/${ARCH_NAME}/releases/download/${ARCH_NAME}_${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
