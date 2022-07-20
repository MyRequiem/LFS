#! /bin/bash

PRGNAME="pyflakes"

### pyflakes (passive checker of Python programs)
# Используется для анализа кода Python и обнаружения различных ошибок.
# Анализирует исходный файл, а не импортирует его, поэтому его безопасно
# использовать на модулях с побочными эффектами.

# Required:    python2
#              python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

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
# Package: ${PRGNAME} (passive checker of Python programs)
#
# Pyflakes is a program to analyze Python programs and detect various errors.
# It works by parsing the source file, not importing it, so it is safe to use
# on modules with side effects. It's also much faster passive checker of Python
# programs.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://files.pythonhosted.org/packages/15/60/c577e54518086e98470e9088278247f4af1d39cb43bcbd731e2c307acd6a/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
