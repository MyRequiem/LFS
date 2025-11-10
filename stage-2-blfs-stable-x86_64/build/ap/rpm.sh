#! /bin/bash

PRGNAME="rpm"

### rpm (RPM package format tool)
# Инструмент от Red Hat Software, используемый для установки и удаления пакетов
# в формате .rpm

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build_
cd build_ || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D WITH_LIBDW=OFF            \
    -D WITH_AUDIT=OFF            \
    -D WITH_SELINUX=OFF          \
    -D WITH_SEQUOIA=OFF          \
    -W no-dev                    \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RPM package format tool)
#
# RPM is a tool from Red Hat Software used to install and remove packages in
# the .rpm format
#
# Home page: http://ftp.${PRGNAME}.org
# Download:  http://ftp.${PRGNAME}.org/releases/${PRGNAME}-${MAJ_VERSION}.x/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
