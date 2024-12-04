#! /bin/bash

PRGNAME="p7zip"

### p7zip (file archiver with high compression rates)
# Архиватор с высокой степенью сжатия данных. Поддерживает несколько алгоритмов
# сжатия и множество форматов данных, включая собственный формат 7z c
# высокоэффективным алгоритмом сжатия LZMA: 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM,
# ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR,
# MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR и Z

# Required:    no
# Recommended: no
# Optional:    wxwidgets (https://www.wxwidgets.org/) для сборки GUI интерфейса 7zG

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим несколько уязвимостей безопасности
patch -Np1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-consolidated_fixes-1.patch" || exit 1

# не позволяем p7zip устанавливать сжатые (gzip) man-страницы
sed '/^gzip/d' -i install.sh

make all3

# make test

make                        \
    DEST_HOME=/usr          \
    DEST_MAN=/usr/share/man \
    DEST_DIR="${TMP_DIR}"   \
    DEST_SHARE_DOC="/usr/share/doc/${PRGNAME}-${VERSION}" install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (file archiver with high compression rates)
#
# p7zip is the Unix command-line port of 7-Zip, a file archiver that archives
# with high compression ratios. It handles 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM,
# ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR,
# MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR and Z formats.
#
# Home page: https://github.com/${PRGNAME}-project/${PRGNAME}
# Download:  https://github.com/${PRGNAME}-project/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
