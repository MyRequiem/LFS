#! /bin/bash

PRGNAME="libvpx"

### libvpx (VP8/VP9 video codec)
# Пакет из проекта WebM представляющий собой реализации открытого видеокодека
# VP8, используемого в большинстве современных html5 видео, и кодека следующего
# поколения VP9. Данные кодеки первоначально разработаны On2 и выпущены как
# открытый исходный код от Google Inc. VP8 и VP9 являются преемниками кодека
# VP3, на котором был основан кодек Theora

# Required:    yasm или nasm
#              which            (для поиска yasm или nasm во время конфигурации)
# Recommended: no
# Optional:    curl             (скачивает необходимые файлы для тестов)
#              doxygen          (для документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сохраняем владельца и разрещения при копировании файлов
sed -i 's/cp -p/cp/' build/make/Makefile || exit 1

mkdir libvpx-build
cd libvpx-build || exit 1

../configure        \
    --prefix=/usr   \
    --enable-vp8    \
    --enable-vp9    \
    --enable-shared \
    --disable-static || exit 1

make || exit 1

# набор тестов загружает несколько файлов как часть процесса тестирования,
# поэтому необходимо подключение к сети Internet
# LD_LIBRARY_PATH=. make test

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (VP8/VP9 video codec)
#
# This package, from the WebM project, provides the reference implementations
# of the VP8 open video codec, used in most current html5 video, and of the
# next-generation VP9 codec, originally developed by On2 and released as open
# source by Google Inc. It is the successor of the VP3 codec, on which the
# Theora codec was based.
#
# Home page: https://www.webmproject.org/
# Download:  https://github.com/webmproject/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
