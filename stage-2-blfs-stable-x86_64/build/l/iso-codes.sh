#! /bin/bash

PRGNAME="iso-codes"

### ISO Codes (ISO-standard lists)
# Огромный справочник стандартных названий стран, языков и валют. Программы
# используют его, чтобы во всей системе географические названия отображались
# единообразно и правильно переводились на русский язык.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d v -f 2)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup .. \
    --prefix=/usr || exit 1

# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ISO-standard lists)
#
# This package provides lists of various ISO standards (e.g. country, language,
# language scripts, and currency names) in one place, rather than repeated in
# many programs throughout the system. It is used as a central database for
# accessing this data.
#
# Home page: https://salsa.debian.org/${PRGNAME}-team/${PRGNAME}
# Download:  https://salsa.debian.org/${PRGNAME}-team/${PRGNAME}/-/archive/v${VERSION}/${PRGNAME}-v${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
