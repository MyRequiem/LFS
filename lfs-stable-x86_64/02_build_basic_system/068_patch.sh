#! /bin/bash

PRGNAME="patch"

### Patch
# Программа для изменения или создания файлов путем применения файлов *.patch,
# обычно создаваемых программой diff

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/patch.html

# Home page: https://savannah.gnu.org/projects/patch/
# Download:  http://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (apply a diff file to an original file or files)
#
# Patch is a utility used to apply diffs (or patches) to files, which are
# usually source code.
#
# Home page: https://savannah.gnu.org/projects/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
