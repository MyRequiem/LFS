#! /bin/bash

PRGNAME="python3-trove-classifiers"
ARCH_NAME="trove_classifiers"

### Trove-Classifiers (Canonical source for classifiers on PyPI)
# Библиотека Python, охватывающая все допустимые классификаторы PyPI  согласно
# PEP 301

# Required:    no
# Recommended: no
# Optional:    python3-pytest (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# жестко закодируем версию пакета в файле setup.py, чтобы обойти проблему,
# из-за которой сгенерированное wheel содержит неверную версию, если модуль
# python3-calver (не входит в BLFS) не установлен
sed -i "/calver/s/^/#/;\$iversion=\"${VERSION}\"" setup.py || exit 1

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
    trove-classifiers || exit 1

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
# Package: ${PRGNAME} (Canonical source for classifiers on PyPI)
#
# Trove-Classifiers is a Python library to encompass all valid PyPI classifiers
# used to categorize projects and releases per PEP 301, for example
# Topic :: System :: Filesystems and Development Status :: 6 - Mature
#
# Home page: https://pypi.org/project/trove-classifiers/
# Download:  https://files.pythonhosted.org/packages/source/t/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
