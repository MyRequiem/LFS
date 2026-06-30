#! /bin/bash

PRGNAME="icon-naming-utils"

### icon-naming-utils (generate icon files for your DE)
# Perl сценарий, используемый для поддержки обратной совместимости с текущими
# темами значков рабочего стола

# Required:    perl-xml-simple
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (generate icon files for your DE)
#
# The icon-naming-utils package contains a Perl script used for maintaining
# backwards compatibility with current desktop icon themes, while migrating to
# the names specified in the Icon Naming Specification
#
# Home page: https://tango.freedesktop.org/releases/
# Download:  https://tango.freedesktop.org/releases/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
