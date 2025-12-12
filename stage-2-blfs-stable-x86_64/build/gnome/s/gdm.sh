#! /bin/bash

PRGNAME="gdm"

### GDM (GNOME Display Manager)
# Дисплейный менеджер, который предоставляет графический интерфейс для входа в
# систему и управления сессиями пользователей в среде рабочего стола GNOME. Он
# отвечает за отображение экрана входа, аутентификацию пользователей и запуск
# выбранной графической среды, такой как Wayland или X11. GDM поддерживает
# различные функции, включая поддержку удаленных сеансов, настройку локали и
# раскладки клавиатуры, а также настройку внешнего вида экрана входа.

# Required:    accountsservice
#              dconf
#              libcanberra
#              linux-pam
#              --- runtime ---
#              gnome-session
#              gnome-shell
#              elogind
# Recommended: no
# Optional:    keyutils
#              check            (для тестов) https://libcheck.github.io/check/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# должны существовать группа и пользователь gdm, который сможет взять на себя
# управление демоном gdm после его запуска
! grep -qE "^gdm:" /etc/group  && \
    groupadd -g 21 gdm

! grep -qE "^gdm:" /etc/passwd && \
    useradd -c "GDM Daemon Owner" \
            -d /var/lib/gdm       \
            -g gdm                \
            -s /bin/false         \
            -u 21 gdm             &&
            passwd -ql gdm

# адаптируем сборку с GCC 15
sed -r 's/([(*])bool([) ])/\1boolval\2/' -i \
    common/gdm-settings-utils.* || exit 1

# изменим gdm-launch-environment.pam для нашей SySv системы
sed -e 's@systemd@elogind@'                                \
    -e 's/-session optional/-session required/'            \
    -e '/elogind/isession  required       pam_loginuid.so' \
    -i data/pam-lfs/gdm-launch-environment.pam || exit 1

mkdir build
cd build || exit 1

meson setup ..                 \
    --prefix=/usr              \
    --buildtype=release        \
    -D gdm-xsession=true       \
    -D initial-vt=7            \
    -D run-dir=/run/gdm        \
    -D logind-provider=elogind \
    -D systemd-journal=false   \
    -D systemdsystemunitdir=no \
    -D systemduserunitdir=no || exit 1

ninja || exit 1
# для тестов нужна утилита 'check', которая была удалена из LFS
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

###
# Конфигурация
#
# Демон GDM настраивается с помощью конфига
#    /etc/gdm/custom.conf
# Значения по умолчанию хранятся в GSettings в файле gdm.schemas. Пользователям
# рекомендуется изменить custom.conf, поскольку gdm.schemas будет перезаписан
# при обновлении пакета gdm
#
# В некоторых системах с графическими процессорами NVIDIA или виртуальными
# графическими процессорами (например, предоставляемыми qemu) GDM по умолчанию
# скрывает сеансы Wayland. Это часто делается для того, чтобы пользователи не
# столкнулись с проблемами с ошибочными драйверами, которые могут привести к
# зависаниям системы, сбоям приложений, проблемам с управлением питанием и
# замедлению работы графики. Если ваша система представляет собой виртуальную
# машину или у вас есть графический процессор NVIDIA и вы все равно хотите
# попробовать запустить сеансы Wayland, выполните следующую команду:
#    # ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
#
# Если установлено несколько дисплейных менеджеров, например sddm и gdm, то
# выбор менеджера, который будет использоваться при переходе на init 5
# указывается в /etc/sysconfig/xdm
###

# установим скрипт /etc/rc.d/init.d/xdm, который будет автоматически запускать
# GDM при переходе на уровень запуска 5 (init 5)
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-gdm DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# GDM приостанавливает работу системы, если экран приветствия некоторое время
# работает без какого-либо интерактивного ввода (Auto-Suspend). Отключим такое
# поведение:
su gdm -s /bin/bash                                                \
       -c "dbus-run-session                                        \
             gsettings set org.gnome.settings-daemon.plugins.power \
                           sleep-inactive-ac-type                  \
                           nothing"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Display Manager)
#
# GDM is a system service that is responsible for providing graphical logins
# and managing local and remote displays
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
