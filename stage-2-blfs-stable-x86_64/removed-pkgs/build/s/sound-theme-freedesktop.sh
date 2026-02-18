#! /bin/bash

PRGNAME="sound-theme-freedesktop"

### sound-theme-freedesktop (freedesktop.org sound theme)
# Базовый набор звуков для приложений

# Required:    no
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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (freedesktop.org sound theme)
#
# The freedesktop.org sound theme is a basic set of sounds for applications to
# use.
#
# Home page: https://freedesktop.org/wiki/Specifications/sound-theme-spec/
# Download:  https://people.freedesktop.org/~mccann/dist/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
