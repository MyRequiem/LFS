#! /bin/bash

PRGNAME="ffmpeg"

### FFmpeg (software to record, convert and stream audio and video)
# Ведущий мультимедийный фреймворк, способный декодировать, кодировать,
# перекодировать, мультиплексировать, демультиплексировать, транслировать,
# фильтровать и воспроизводить практически все форматы аудио и видео. Также
# поддерживает самые неизвестные и древние форматы.

# Required:    no
# Recommended: libaom
#              libass
#              fdk-aac
#              freetype
#              lame
#              libvorbis
#              libvpx
#              opus
#              x264
#              x265
#              nasm или yasm
#              alsa-lib
#              libva
#              sdl2
#              libvdpau
#              libvdpau-va-gl
# Optional:    doxygen
#              fontconfig
#              fribidi
#              frei0r-plugins
#              libcdio
#              libdrm
#              libjxl
#              libwebp
#              opencv
#              openjpeg
#              gnutls
#              pulseaudio
#              samba
#              speex
#              texlive или install-tl-unx (для документации в формате pdf и ps)
#              v4l-utils
#              vulkan-loader
#              xvid
#              Graphical Environments
#              dav1d                      (https://code.videolan.org/videolan/dav1d)
#              flite                      (https://github.com/festvox/flite)
#              gsm                        (https://www.quut.com/gsm/)
#              libaacplus                 (https://tipok.org.ua/node/17j)
#              libbluray                  (https://www.videolan.org/developers/libbluray.html)
#              libcaca                    (https://github.com/cacalabs/libcaca)
#              libcelt                    (https://gitlab.xiph.org/xiph/celt)
#              libdc1394                  (https://sourceforge.net/projects/libdc1394/)
#              libdca                     (https://www.videolan.org/developers/libdca.html)
#              libiec61883                (https://archive.kernel.org/oldwiki/ieee1394.wiki.kernel.org/index.php/Libraries.html)
#              libilbc                    (https://github.com/TimothyGu/libilbc)
#              libmodplug                 (https://sourceforge.net/projects/modplug-xmms/)
#              libnut                     (https://github.com/Distrotech/libnut)
#              librtmp                    (https://rtmpdump.mplayerhq.hu/)
#              libssh                     (https://www.libssh.org/)
#              libtheora                  (https://www.theora.org/)
#              openal                     (https://openal.org/)
#              opencore-amr               (https://sourceforge.net/projects/opencore-amr/)
#              srt                        (https://github.com/Haivision/srt)
#              schroedinger               (https://sourceforge.net/projects/schrodinger/)
#              twolame                    (https://www.twolame.org/)
#              vo-aaenc                   (https://sourceforge.net/projects/opencore-amr/files/vo-aacenc/)
#              vo-amrwbenc                (https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/)
#              zvbi                       (https://zapping.sourceforge.net/ZVBI/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOC_DIR}"

# применим патч, который добавляет API, необходимый для сборки некоторых
# пакетов (например chromium)
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-chromium_method-1.patch" || exit 1

# добавляем библиотеку ALSA в переменную LDFLAGS и включаем обнаружение Flite
sed -i 's/-lflite"/-lflite -lasound"/' configure || exit 1

./configure                         \
    --prefix=/usr                   \
    --enable-gpl                    \
    --enable-version3               \
    --enable-nonfree                \
    --disable-static                \
    --enable-shared                 \
    --disable-debug                 \
    --enable-libaom                 \
    --enable-libass                 \
    --enable-libfdk-aac             \
    --enable-libfreetype            \
    --enable-libmp3lame             \
    --enable-libopus                \
    --enable-libvorbis              \
    --enable-libvpx                 \
    --enable-libx264                \
    --enable-libx265                \
    --enable-openssl                \
    --ignore-tests=enhanced-flv-av1 \
    --docdir="${DOC_DIR}" || exit 1

make || exit 1

# создает утилиту qt-faststart, которая умеет изменять фильмы в формате
# QuickTime (.mov или .mp4), для того, чтобы заголовочная информация находилася
# в начале файла, а не в конце. Это позволяет начать воспроизведение файла
# фильма до того, как весь файл будет прочитан.
gcc tools/qt-faststart.c -o tools/qt-faststart || exit 1

make install DESTDIR="${TMP_DIR}"
install -v -m755 tools/qt-faststart "${TMP_DIR}/usr/bin"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (software to record, convert and stream audio and video)
#
# FFmpeg is the leading multimedia framework, able to decode, encode,
# transcode, mux, demux, stream, filter and play pretty much anything that
# humans and machines have created. It supports the most obscure ancient
# formats up to the cutting edge. It includes libavcodec, the leading
# audio/video codec library.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
