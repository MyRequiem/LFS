#! /bin/bash

PRGNAME="nettle"

### Nettle (small cryptographic library)
# Криптографическая библиотека для C++, Python, Pike и других
# объектно-ориентированных языков программирования, а так же для таких
# приложений как LSH, GNUPG и т.п.

# Required:    no
# Recommended: no
# Optional:    valgrind (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

chmod -v 755 "${TMP_DIR}/usr/lib/lib"{hogweed,nettle}.so

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (small cryptographic library)
#
# Nettle is a cryptographic library that is designed to fit easily in more or
# less any context: in crypto toolkits for object-oriented languages (C++,
# Python, Pike, ...), in applications like LSH or GNUPG, or even in kernel
# space.
#
# Home page: https://www.lysator.liu.se/~nisse/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
