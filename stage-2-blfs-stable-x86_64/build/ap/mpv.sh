#! /bin/bash

PRGNAME="mpv"

### mpv (a movie player based on MPlayer and mplayer2)
# Кроссплатформенный медиаплеер на основе MPlayer/mplayer2

# Required:    alsa-lib
#              ffmpeg
#              libass
#              libplacebo
#              mesa
#              pulseaudio
# Recommended: libjpeg-turbo
#              libva
#              libvdpau
#              luajit
#              uchardet
#              vulkan-loader
# Optional:    libdvdcss
#              libdvdread
#              libdvdnav
#              libbluray        (https://www.videolan.org/developers/libbluray.html)
#              pipewire
#              sdl2
#              jack             (https://jackaudio.org/)
#              openal           (https://openal.org/)
#              libcaca          (https://github.com/cacalabs/libcaca)
#              svgalib          (https://www.svgalib.org/)
#              --- для документации ---
#              python3-docutils

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим сборку с ffmpeg > 7.0
sed -i 's/AV_OPT_TYPE_CHANNEL_LAYOUT/AV_OPT_TYPE_CHLAYOUT/' \
    filters/f_lavfi.c || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D x11=enabled      \
    -D sdl2=enabled     \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

gtk-update-icon-cache -qtf /usr/share/icons/hicolor
update-desktop-database -q

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a movie player based on MPlayer and mplayer2)
#
# mpv is a fork of mplayer2 and MPlayer. It shares some features with the
# former projects while introducing many more. It supports a wide variety of
# video file formats, audio and video codecs, and subtitle types.
#
# Home page: https://${PRGNAME}.io/
# Download:  https://github.com/${PRGNAME}-player/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
