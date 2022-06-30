#! /bin/bash

PRGNAME="libx86emu"

### libx86emu (x86 emulation library)
# Библиотека x86 эмуляции

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# fix CFLAGS
sed -i "s/-O2/-O2 -fPIC/" Makefile

# отключаем генерацию файлов changelog и VERSION
chmod -x ./git2log
echo "${VERSION}" > VERSION

make LIBDIR=/usr/lib                              || exit 1
make LIBDIR=/usr/lib install DESTDIR="${TMP_DIR}" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (x86 emulation library)
#
# Small x86 emulation library with focus of easy usage and extended execution
# logging functions.
#
# Home page: https://github.com/wfeldt/${PRGNAME}
# Download:  https://github.com/wfeldt/${PRGNAME}/archive/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
