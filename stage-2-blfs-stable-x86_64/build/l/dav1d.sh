#! /bin/bash

PRGNAME="dav1d"

### dav1d (AV1 cross-platform decoder)
# Сверхбыстрый и легкий декодер видеофайлов нового формата AV1, созданный
# сообществом VideoLAN (авторами плеера VLC). Разработан с упором на
# максимальную скорость работы и позволяет плавно воспроизводить
# высококачественное AV1-видео даже на старых процессорах.

# Required:    no
# Recommended: nasm
# Optional:    xxhash    (https://xxhash.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..    \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (AV1 cross-platform decoder)
#
# dav1d is an AV1 cross-platform decoder, open-source, and focused on speed and
# correctness. The goal of this project is to provide a decoder for most
# platforms, and achieve the highest speed possible to overcome the temporary
# lack of AV1 hardware decoder. It supports all features from AV1, including
# all subsampling and bit-depth parameters.
#
# Home page: https://code.videolan.org/videolan/${PRGNAME}
# Download:  https://code.videolan.org/videolan/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
