#! /bin/bash

PRGNAME="bumblebee-status"

### bumblebee-status (status line generator for i3wm)
# Модульный генератор строки состояния для оконного менеджера i3

# Required:    i3
# Recommended: python3-psutil    (для модулей cpu и cpu2)
#              hddtemp           (для модуля hddtemp)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-2.2.0-with-python-3.12.5.patch" || exit 1

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (status line generator for i3wm)
#
# bumblebee-status is a modular, theme-able status line generator for the i3
# window manager
#
# Home page: https://github.com/tobi-wan-kenobi/${PRGNAME}/
# Download:  https://github.com/tobi-wan-kenobi/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
