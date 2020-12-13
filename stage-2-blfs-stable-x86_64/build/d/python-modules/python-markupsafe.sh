#! /bin/bash

PRGNAME="python-markupsafe"
ARCH_NAME="MarkupSafe"

### MarkupSafe (unicode subclass that supports HTML/XML strings)
# Python2/3 модуль реализующий текстовый объект для безопасного использования в
# HTML и XML

# Required:    python2
#              python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python3 setup.py build || exit 1

python2 setup.py install --optimize=1 --root="${TMP_DIR}"
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (unicode subclass that supports HTML/XML strings)
#
# MarkupSafe implements a text object that escapes characters so it is safe to
# use in HTML and XML. Characters that have special meanings are replaced so
# that they display as the actual characters. This mitigates injection attacks,
# meaning untrusted user input can safely be displayed on a page.
#
# Home page: https://pypi.python.org/pypi/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/M/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
