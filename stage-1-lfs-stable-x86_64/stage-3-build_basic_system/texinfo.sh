#! /bin/bash

PRGNAME="texinfo"

### Texinfo (GNU software documentation system)
# Программы для чтения, записи и конвертации страниц info

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# установим компоненты, используемые пакетом tetex (texlive), который входит в
# состав BLFS
make TEXMF="/usr/share/texmf" install-tex DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU software documentation system)
#
# 'Texinfo' is a documentation system that uses a single source file to produce
# both on-line information and printed output. Using Texinfo, you can create a
# printed document with the normal features of a book, including chapters,
# sections, cross references, and indices. From the same Texinfo source file,
# you can create a menu-driven, on-line Info file with nodes, menus, cross
# references, and indices. This package is needed to read the documentation
# files in /usr/info
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
