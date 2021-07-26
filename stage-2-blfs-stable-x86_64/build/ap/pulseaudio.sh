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
#              libcap
#              speex
#              xorg-libraries
# Optional:    avahi
#              bluez
#              fftw
#              gconf
#              gtk+3
#              libsamplerate
#              sbc                     (поддержка bluetooth)
#              valgrind
#              jack                    (https://jackaudio.org/)
#              libasyncns              (http://0pointer.de/lennart/projects/libasyncns/)
#              lirc                    (https://www.lirc.org/)
#              orc                     (https://gstreamer.freedesktop.org/src/orc/)
#              soxr                    (https://sourceforge.net/projects/soxr/)
#              tdb                     (https://tdb.samba.org/)
#              webrtc-audio-processing (https://freedesktop.org/software/pulseaudio/webrtc-audio-processing/)

### Конфигурация
#    /etc/pulse/daemon.conf
#    /etc/pulse/client.conf
#    /etc/pulse/default.pa
#    ~/.config/pulse

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

BLUEZ="false"

command -v dbus-daemon  &>/dev/null && \
    command -v sbcdec   &>/dev/null && \
    command -v bluemoon &>/dev/null && \
    BLUEZ="true"

mkdir build
cd build || exit 1

meson               \
    --prefix=/usr   \
    -Ddatabase=gdbm \
    -Dbluez5="${BLUEZ}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# запуск pulseaudio как общесистемного демона возможен, но не рекомендуется
rm -fv "${TMP_DIR}/etc/dbus-1/system.d/${PRGNAME}-system.conf"

CLIENT_CONF="/etc/pulse/client.conf"
if [ -f "${CLIENT_CONF}" ]; then
    mv "${CLIENT_CONF}" "${CLIENT_CONF}.old"
fi

DAEMON_CONF="/etc/pulse/daemon.conf"
if [ -f "${DAEMON_CONF}" ]; then
    mv "${DAEMON_CONF}" "${DAEMON_CONF}.old"
fi

DEFAULT_PA="/etc/pulse/default.pa"
if [ -f "${DEFAULT_PA}" ]; then
    mv "${DEFAULT_PA}" "${DEFAULT_PA}.old"
fi

SYSTEM_PA="/etc/pulse/system.pa"
if [ -f "${SYSTEM_PA}" ]; then
    mv "${SYSTEM_PA}" "${SYSTEM_PA}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${CLIENT_CONF}"
config_file_processing "${DAEMON_CONF}"
config_file_processing "${DEFAULT_PA}"
config_file_processing "${SYSTEM_PA}"

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
