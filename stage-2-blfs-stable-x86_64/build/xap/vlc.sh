#! /bin/bash

PRGNAME="vlc"

### VLC (VLC media player)
# Популярнейший универсальный медиаплеер, способный воспроизводить любые аудио
# и видеофайлы благодаря огромному набору встроенных кодеков. Также умеет
# транслировать и принимать потоковое вещание из интернета.

# Required:    no
# Recommended: alsa-lib
#              desktop-file-utils
#              ffmpeg
#              liba52
#              libgcrypt
#              libmad
#              lua
#              qt6
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
#              samba
#              v4l-utils
#              libbluray                (https://www.videolan.org/developers/libbluray.html)
#              libdc1394                (https://sourceforge.net/projects/libdc1394/)
#              libnfs                   (https://github.com/sahlberg/libnfs)
#              libraw1394               (https://sourceforge.net/projects/libraw1394/)
#              live555                  (http://www.live555.com/)
#              vcdimager                (требует libcdio) https://www.gnu.org/software/vcdimager/
#              --- Дополнительные плагины мультиплексора/демультиплексора ---
#              libogg
#              game-music-emu           (https://github.com/kode54/Game_Music_Emu)
#              libdvbpsi                (https://www.videolan.org/developers/libdvbpsi.html)
#              libshout                 (https://downloads.xiph.org/releases/libshout/)
#              libmatroska              (требует libebml https://dl.matroska.org/downloads/libebml/) https://dl.matroska.org/downloads/libmatroska/
#              libmodplug               (https://sourceforge.net/projects/modplug-xmms/)
#              musepack                 (https://www.musepack.net/)
#              sidplay-libs             (https://sourceforge.net/projects/sidplay2/)
#              --- Дополнительные плагины кодеков ---
#              dav1d
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
#              dirac                    (https://sourceforge.net/projects/dirac/)
#              fluidlite                (https://github.com/divideconcept/FluidLite)
#              fluidsynth               (https://sourceforge.net/projects/fluidsynth/)
#              libdca                   (https://www.videolan.org/developers/libdca.html)
#              libkate                  (https://wiki.xiph.org/index.php/OggKate)
#              libtheora                (https://www.theora.org/)
#              openmax                  (https://www.khronos.org/openmax/)
#              schroedinger             (https://sourceforge.net/projects/schrodinger/)
#              shine                    (https://github.com/toots/shine)
#              soxr                     (https://sourceforge.net/p/soxr/wiki/Home/)
#              tremor                   (https://wiki.xiph.org/Tremor)
#              twolame                  (https://www.twolame.org/)
#              zapping-vbi              (https://sourceforge.net/projects/zapping/)
#              --- Дополнительные видеоплагины ---
#              aalib
#              fontconfig
#              freetype
#              fribidi
#              gst-plugins-base
#              libplacebo               (в текущей версии не работает, сломан)
#              librsvg
#              libcaca                  (https://github.com/cacalabs/libcaca)
#              libmfx                   (https://github.com/Intel-Media-SDK/MediaSDK)
#              sdl12-compat             (https://github.com/libsdl-org/sdl12-compat)
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

# исправим ошибку сборки с последней версией gst-plugins-base
sed -i 's/gstvideopool.h/video.h/' \
    modules/codec/gstreamer/gstvlcvideopool.h || exit 1

# --enable-aa
#    включаем aalib, смотрим фильмы прям в консоли в виде ASCII-символов (^_^)
#    $ vlc -V aa /path/to/film.mp4 - в Иксах
#    $ vlc -I dummy -V aa /path/to/film.mp4 - в TTY
#    (пример см. $ aafire)
# --disable-nfs
#    отключаем Network File System (сетевая файловая система)
# --disable-live555
#    отключаем RTSP и камеры
# --disable-vcd
#    забыли про видеодиски из 90-х
# --disable-libcddb
#    отключаем поиск названий треков для аудио-CD
# --disable-vnc
#    отключаем ненужный VNC-клиент
# --disable-freerdp
#    отключаем Remote Desktop Protocol, подключаться к рабочему столу Windows
#    не собираюсь
# --disable-asdcp
#    убираем поддержку кинотеатральных пакетов
# --disable-dvbpsi
#    отключаем декодер спутниковых/эфирных таблиц
# --disable-libplacebo
#    обходим стороной сломанную библиотеку libplacebo
# --disable-postproc
#    отключаем программную постобработку изображений, в современных форматах
#    (H.264, H.265/HEVC, VP9, AV1) алгоритмы сглаживания уже встроены прямо
#    внутрь самого кодека на аппаратном уровне
# --disable-addonmanagermodules
#    отключаем встроенный магазин расширений
BUILDCC=gcc              \
./configure              \
    --prefix=/usr        \
    --enable-aa          \
    --disable-nfs        \
    --disable-live555    \
    --disable-vcd        \
    --disable-libcddb    \
    --disable-vnc        \
    --disable-freerdp    \
    --disable-asdcp      \
    --disable-dvbpsi     \
    --disable-libplacebo \
    --disable-postproc   \
    --disable-addonmanagermodules || exit 1

make || exit 1
# make check
make docdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
