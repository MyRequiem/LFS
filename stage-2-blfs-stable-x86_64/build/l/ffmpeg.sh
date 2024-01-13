#! /bin/bash

PRGNAME="ffmpeg"

### FFmpeg (software to record, convert and stream audio and video)
# Ведущий мультимедийный фреймворк, способный декодировать, кодировать,
# перекодировать, мультиплексировать, демультиплексировать, транслировать,
# фильтровать и воспроизводить практически все форматы аудио и видео. Также
# поддерживает самые неизвестные и древние форматы.

# Required:    no
# Recommended: libass
#              fdk-aac
#              freetype
#              lame
#              libtheora
#              libvorbis
#              libvpx
#              opus
#              x264
#              x265
#              nasm
#              yasm
#              alsa-lib
#              libva
#              libvdpau
#              sdl2
# Optional:    doxygen
#              fontconfig
#              fribidi
#              frei0r-plugins
#              libcdio
#              libdrm
#              libwebp
#              opencv
#              openjpeg
#              gnutls
#              pulseaudio
#              samba
#              speex
#              texlive или install-tl-unx
#              v4l-utils
#              xvid
#              Graphical Environments
#              flite                      (http://www.speech.cs.cmu.edu/flite/)
#              gsm                        (http://www.quut.com/gsm/)
#              libaacplus                 (http://tipok.org.ua/node/17)
#              libbluray                  (http://www.videolan.org/developers/libbluray.html)
#              libcaca                    (http://caca.zoy.org/)
#              libcelt                    (https://gitlab.xiph.org/xiph/celt)
#              libdc1394                  (http://sourceforge.net/projects/libdc1394)
#              libdca                     (https://www.videolan.org/developers/libdca.html)
#              libiec61883                (https://ieee1394.wiki.kernel.org/index.php/Libraries)
#              libilbc                    (https://github.com/TimothyGu/libilbc)
#              libmodplug                 (https://sourceforge.net/projects/modplug-xmms/)
#              libnut                     (https://github.com/Distrotech/libnut)
#              librtmp                    (http://rtmpdump.mplayerhq.hu/)
#              libssh                     (https://www.libssh.org/)
#              openal                     (https://openal.org/)
#              opencore-amr               (https://sourceforge.net/projects/opencore-amr/)
#              schroedinger               (https://sourceforge.net/projects/schrodinger/)
#              twolame                    (https://www.twolame.org/)
#              vo-aaenc                   (https://sourceforge.net/projects/opencore-amr/files/vo-aacenc/)
#              vo-amrwbenc                (https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/)
#              zvbi                       (http://zapping.sourceforge.net/ZVBI/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOC_DIR}"

# добавляем библиотеку ALSA в переменную LDFLAGS и включаем обнаружение Flite
sed -i 's/-lflite"/-lflite -lasound"/' configure &&

./configure              \
    --prefix=/usr        \
    --enable-gpl         \
    --enable-version3    \
    --enable-nonfree     \
    --disable-static     \
    --enable-shared      \
    --disable-debug      \
    --enable-avresample  \
    --enable-libass      \
    --enable-libfdk-aac  \
    --enable-libfreetype \
    --enable-libmp3lame  \
    --enable-libopus     \
    --enable-libpulse    \
    --enable-libtheora   \
    --enable-libvorbis   \
    --enable-libvpx      \
    --enable-libdrm      \
    --enable-libx264     \
    --enable-libx265     \
    --enable-openssl     \
    --docdir="${DOC_DIR}" || exit 1

make || exit 1

# создает утилиту qt-faststart, которая умеет изменять фильмы в формате
# QuickTime (.mov или .mp4), для того, чтобы заголовочная информация находилася
# в начале файла, а не в конце. Это позволяет начать воспроизведение файла
# фильма до того, как весь файл будет прочитан.
gcc tools/qt-faststart.c -o tools/qt-faststart

make install DESTDIR="${TMP_DIR}"
install -v -m755 tools/qt-faststart "${TMP_DIR}/usr/bin"

# документация
install -v -m644 doc/*.txt "${TMP_DIR}${DOC_DIR}"

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
# Download:  http://${PRGNAME}.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
