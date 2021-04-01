#! /bin/bash

PRGNAME="sharutils"

### Sharutils  (GNU shell archive packing utilities)
# Пакет содержит утилиты для работы с шелл-архивами, т.е. архивами, которые
# можно распаковать с помощью /bin/sh. Утилита 'shar' создает и подготавливает
# архивы для передачи по электронной почте, 'unshar' распаковывает такие архивы
# после их приема. Утилиты 'uuencode' и 'uudecode' предназначены для работы с
# кодировками шелл-архивов.

# Required:    no
# Recommended: no
# Optional:    berkeley-db (для утилиты uudecode)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим переполнение буфера стека и проблему, обнаруженную с GCC-10
sed -i 's/BUFSIZ/rw_base_size/' src/unshar.c    || exit 1
sed -i '/program_name/s/^/extern /' src/*opts.h || exit 1

sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c || exit 1
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU shell archive packing utilities)
#
# 'shar' makes so-called shell archives out of many files, preparing them for
# transmission by electronic mail services. 'unshar' helps unpacking shell
# archives after reception. 'uuencode' prepares a file for transmission over an
# electronic channel which ignores or otherwise mangles the eight bit (high
# order bit) of bytes. 'uudecode' does the converse transformation.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
