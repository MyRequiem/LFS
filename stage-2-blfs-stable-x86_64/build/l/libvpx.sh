#! /bin/bash

PRGNAME="libvpx"

### libvpx (VP8/VP9 video codec)
# Видеокодеки для интернета. Отвечают за сжатие и воспроизведение популярных
# форматов видео, используемых на сайтах (WebM).

# Required:    no
# Recommended: yasm или nasm
#              which            (для поиска yasm или nasm во время конфигурации)
# Optional:    curl             (скачивает необходимые файлы для тестов)
#              doxygen          (для документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# при обновлении пакета до новой версии, обновим временные метки всех файлов,
# чтобы система сборки не сохранила файлы из старого пакета
# shellcheck disable=SC2038,SC2185
find -type f | xargs touch

# обновление безопасности
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-security_fix-1.patch" || exit 1

# сохраняем владельца и разрешения при копировании файлов
sed -i 's/cp -p/cp/' build/make/Makefile || exit 1

mkdir libvpx-build
cd libvpx-build || exit 1

../configure        \
    --prefix=/usr   \
    --enable-shared \
    --disable-static || exit 1

make || exit 1

# набор тестов загружает несколько файлов как часть процесса тестирования,
# поэтому необходимо подключение к сети Internet
# LD_LIBRARY_PATH=. make test

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
