#! /bin/bash

PRGNAME="mpv"

### mpv (a movie player based on MPlayer and mplayer2)
# Кроссплатформенный медиаплеер на основе MPlayer/mplayer2

# Required:    python3
#              aom
#              libdvdnav
#              libcdio
#              libass
#              libwebp
#              x264
#              x265
#              sdl2
#              python3-docutils
#              ffmpeg
#              libplacebo
#              lua
#              mujs
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cp "${SOURCES}/waf-"* .
mv ./waf-* waf
chmod 744 waf

./waf configure                 \
    --prefix=/usr               \
    --enable-cdda               \
    --enable-sdl2               \
    --enable-dvbin              \
    --enable-dvdnav             \
    --sysconfdir=/etc           \
    --enable-manpage-build      \
    --enable-libmpv-shared      \
    --confdir="/etc/${PRGNAME}" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

./waf build || exit 1
./waf --destdir="${TMP_DIR}" install

(
    cd "${TMP_DIR}/usr/share/" || exit 1
    rm -rf doc
)

ENCODING_PROFILES_CONF="/etc/${PRGNAME}/encoding-profiles.conf"
if [ -f "${ENCODING_PROFILES_CONF}" ]; then
    mv "${ENCODING_PROFILES_CONF}" "${ENCODING_PROFILES_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${ENCODING_PROFILES_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a movie player based on MPlayer and mplayer2)
#
# mpv is a fork of mplayer2 and MPlayer. It shares some features with the
# former projects while introducing many more. It supports a wide variety of
# video file formats, audio and video codecs, and subtitle types.
#
# Home page: https://${PRGNAME}.io/
#            https://github.com/${PRGNAME}-player/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}-player/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#            https://waf.io/waf-2.0.20
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
