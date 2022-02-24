#! /bin/bash

PRGNAME="libtheora"

### libtheora (Theora video codec library)
# Видеокодек разрабатываемый фондом Xiph.Org, предназначенный для использования
# в мультимедийной потоковой системе Ogg Foundation

# Required:    libogg
# Recommended: libvorbis
# Optional:    sdl и libpng (для сборки примеров)
#              valgrind (для тестов)
#              -- 4 пакета для создания API документации --
#              doxygen
#              texlive или install-tl-unx
#              bibtex (http://bibtexml.sourceforge.net/)
#              transfig (http://mcj.sourceforge.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

BUILD_EXAMPLE="false"

command -v sdl-config &>/dev/null && \
    command -v libpng-config &>/dev/null && BUILD_EXAMPLE="true"

# исправим ошибку сборки с libpng 1.6
sed -i 's/png_\(sizeof\)/\1/g' examples/png2theora.c || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# установим примеры
if [[ "x${BUILD_EXAMPLE}" == "xtrue" ]]; then
    mkdir -p "${TMP_DIR}/usr/bin"
    cd examples/.libs || exit 1
    for EXAMPLE in *; do
        install -v -m755 "${EXAMPLE}" "${TMP_DIR}/usr/bin/theora_${EXAMPLE}"
    done
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Theora video codec library)
#
# Theora is Xiph.Org's first publicly released video codec, intended for use
# within the Foundation's Ogg multimedia streaming system
#
# Home page: https://theora.org/
# Download:  http://downloads.xiph.org/releases/theora/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
