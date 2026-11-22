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
#              v4l-utils
#              --- Дополнительные плагины мультиплексора/демультиплексора ---
#              libogg
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
#              libvpx
#              x264
#              --- Дополнительные видеоплагины ---
#              aalib
#              fontconfig
#              freetype
#              fribidi
#              gst-plugins-base
#              libplacebo               (в текущей версии не работает, сломан)
#              librsvg
#              --- Дополнительные аудио плагины ---
#              pulseaudio
#              libsamplerate
#              --- Добполнительные опции ---
#              gnutls
#              libxml2
#              protobuf
#              taglib
#              xdg-utils                (runtime)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Включаем aalib, смотрим видео прямо в консоли в виде ASCII-символов (^_^).
# В Иксах: $ vlc -V aa /path/to/video.mp4
# В TTY:   $ vlc -I dummy -V aa /path/to/video.mp4
# (пример см. $ aafire)
#    --enable-aa
# Отключаем Network File System (сетевая файловая система).
#    --disable-nfs
# Отключаем RTSP и камеры.
#    --disable-live555
# Забыли про видеодиски из 90-х.
#    --disable-vcd
# Отключаем поиск названий треков для аудио-CD.
#    --disable-libcddb
# Отключаем ненужный VNC-клиент.
#    --disable-vnc
# Отключаем Remote Desktop Protocol, подключаться к рабочему столу Windows не
# собираюсь.
#    --disable-freerdp
# Убираем поддержку кинотеатральных пакетов.
#    --disable-asdcp
# Отключаем декодер спутниковых/эфирных таблиц.
#    --disable-dvbpsi
# Обходим стороной сломанную библиотеку libplacebo.
#    --disable-libplacebo
# Отключаем программную постобработку изображений. В современных форматах
# (H.264, H.265/HEVC, VP9, AV1) алгоритмы сглаживания уже встроены прямо внутрь
# самого кодека на аппаратном уровне.
#    --disable-postproc
# Отключаем встроенный магазин расширений.
#    --disable-addonmanagermodules
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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses,kde4}

# Оставляем только vlc.desktop
rm -f "${TMP_DIR}/usr/share/applications/vlc-"*

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
