#! /bin/bash

PRGNAME="ffmpeg"

### FFmpeg (software to record, convert and stream audio and video)
# Мощный универсальный набор инструментов для записи, конвертации и потоковой
# передачи практически всех форматов аудио и видео. Это главный цифровой
# комбайн системы, на котором держится работа большинства медиаплееров.

# Required:    no
# Recommended: dav1d
#              libaom
#              libass
#              fdk-aac
#              freetype
#              lame
#              libvorbis
#              libvpx
#              opus
#              x264
#              x265
#              nasm
#              --- for desktop use ---
#              alsa-lib
#              libva
#              sdl2-compat
# Optional:    fontconfig
#              fribidi
#              libdrm
#              libplacebo
#              libwebp
#              openjpeg
#              gnutls
#              pulseaudio
#              v4l-utils
#              vulkan-loader
#              xvid
#              Graphical Environments

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Применим патч, который добавляет API, необходимый для сборки некоторых
# пакетов (например chromium).
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-9.0.1-chromium_method-1.patch" || exit 1

./configure                                                 \
    --prefix=/usr                                           \
    --enable-gpl                                            \
    --enable-version3                                       \
    --enable-nonfree                                        \
    --disable-static                                        \
    --enable-shared                                         \
    --disable-debug                                         \
    --enable-libaom                                         \
    --enable-libass                                         \
    --enable-libfdk-aac                                     \
    --enable-libfreetype                                    \
    --enable-libmp3lame                                     \
    --enable-libopus                                        \
    --enable-libvorbis                                      \
    --enable-libvpx                                         \
    --enable-libx264                                        \
    --enable-libx265                                        \
    --enable-openssl                                        \
    --enable-libdav1d                                       \
    --disable-libsvtav1                                     \
    --ignore-tests=enhanced-flv-av1,enhanced-flv-multitrack \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# Создаем утилиту qt-faststart, которая умеет изменять фильмы в формате
# QuickTime (.mov или .mp4), для того, чтобы заголовочная информация находилась
# в начале файла, а не в конце. Это позволяет начать воспроизведение файла
# фильма до того, как весь файл будет прочитан.
gcc tools/qt-faststart.c -o tools/qt-faststart || exit 1

make install DESTDIR="${TMP_DIR}"
install -v -m755 tools/qt-faststart "${TMP_DIR}/usr/bin"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
