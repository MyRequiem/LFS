#! /bin/bash

PRGNAME="p7zip"

### p7zip (file archiver with high compression rates)
# Архиватор с высокой степенью сжатия данных. Поддерживает несколько алгоритмов
# сжатия и множество форматов данных, включая собственный формат 7z c
# высокоэффективным алгоритмом сжатия LZMA: 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM,
# ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR,
# MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR и Z

# http://www.linuxfromscratch.org/blfs/view/svn/general/p7zip.html

# Home page: https://sourceforge.net/projects/p7zip/
# Download:  https://downloads.sourceforge.net/p7zip/p7zip_16.02_src_all.tar.bz2
# Patch:     http://www.linuxfromscratch.org/patches/blfs/svn/p7zip-16.02-consolidated_fixes-1.patch

# Required: no
# Optional: wxwidgets (https://www.wxwidgets.org/) для сборки GUI интерфейса 7zG

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="/root/src"
VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}_*.tar.?z*" 2>/dev/null | \
    sort | head -n 1 | cut -d _ -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}_${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим некоторые проблемы связанные с безопасностью
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-consolidated_fixes-1.patch" || exit 1

make all3

# make test

if command -v wxrc &>/dev/null; then
    make 7zG
    # make test_7zG
fi

make                        \
    DEST_HOME=/usr          \
    DEST_MAN=/usr/share/man \
    DEST_SHARE_DOC="/usr/share/doc/${PRGNAME}-${VERSION}" install

make                        \
    DEST_HOME=/usr          \
    DEST_MAN=/usr/share/man \
    DEST_DIR="${TMP_DIR}"   \
    DEST_SHARE_DOC="/usr/share/doc/${PRGNAME}-${VERSION}" install

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (file archiver with high compression rates)
#
# p7zip is the Unix command-line port of 7-Zip, a file archiver that archives
# with high compression ratios. It handles 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM,
# ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR,
# MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR and Z formats.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}_${VERSION}_src_all.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
