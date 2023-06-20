#! /bin/bash

PRGNAME="alsa-utils"

### alsa-utils (Advanced Linux Sound Architecture utilities)
# Пакет содержит утилиты для использования с ALSA и управления звуковой картой:
#    alsactl       - управление настройками звуковой карты
#    arecord/aplay - захват и воспроизведение аудио
#    amixer        - консольный микшер
#    alsamixer     - консольный микшер на базе ncurses

# Required:    alsa-lib
# Recommended: no
# Optional:    python3-docutils
#              fftw
#              libsamplerate
#              xmlto
#              dialog (https://hightek.org/dialog/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# если установлен пакет 'fftw' собираем Basic Audio Tester (BAT)
FFTW="--disable-bat"
# для создания man-страниц
XMLTO="--disable-xmlto"

command -v fftw-wisdom &>/dev/null && FFTW="--enable-bat"
command -v xmlto       &>/dev/null && XMLTO="--enable-xmlto"

# отключаем создание конфигурации alsaconf, которая не совместима с Udev
#    --disable-alsaconf
# используем библиотеки ncurses для расширенных символов
#    --with-curses=ncursesw
./configure            \
    --disable-alsaconf \
    "${FFTW}"          \
    "${XMLTO}"         \
    --with-curses=ncursesw || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# ### Конфигурация:
#    - любых пользователей, использующих звуковые устройства нужно добавить в
#       группу audio
#           # usermod -a -G audio <username>
#
#    - по умолчанию все каналы звуковой карты отключены. Для включения
#       используем утилиту 'alsamixer'

# для автоматического сохранения и восстановления настроек громкости при
# перезагрузке системы установим загрузочный скрипт /etc/rc.d/init.d/alsa
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-alsa DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# при первом запуске утилиты 'alsactl' (обычно запускается из стандартного
# правила udev) будет жаловаться на отсутствие файла
#    /var/lib/alsa/asound.state
#  сразу создадим его:
alsactl -L store
cp /var/lib/alsa/asound.state "${TMP_DIR}/var/lib/alsa/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Advanced Linux Sound Architecture utilities)
#
# The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI
# functionality to the Linux operating system. This package contains command
# line audio utilities for use with ALSA and controlling your sound card:
#    alsactl       -  manage soundcard settings
#    arecord/aplay -  capture and play audio
#    amixer        -  adjust mixer settings from the command line
#    alsamixer     -  an ncurses-based console mixer
#
# Home page: https://alsa-project.org/wiki/Main_Page
# Download:  https://www.alsa-project.org/files/pub/utils/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
