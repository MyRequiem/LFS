#! /bin/bash

PRGNAME="python2-pies2overrides"
ARCH_NAME="pies2overrides"

### pies2overrides (Defines override classes with pies)
# Определяет классы, которые следует включать в круговые диаграммы, только если
# они выполняются на Python2

# Required:    python2
#              python-ipaddress
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Defines override classes with pies)
#
# Defines override classes that should be included with pies only if running on
# Python2.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://pypi.python.org/packages/57/5e/73f57e9819b2d2e4540ca9a77cedb9b32840035fcb046ec573c54be6531f/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
