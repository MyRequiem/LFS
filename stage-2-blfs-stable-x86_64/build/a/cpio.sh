#! /bin/bash

PRGNAME="cpio"

### cpio (backup and archiving utility)
# Программа для управления архивами файлов. Пакет также включает mt - программу
# управления накопителем на магнитной ленте.

# Required:    no
# Recommended: no
# Optional:    texlive или install-tl-unx

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# собираем утилиту mt
#    --enable-mt
# запрещаем сборку программы rmt, так как она уже установлена с пакетом tar
#    --with-rmt=/usr/libexec/rmt
./configure       \
    --prefix=/usr \
    --enable-mt   \
    --with-rmt=/usr/libexec/rmt || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (backup and archiving utility)
#
# This is GNU cpio, a program to manage archives of files. This package also
# includes mt, a tape drive control program. cpio copies files into or out of a
# cpio or tar archive, which is a file that contains other files plus
# information about them, such as their pathname, owner, timestamps, and access
# permissions. The archive can be another file on the disk, a magnetic tape, or
# a pipe.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
