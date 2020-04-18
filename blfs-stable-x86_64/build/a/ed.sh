#! /bin/bash

PRGNAME="ed"

### GNU Ed (The GNU ed line editor)
# Реализация стандартного строкового редактора Unix. Используется для создания,
# отображения, изменения тектовых файлов как в интерактивном режиме, так и с
# помощью сценариев оболочки. Так же используется утилитой patch, если файл
# *.patch создан с помощью Ed.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/ed.html

# Home page: http://www.gnu.org/software/ed/
# Download:  https://ftp.gnu.org/gnu/ed/ed-1.15.tar.lz

# Required: libarchive
#           lzip (для распаковки архива с исходниками в формате .tar.lz)
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --bindir=/bin || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The GNU ed line editor)
#
# GNU Ed is an 8-bit clean, more or less POSIX-compliant implementation of the
# standard Unix line-oriented text editor. It is used to create, display,
# modify and otherwise manipulate text files, both interactively and via shell
# scripts. Ed isn't something which many people use. It's described here
# because it can be used by the patch program if you encounter an ed-based
# patch file. This happens rarely because diff-based patches are preferred
# these days.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.lz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
