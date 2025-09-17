#! /bin/bash

PRGNAME="7zip"

### 7zip (file archiver with high compression rates)
# Архиватор с высокой степенью сжатия данных. Поддерживает несколько алгоритмов
# сжатия и множество форматов данных, включая собственный формат 7z c
# высокоэффективным алгоритмом сжатия LZMA: 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM,
# ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR,
# MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR и Z

# Required:    no
# Recommended: no
# Optional:    uasm (https://github.com/Terraspace/UASM)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/"usr/{bin,lib/7zip}

(
    for TARGET in Bundles/{Alone,Alone7z,Format7zF,SFXCon} UI/Console; do
        make -C "CPP/7zip/${TARGET}" -f ../../cmpl_gcc.mak || exit 1
    done
)

# пакет не имеет набора тестов

install -vDm755 CPP/7zip/Bundles/Alone{/b/g/7za,7z/b/g/7zr} \
                CPP/7zip/Bundles/Format7zF/b/g/7z.so        \
                CPP/7zip/UI/Console/b/g/7z                  \
                -t "${TMP_DIR}/usr/lib/7zip/" || exit 1

install -vm755 CPP/7zip/Bundles/SFXCon/b/g/7zCon \
    "${TMP_DIR}/usr/lib/7zip/7zCon.sfx" || exit 1

(
    for TARGET in 7z 7za 7zr; do
        cat > "${TMP_DIR}/usr/bin/${TARGET}" << EOF || exit 1
#!/bin/sh
exec /usr/lib/7zip/${TARGET} "\$@"
EOF
        chmod 755 "${TMP_DIR}/usr/bin/${TARGET}" || exit 1
    done
) || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (file archiver with high compression rates)
#
# 7zip is the Unix command-line port of 7-Zip, a file archiver that archives
# with high compression ratios. It handles 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM,
# ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR,
# MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR and Z formats.
#
# Home page: https://github.com/ip7z/${PRGNAME}/
# Download:  https://github.com/ip7z/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
