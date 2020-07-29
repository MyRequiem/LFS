#! /bin/bash

PRGNAME="libbytesize"

### libbytesize (library for working with sizes in bytes)
# Библиотека для работы с общими операциями размеров в байтах

# http://www.linuxfromscratch.org/blfs/view/stable/general/libbytesize.html

# Home page: https://github.com/storaged-project/libbytesize/
# Download:  https://github.com/storaged-project/libbytesize/releases/download/2.2/libbytesize-2.2.tar.gz

# Required: pcre2
# Optional: gtk-doc
#           python-six (для тестов и python bindings)
#           pocketlint (python модуль для одного теста) https://github.com/rhinstaller/pocketlint/releases
#           polib      (python модуль для одного теста) https://pypi.org/project/polib/

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1

# если установлены опциональные модули Python (python-six, pocketlint, polib),
# то можно запустить регрессионные тесты
# make check

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for working with sizes in bytes)
#
# The libbytesize package is a library facilitates the common operations with
# sizes in bytes. Many projects need to work with sizes in bytes (be it sizes
# of storage space, memory,...) and all of them need to deal with the same
# issues like:
#    * How to get a human-readable string for the given size?
#    * How to store the given size so that no significant information is lost?
#    * If we store the size in bytes, what if the given size gets over the
#       MAXUINT64 value?
#    * How to interpret sizes entered by users according to their locale and
#       typing conventions?
#    * How to deal with the decimal/binary units (MB vs. MiB) ambiguity?
#
# Home page: https://github.com/storaged-project/${PRGNAME}/
# Download:  https://github.com/storaged-project/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
