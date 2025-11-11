#! /bin/bash

PRGNAME="vlc"

### VLC (VLC media player)
# Медиаплеер, стример и кодер/декодер

# Required:    no
# Recommended: alsa-lib
#              desktop-file-utils
#              ffmpeg
#              liba52
#              libgcrypt
#              libmad
#              lua
#              Graphical Environments
# Optional:    dbus
#              libidn
#              libssh2
#              --- Дополнительные плагины ввода ---
#              libarchive
#              libcddb
#              libdv
#              libdvdcss
#              libdvdread
#              libdvdnav
#              libproxy
#              opencv
#              samba
#              v4l-utils
#              libbluray                (https://www.videolan.org/developers/libbluray.html)
#              libdc1394                (https://sourceforge.net/projects/libdc1394/)
#              libnfs                   (https://github.com/sahlberg/libnfs)
#              libraw1394               (https://sourceforge.net/projects/libraw1394/)
#              live555                  (http://www.live555.com/)
#              vcdimager                (https://www.gnu.org/software/vcdimager/)
#              --- Дополнительные плагины мультиплексора/демультиплексора ---
#              libogg
#              game-music-emu           (https://github.com/kode54/Game_Music_Emu)
#              libdvbpsi                (https://www.videolan.org/developers/libdvbpsi.html)
#              libshout                 (https://downloads.xiph.org/releases/libshout/)
#              libmatroska              (https://dl.matroska.org/downloads/libmatroska/)
#              libmodplug               (https://sourceforge.net/projects/modplug-xmms/)
#              musepack                 (https://www.musepack.net/)
#              sidplay-libs             (https://sourceforge.net/projects/sidplay2/)
#              --- Дополнительные плагины кодеков ---
#              faad2
#              flac
#              libaom
#              libass
#              libmpeg2
#              libpng
#              libva
#              libvorbis
#              opus
#              speex
#              libvpx
#              x264
#              aribb24                  (https://github.com/nkoriyama/aribb24)
#              dav1d                    (https://code.videolan.org/videolan/dav1d)
#              dirac                    (https://sourceforge.net/projects/dirac/)
#              fluidlite                (https://github.com/divideconcept/FluidLite)
#              fluidsynth               (https://sourceforge.net/projects/fluidsynth/)
#              libdca                   (https://www.videolan.org/developers/libdca.html)
#              libkate                  (https://wiki.xiph.org/index.php/OggKate)
#              libtheora                (https://www.theora.org/)
#              openmax                  (https://www.khronos.org/openmax/)
#              schroedinger             (https://sourceforge.net/projects/schrodinger/)
#              shine                    (https://github.com/toots/shine)
#              sox                      (https://sourceforge.net/p/soxr/wiki/Home/)
#              tremor                   (https://wiki.xiph.org/Tremor)
#              twolame                  (https://www.twolame.org/)
#              zapping-vbi              (https://sourceforge.net/projects/zapping/)
#              --- Дополнительные видеоплагины ---
#              aalib
#              fontconfig
#              freetype
#              fribidi
#              libplacebo
#              librsvg
#              libvdpau
#              sdl12-compat
#              libcaca                  (https://github.com/cacalabs/libcaca)
#              libmfx                   (https://github.com/Intel-Media-SDK/MediaSDK)
#              --- Дополнительные аудио плагины ---
#              pulseaudio
#              libsamplerate
#              spatialaudio             (https://github.com/videolabs/libspatialaudio)
#              jack                     (https://jackaudio.org/)
#              --- Дополнительные плагины интерфейса ---
#              freerdp
#              libtar                   (https://repo.or.cz/w/libtar.git/)
#              libvncclient             (https://libvnc.github.io/)
#              lirc                     (https://www.lirc.org/)
#              --- Дополнительные плагины визуализации и видеофильтров ---
#              goom                     (https://sourceforge.net/projects/goom/)
#              libvsxu                  (https://www.vsxu.com/)
#              projectm                 (https://sourceforge.net/projects/projectm/)
#              --- Дополнительные плагины обнаружения служб ---
#              avahi
#              libmtp                   (https://sourceforge.net/projects/libmtp/)
#              libupnp                  (https://sourceforge.net/projects/pupnp/)
#              --- Добполнительные опции ---
#              gnutls
#              libnotify
#              libxml2
#              protobuf
#              taglib
#              xdg-utils                (runtime)
#              atmolight                (https://www.team-mediaportal.com/extensions/mp2-plugins/atmolight)
#              libmicrodns              (https://github.com/videolabs/libmicrodns)
#              srt                      (https://github.com/Haivision/srt)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему сборки с taglib>=2.0 и ffmpeg>=7
patch -Np1 -i "${SOURCES}/vlc-3.0.21-taglib-1.patch"         || exit 1
patch -Np1 -i "${SOURCES}/vlc-3.0.21-fedora_ffmpeg7-1.patch" || exit 1

BUILDCC=gcc       \
./configure       \
    --prefix=/usr \
    --disable-nfs \
    --disable-libplacebo || exit 1

make || exit 1
# make check
make docdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

gtk-update-icon-cache -qtf /usr/share/icons/hicolor
update-desktop-database -q

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (VLC media player)
#
# VLC is a media player, streamer, and encoder. It can play from many inputs,
# such as files, network streams, capture devices, desktops, or DVD, SVCD, VCD,
# and audio CD. It can use most audio and video codecs (MPEG 1/2/4, H264, VC-1,
# DivX, WMV, Vorbis, AC3, AAC, etc.), and it can also convert to different
# formats and/or send streams through the network.
#
# Home page: https://www.videolan.org/
# Download:  https://download.videolan.org/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
