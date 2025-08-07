#! /bin/bash

PRGNAME="python3-flit-core"
ARCH_NAME="flit_core"

### Flit_core (a PEP517 build backend for packages using Flit)
# Модуль Flit_core является ключевым компонентом системы Flit, обеспечивающим
# простой способ разместить пакеты и модули Python на PyPi

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
# Package: ${PRGNAME} (a PEP517 build backend for packages using Flit)
#
# The Flit_core module is the key component of the Flit system, which provides
# a simple way to put Python packages and modules on PyPi
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://pypi.org/packages/source/f/flit-core/${ARCH_NAME}-${ARCH_NAME}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
