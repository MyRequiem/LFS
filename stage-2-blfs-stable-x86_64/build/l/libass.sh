#! /bin/bash

PRGNAME="libass"

### libass (Subtitle renderer for the ASS/SSA)
# Портативный рендерер субтитров формата ASS/SSA (Advanced Substation
# Alpha/Substation Alpha)

# Required:    freetype
#              fribidi
#              nasm
# Recommended: fontconfig
# Optional:    harfbuzz

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

FONTCONFIG="--disable-fontconfig"
command -v fc-cache &>/dev/null && FONTCONFIG="--enable-fontconfig"

./configure         \
    --prefix=/usr   \
    "${FONTCONFIG}" \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Subtitle renderer for the ASS/SSA)
#
# libass is a portable subtitle renderer for the ASS/SSA (Advanced Substation
# Alpha/Substation Alpha) subtitle format that allows for more advanced
# subtitles than the conventional SRT and similar formats. It is mostly
# compatible with VSFilter.
#
# Home page: https://code.google.com/archive/p/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
