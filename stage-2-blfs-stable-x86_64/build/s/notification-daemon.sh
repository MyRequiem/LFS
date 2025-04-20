#! /bin/bash

PRGNAME="notification-daemon"

### notification-daemon (isplays passive pop-up notifications)
# Предоставляет стандартный способ уведомлений в виде пассивного всплывающего
# окна на рабочем столе не прерывая работу пользователя, которое может
# автоматически исчезать через некоторое время.

# Required:    gtk+3
#              libcanberra (должен быть собран с поддержкой gtk+3)
# Recommended: no
# Optional:    no

### NOTE:
# Протестировать демон уведомлений можно с помощью утилиты 'notify-send' (пакет
# libnotify)
#    $ pgrep -l notification-da && \
#       notify-send -i info Information "Hi ${USER}, This is a Test"
#
# команда 'pgrep -l notification-da' добавлена чтобы убедиться, что запущен
# демон именно из этого пакета, а не другого (например демон из пакета
# xfce4-notifyd)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (isplays passive pop-up notifications)
#
# The Desktop Notifications framework provides a standard way of doing passive
# pop-up notifications on the Linux desktop. These are designed to notify the
# user of something without interrupting their work with a dialog box that they
# must close. Passive popups can automatically disappear after a short period
# of time.
#
# Home page: https://www.galago-project.org/specs/notification/index.php
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
