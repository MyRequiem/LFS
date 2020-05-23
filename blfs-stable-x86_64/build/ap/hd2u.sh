#! /bin/bash

PRGNAME="hd2u"

### Hd2u (an any to any text format converter)
# Конвертер любых текстовых форматов

# http://www.linuxfromscratch.org/blfs/view/stable/general/hd2u.html

# Home page: https://hany.sk/~hany/
# Download:  http://hany.sk/~hany/_data/hd2u/hd2u-1.0.4.tgz

# Required: popt
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install
make install BUILD_ROOT="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an any to any text format converter)
#
# The hd2u package contains an any to any text format converter.
#
# Home page: https://hany.sk/~hany/
# Download:  http://hany.sk/~hany/_data/hd2u/hd2u-1.0.4.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
