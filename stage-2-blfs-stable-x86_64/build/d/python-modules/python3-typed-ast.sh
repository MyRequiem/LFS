#! /bin/bash

PRGNAME="python3-typed-ast"
ARCH_NAME="typed_ast"

### typed_ast (abstract syntax tree parser)
# Парсер, аналогичный стандартной Python библиотеке ast. В отличие от ast,
# парсеры в typed_ast включают комментарии типа PEP 484 и не зависят от версии
# Python, под которым они запущены.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (abstract syntax tree parser)
#
# typed_ast is a Python 3 package that provides a Python 2.7 and Python 3
# parser similar to the standard ast library. Unlike ast, the parsers in
# typed_ast include PEP 484 type comments and are independent of the version of
# Python under which they are run. The typed_ast parsers produce the standard
# Python AST (plus type comments), and are both fast and correct, as they are
# based on the CPython 2.7 and 3.6 parsers.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/07/d2/d55702e8deba2c80282fea0df53130790d8f398648be589750954c2dcce4/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
