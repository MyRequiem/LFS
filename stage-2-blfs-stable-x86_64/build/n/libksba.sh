#! /bin/bash

PRGNAME="libksba"

### libksba (X.509 & CMS library for S/MIME and TLS)
# Библиотека для работы с сертификатами X.509

# Required:    libgpg-error
# Recommended: no
# Optional:    valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VALGRIND="--disable-valgrind-tests"
# command -v valgrind &>/dev/null && VALGRIND="--enable-valgrind-tests"

./configure       \
    --prefix=/usr \
    "${VALGRIND}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X.509 & CMS library for S/MIME and TLS)
#
# Libksba is a library to make the tasks of working with X.509 certificates,
# CMS data and related objects more easy. It provides a highlevel interface to
# the implemented protocols and presents the data in a consistent way. There is
# no more need to worry about all the nasty details of the protocols. The API
# gives the C programmer an easy way of interacting with the data. It copes
# with the version details X.509 protocols tend to have as well as with the
# many different versions and dialects. Applications must usually cope with all
# of this and it has to be coded over and over again. Libksba hides this by
# providing just one API which does the Right Thing™. Support for new features
# will be added as needed. The Libksba package contains a library used to make
# X.509 certificates as well as making the CMS (Cryptographic Message Syntax)
# easily accessible by other applications. Both specifications are building
# blocks of S/MIME and TLS. The library does not rely on another cryptographic
# library but provides hooks for easy integration with Libgcrypt.
#
# Home page: https://gnupg.org/software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
