#! /bin/bash

PRGNAME="python3-pyparsing"
ARCH_NAME="pyparsing"

### pyparsing (parsing module for python)
# Альтернативный подход к созданию и выполнению простой грамматики (синтаксиса)
# вместо традиционного подхода lex/yacc или использования обычных выражений.
# Модуль pyparsing предоставляет библиотеку классов, которые клиент использует
# для построения грамматики непосредственно в коде Python

# Required:    no
# Recommended: no
# optional:    --- для тестов ---
#              python3-railroad-diagrams    (https://pypi.org/project/railroad-diagrams/)
#              python3-pytes

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
    "${ARCH_NAME}" || exit 1

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
# Package: ${PRGNAME} (parsing module for python)
#
# The pyparsing module is an alternative approach to creating and executing
# simple grammars, vs. the traditional lex/yacc approach, or the use of regular
# expressions. The pyparsing module provides a library of classes that client
# code uses to construct the grammar directly in Python code.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/p/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
