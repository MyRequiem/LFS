#! /bin/bash

PRGNAME="sddm"

### sddm (QML based X11 display manager)
# SDDM (Simple Desktop Display Manager) - дисплейный менеджер KDE Plasma для
# предоставления графического интерфейса входа в систему с запросом имени
# пользователя и пароля. Основан на Qt и QML

# Required:    cmake
#              extra-cmake-modules
#              qt6
# Recommended: python3-docutils         (для man-страниц)
#              linux-pam
#              upower
# Optional:    no

###
# Конфиг:
#    /etc/sddm.conf

### INFO
# SDDM должен выполняться на уровне запуска 5, однако уровень запуска по
# умолчанию равен 3 (см. /etc/inittab) Переход на уровень запуска 5 из
# терминала (от пользователя root) запускает загрузочный скрипт sddm
# /etc/rc.d/init.d/xdm , вызывая экран приветствия для выбора пользователя,
# Window Managers (WM) или Desktop Environments (DE). Список DE и WM (i3,
# Plasma, Gnome и т.д.) зависит от наличия файлов .desktop в
# /usr/share/xsessions и /usr/share/wayland-sessions. Большинство WM и DE
# автоматически предоставляют эти файлы, но при необходимости можно добавить
# собственные.
#    $ sudo init 5
#
# Можно в /etc/inittab поставить уровень запуска по умолчанию 5, что не всегда
# удобно
#    id:5:initdefault:
#
# Для запуска KDE с помощью xinit (командой startx) с уровня запуска 3 в файл
# ~/.xinitrc добавим:
#    export DESKTOP_SESSION=plasma
#    dbus-launch --exit-with-x11 /usr/bin/startplasma-x11
# или без ~/.xinitrc
#   $ startx /usr/bin/startplasma-x11

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/pam.d"

### должны существовать пользователь и группа sddm
! grep -qE "^sddm:" /etc/group  && \
    groupadd -g 64 sddm

! grep -qE "^sddm:" /etc/passwd && \
useradd -c "sddm Daemon"           \
        -d /var/lib/sddm           \
        -g sddm                    \
        -s /bin/false              \
        -u 64 sddm

mkdir build
cd build || exit 1

cmake                                                                \
    -D CMAKE_INSTALL_PREFIX=/usr                                     \
    -D CMAKE_BUILD_TYPE=Release                                      \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5                              \
    -D ENABLE_JOURNALD=OFF                                           \
    -D NO_SYSTEMD=ON                                                 \
    -D RUNTIME_DIR=/run/sddm                                         \
    -D USE_ELOGIND=ON                                                \
    -D BUILD_MAN_PAGES=ON                                            \
    -D BUILD_WITH_QT6=ON                                             \
    -D DATA_INSTALL_DIR=/usr/share/sddm                              \
    -D DBUS_CONFIG_FILENAME=sddm_org.freedesktop.DisplayManager.conf \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

install -v -dm755 -o sddm -g sddm "${TMP_DIR}/var/lib/sddm"

###
# Конфигурация Linux PAM
###

cat << EOF > "${TMP_DIR}/etc/pam.d/sddm"
auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password

session  required       pam_limits.so
session  include        system-session

EOF

cat << EOF > "${TMP_DIR}/etc/pam.d/sddm-autologin"
auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account

password required       pam_deny.so

session  required       pam_limits.so
session  include        system-session

EOF

cat << EOF > "${TMP_DIR}/etc/pam.d/sddm-greeter"
auth     required       pam_env.so
auth     required       pam_permit.so

account  required       pam_permit.so
password required       pam_deny.so
session  required       pam_unix.so
-session optional       pam_systemd.so

EOF

# установим загрузочный скрипт
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-sddm DESTDIR="${TMP_DIR}"
)

###
# WARNINIG
###
# Пакет устанавливает некоторые .qml файлы с префиксом ${QT6DIR}, т.е. в
# /opt/qt6 - ссылка на директорию qt6-x.x.x
#
# В данном случае эти файлы установлены в директорию DESTDIR/opt/qt6, поэтому
# при копировании директории DESTDIR/opt/qt6 в корень системы произойдет
# ошибка, т.к. существует ссылка /opt/qt6
#
# Переименуем DESTDIR/opt/qt6 в qt6-x.x.x
REAL_QT6DIR="/opt/$(readlink "${QT6DIR}")"
mv "${TMP_DIR}${QT6DIR}" "${TMP_DIR}${REAL_QT6DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# конфиг
/usr/bin/sddm --example-config > /etc/sddm.conf

# включим NumLock при загрузке
sed -i '/Numlock/s/none/on/'     /etc/sddm.conf
# уберем виртуальную клавиатуру (включена по умолчанию)
sed -i 's/qtvirtualkeyboard//'   /etc/sddm.conf

cp /etc/sddm.conf "${TMP_DIR}/etc/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (QML based X11 display manager)
#
# SDDM (Simple Desktop Display Manager) - a lightweight display manager based
# upon Qt and QML
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
