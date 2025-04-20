#! /bin/bash

PRGNAME="pulseaudio"

### PulseAudio (PulseAudio sound server)
# Кроссплатформенный звуковой сервер, созданный в качестве улучшенной замены
# таких серверов как ESD (Enlightened Sound Daemon), ARts. Сервер принимает
# звук от одного или нескольких источников (процессов или устройств) и
# направляет одному или нескольким приёмникам (звуковым платам, серверам
# PulseAudio или процессам). Одной из основных целей проекта является
# предоставление возможности перенаправления любых звуковых потоков, включая и
# потоки от процессов, требующих прямого доступа к аудиоустройствам (например,
# старая OSS)

# Required:    libsndfile
# Recommended: alsa-lib
#              dbus
#              elogind
#              glib
#              speex
#              xorg-libraries
# Optional:    avahi
#              bluez
#              doxygen
#              fftw
#              gtk+3
#              libsamplerate
#              sbc                     (поддержка bluetooth)
#              valgrind
#              jack                    (https://jackaudio.org/)
#              libasyncns              (https://0pointer.de/lennart/projects/libasyncns/)
#              lirc                    (https://www.lirc.org/)
#              orc                     (https://gstreamer.freedesktop.org/src/orc/)
#              soxr                    (https://sourceforge.net/projects/soxr/)
#              tdb                     (https://tdb.samba.org/)
#              webrtc-audio-processing (https://freedesktop.org/software/pulseaudio/webrtc-audio-processing/)

### Конфигурация
#    /etc/pulse/daemon.conf
#    /etc/pulse/client.conf
#    /etc/pulse/default.pa
#    ~/.config/pulse/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D database=gdbm    \
    -D doxygen=false    \
    -D bluez5=disabled  \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

if [ -d "${TMP_DIR}/lib" ]; then
    (
        cd "${TMP_DIR}" || exit 1
        mv lib/* usr/lib
        rm -rf lib
    )
fi

# запуск pulseaudio как общесистемного демона возможен, но не рекомендуется,
# поэтому удалим файл конфигурации D-Bus для общесистемного демона, чтобы
# избежать создания ненужных системных пользователей и групп
rm -f "${TMP_DIR}/usr/share/dbus-1/system.d/pulseaudio-system.conf"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PulseAudio sound server)
#
# PulseAudio is a sound system for POSIX OSes, meaning that it is a proxy for
# sound applications. It allows you to do advanced operations on your sound
# data as it passes between your application and your hardware. Things like
# transferring the audio to a different machine, changing the sample format or
# channel count and mixing several sounds into one are easily achieved using a
# sound server.
#
# Home page: http://www.${PRGNAME}.org
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
