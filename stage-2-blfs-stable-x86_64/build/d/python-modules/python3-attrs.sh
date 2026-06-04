#! /bin/bash

PRGNAME="python3-attrs"
ARCH_NAME="attrs"

### Attrs (attributes without boilerplate)
# Декораторы классов Python - инструмент для программистов, который избавляет
# от написания скучного и однообразного кода в Python. Он сам создает нужные
# части программы, делая её компактнее и понятнее.

# Required:    python3-hatch-fancy-pypi-readme
#              python3-hatch-vcs
# Recommended: no
# Optional:    --- для тестов ---
#              python3-pytest
#              python3-cloudpickle          (https://pypi.org/project/cloudpickle/)
#              python3-hypothesis           (https://pypi.org/project/hypothesis/)
#              python3-pympler              (https://pypi.org/project/Pympler/)
#              python3-mypy                 (https://pypi.org/project/mypy/)
#              python3-pytest-mypy-plugins  (https://pypi.org/project/pytest-mypy-plugins/)
#              python3-pytest-xdist         (https://pypi.org/project/pytest-xdist/)
#              python3-zope-interface       (https://pypi.org/project/zope.interface/)

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
    "${ARCH_NAME}" || exit 1

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды
rm -rf "${TMP_DIR}/usr/bin/__pycache__"
rm -rf "${TMP_SITE_PACKAGES}/__pycache__"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (attributes without boilerplate)
#
# Attrs is an MIT-licensed Python package with class decorators that ease the
# chores of implementing the most common attribute-related object protocols.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/a/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
