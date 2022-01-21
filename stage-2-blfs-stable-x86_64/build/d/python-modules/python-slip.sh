#! /bin/bash

PRGNAME="python-slip"

### python-slip (convenience, extension, and workaround code)
# Обеспечивает удобство, расширение и обходной код для Python и некоторых
# Python-модулей

# Required:    python-dbus
#              python3-decorator
#              python-six
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сгенерируем setup.py с актуальной версией пакета
sed "s/@VERSION@/${VERSION}/" setup.py.in > setup.py || exit 1

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (convenience, extension, and workaround code)
#
# python-slip provides convenience, extension and workaround code for Python
# and some Python modules
#
# Home page: https://github.com/nphilipp/${PRGNAME}
# Download:  https://github.com/nphilipp/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
