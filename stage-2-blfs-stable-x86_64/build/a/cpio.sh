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
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

BUILD_HTML_DOCS="false"
TEXLIVE=""
# command -v texdoc &>/dev/null && TEXLIVE="true"

# исправим ошибку сборки с GCC >=10
sed -i '/The name/,+2 d' src/global.c || exit 1

# собираем утилиту mt
#    --enable-mt
# запрещаем сборку программы rmt, так как она уже установлена с пакетом tar
#    --with-rmt=/usr/libexec/rmt
./configure \
    --prefix=/usr \
    --enable-mt   \
    --with-rmt=/usr/libexec/rmt || exit 1

make || exit 1

# txt документация
makeinfo --plaintext -o doc/cpio.txt  doc/cpio.texi

# html документация
if [[ "x${BUILD_HTML_DOCS}" == "xtrue" ]]; then
    makeinfo --html            -o doc/html      doc/cpio.texi
    makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi
fi

# если установлен texlive или install-tl-unx, то можно соберать pdf и
# Postscript документацию
if [ -n "${TEXLIVE}" ]; then
    make -C doc pdf
    make -C doc ps
fi

# make check
make install DESTDIR="${TMP_DIR}"

# устанавливаем документацию
install -v -m644 doc/cpio.txt "${TMP_DIR}${DOCS}"

if [[ "x${BUILD_HTML_DOCS}" == "xtrue" ]]; then
    install -v -m755 -d "${TMP_DIR}${DOCS}/html"
    install -v -m644 doc/html/* "${TMP_DIR}${DOCS}/html"
fi

if [ -n "${TEXLIVE}" ]; then
    install -v -m644 doc/cpio.{pdf,ps,dvi} "${TMP_DIR}${DOCS}"
fi

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
