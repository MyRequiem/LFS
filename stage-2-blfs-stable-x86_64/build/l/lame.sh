#! /bin/bash

PRGNAME="lame"

### LAME (LAME Ain't an Mp3 Encoder)
# Утилиты для кодирования аудио в формат MP3. LAME - рекурсивный акроним для
# Ain’t an MP3 Encoder (LAME - это не MP3-кодировщик), относящийся к ранней
# истории LAME, когда он не был кодером в полной мере, а входил в
# демонстрационный код ISO

# Required:    no
# Recommended: no
# Optional:    dmalloc        (https://dmalloc.com/)
#              electric-fence (https://linux.softpedia.com/get/Programming/Debuggers/Electric-Fence-3305.shtml/)
#              libsndfile
#              nasm           (оптимизация сборки, но только для 32-bit x86)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим жестко запрограммированый в исходном коде путь поиска библиотек в
# установленных программах
sed -i -e 's/^\(\s*hardcode_libdir_flag_spec\s*=\).*/\1/' configure

./configure          \
    --prefix=/usr    \
    --enable-mp3rtp  \
    --disable-static || exit 1

make || exit 1
# LD_LIBRARY_PATH=libmp3lame/.libs make test
make pkghtmldir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (LAME Ain't an Mp3 Encoder)
#
# The LAME package contains an MP3 encoder and optionally, an MP3 frame
# analyzer. This is useful for creating and analyzing compressed audio files.
#
# Home page: https://${PRGNAME}.sourceforge.io/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
