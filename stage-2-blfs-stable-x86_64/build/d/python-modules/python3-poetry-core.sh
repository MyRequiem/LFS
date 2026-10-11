#! /bin/bash

PRGNAME="python3-poetry-core"
ARCH_NAME="poetry_core"

### Poetry-core (Poetry PEP 517 Build Backend)
# Встроенный инструмент сборки, который превращает исходный код Python-проекта
# в готовые файлы для установки и публикации. Позволяет устанавливать пакеты
# через pip без необходимости скачивать и устанавливать полноценную программу
# Poetry.

# Required:    no
# Recommended: no
# Optional:    --- для тестов ---
#              python3-pytest
#              python3-build
#              python3-pytest-cov    (https://pypi.org/project/pytest-cov/)
#              python3-pytest-mock   (https://pypi.org/project/pytest-mock/)
#              python3-virtualenv    (https://pypi.org/project/virtualenv/)

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
    --find-links dist   \
    --no-user           \
    poetry-core || exit 1

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# Удаляем все скомпилированные байт-коды.
rm -rf "${TMP_DIR}/usr/bin/__pycache__"
rm -rf "${TMP_SITE_PACKAGES}/__pycache__"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Poetry PEP 517 Build Backend)
#
# Poetry-core is a lightweight, fully compliant, and self-contained PEP 517
# build backend developed for Poetry.
#
# It enables PEP 517-compatible frontends like pip to build Poetry-managed
# projects efficiently without installing the full Poetry package or its entire
# dependency tree.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/p/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
