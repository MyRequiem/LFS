#! /bin/bash

PRGNAME="cpio"

### cpio (backup and archiving utility)
# Программа для управления архивами файлов. Пакет также включает mt - программу
# управления накопителем на магнитной ленте.

# http://www.linuxfromscratch.org/blfs/view/stable/general/cpio.html

# Home page: http://www.gnu.org/software/cpio/
# Download:  https://ftp.gnu.org/gnu/cpio/cpio-2.13.tar.bz2

# Required: no
# Optional: texlive или install-tl-unx

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/html"

TEXLIVE=""
command -v texdoc &>/dev/null && TEXLIVE="true"

# собираем утилиту mt
#    --enable-mt
# запрещаем сборку программы rmt, так как она уже установлена с пакетом tar
#    --with-rmt=/usr/libexec/rmt
./configure \
    --prefix=/usr \
    --bindir=/bin \
    --enable-mt   \
    --with-rmt=/usr/libexec/rmt || exit 1

make || exit 1

# html и txt документация
makeinfo --html            -o doc/html      doc/cpio.texi
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi

# если установлен texlive или install-tl-unx, то можно соберать pdf и
# Postscript документацию
if [ -n "${TEXLIVE}" ]; then
    make -C doc pdf
    make -C doc ps
fi

# make check

make install
make install DESTDIR="${TMP_DIR}"

# устанавливаем документацию
install -v -m755 -d "${DOCS}/html"

install -v -m644 doc/cpio.{html,txt} "${DOCS}"
install -v -m644 doc/cpio.{html,txt} "${TMP_DIR}${DOCS}"

install -v -m644 doc/html/* "${DOCS}/html"
install -v -m644 doc/html/* "${TMP_DIR}${DOCS}/html"

if [ -n "${TEXLIVE}" ]; then
    install -v -m644 doc/cpio.{pdf,ps,dvi} "${DOCS}"
    install -v -m644 doc/cpio.{pdf,ps,dvi} "${TMP_DIR}${DOCS}"
fi

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
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
