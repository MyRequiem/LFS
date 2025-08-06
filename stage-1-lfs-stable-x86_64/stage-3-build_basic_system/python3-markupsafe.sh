#! /bin/bash

PRGNAME="python3-markupsafe"
ARCH_NAME="markupsafe"

### MarkupSafe (unicode subclass that supports HTML/XML strings)
# Python2/3 модуль реализующий текстовый объект для безопасного использования в
# HTML и XML

ROOT="/"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-cache-dir       \
    --no-build-isolation \
    --no-deps            \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
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
# Package: ${PRGNAME} (unicode subclass that supports HTML/XML strings)
#
# MarkupSafe implements a text object that escapes characters so it is safe to
# use in HTML and XML. Characters that have special meanings are replaced so
# that they display as the actual characters. This mitigates injection attacks,
# meaning untrusted user input can safely be displayed on a page.
#
# Home page: https://pypi.python.org/pypi/${ARCH_NAME}/
# Download:  https://pypi.org/packages/source/M/MarkupSafe/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
