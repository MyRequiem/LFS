#! /bin/bash

PRGNAME="libmd"

### libmd (Message Digest functions from BSD systems)
# Библиотека предоставляющая функции Message Digest, имеющиеся в системах BSD
# либо в их libc (NetBSD, OpenBSD) или libmd (FreeBSD, DragonflyBSD, macOS,
# Solaris) библиотеках и отсутствующие в других, таких как системы GNU

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Message Digest functions from BSD systems)
#
# This library provides message digest functions found on BSD systems either on
# their libc (NetBSD, OpenBSD) or libmd (FreeBSD, DragonflyBSD, macOS, Solaris)
# libraries and lacking on others like GNU systems.
#
# Home page: https://www.hadrons.org/software/${PRGNAME}/
# Download:  https://archive.hadrons.org/software/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
