#! /bin/bash

PRGNAME="parted"

### parted (GNU disk partitioning tool)
# GNU Parted - программа для создания, удаления, изменения размера, проверки и
# копирование разделов жесткого диска и файловых систем на нем. Применяется для
# создания пространства для новых операционных систем, реорганизация
# использования диска, копирование данных между жесткими дисками и образами
# дисков.

# Required:    python2
# Recommended: lvm2
# Optional:    dosfstools
#              pth
#              texlive или install-tl-unx
#              digest-crc (для тестов) https://metacpan.org/pod/Digest::CRC

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

LVM2="--disable-device-mapper"
command -v lvm &>/dev/null && LVM2="--enable-device-mapper"

./configure       \
    --prefix=/usr \
    "${LVM2}"     \
    --disable-static || exit 1

make || exit 1

# html и plaintex документация
make -C doc html
# makeinfo --html      -o doc/html       doc/parted.texi
makeinfo --plaintext -o doc/parted.txt doc/parted.texi

# если установлен texlive или install-tl-unx, то соберем pdf и ps документацию
TEXLIVE=""
# command -v texdoc &>/dev/null && TEXLIVE="true"
if [ -n "${TEXLIVE}" ]; then
    texi2pdf -o doc/parted.pdf doc/parted.texi
    texi2dvi -o doc/parted.dvi doc/parted.texi
    dvips    -o doc/parted.ps  doc/parted.dvi
fi

# make check

make install DESTDIR="${TMP_DIR}"

# документация
# install -v -m644 doc/html/* "${TMP_DIR}${DOCS}/html"
install -v -m644 doc/{FAT,API,parted.{txt,html}} "${TMP_DIR}${DOCS}"

if [ -n "${TEXLIVE}" ]; then
    install -v -m644 doc/FAT doc/API doc/parted.{pdf,ps,dvi} "${TMP_DIR}${DOCS}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU disk partitioning tool)
#
# GNU Parted is a program for creating, destroying, resizing, checking and
# copying partitions, and the filesystems on them. This is useful for creating
# space for new operating systems, reorganizing disk usage, copying data
# between hard disks, and disk imaging.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
