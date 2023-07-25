#! /bin/bash

PRGNAME="python3-curtsies"
ARCH_NAME="curtsies"

### curtsies (Curses-like terminal wrapper)
# Оболочка терминала, совместимая с Python 3.6+, похожая на Curses, с
# отображением на основе компоновки двухмерных массивов текста.

# Required:    python3
#              python3-six
#              python-blessings
#              python3-cwcwidth
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
# Package: ${PRGNAME} (Curses-like terminal wrapper)
#
# Python 3.6+ Curses-like terminal wrapper with a display based on compositing
# 2d arrays of text
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/b0/26/49fcac52193a33f024c36bc5a7f6d43fa3cecfecac307170a277b477aeba/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
