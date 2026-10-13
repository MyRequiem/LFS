#! /bin/bash

PRGNAME="elogind"

### elogind (logind extracted from systemd)
# Мастер управления сеансами. Следит за тем, кто зашел в систему, и дает
# программам разрешение на работу с оборудованием (звуком, видео) без участия
# громоздких систем.

# Required:    no
# Recommended: dbus               (runtime)
#              linux-pam          (для Xorg)
#              polkit             (runtime)
#              --- для сборки man-страниц ---
#              docbook-xml
#              docbook-xsl
#              libxslt
# Optional:    --- для тестов ---
#              python3-lxml
#              zsh
#              valgrind
#              audit-userspace    (https://github.com/linux-audit/audit-userspace)
#              bash-completion    (https://github.com/scop/bash-completion)
#              kexec              (https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kexec/)
#              selinux            (https://selinuxproject.org/page/Main_Page)

### Конфигурация ядра.
#    CONFIG_CGROUPS=y
#    CONFIG_INOTIFY_USER=y
#    CONFIG_TMPFS=y
#    CONFIG_TMPFS_POSIX_ACL=y
#
# Кроме того, для некоторых тестов требуется криптографическое API ядра
# пользовательского пространства.
#    CONFIG_CRYPTO=y
#    CONFIG_CRYPTO_USER=m|y
#    CONFIG_CRYPTO_USER_API_HASH=m|y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/pam.d"

mkdir build
cd build || exit 1

# В версии elogind-257.16 ошибка в синтаксисе XML файла мануала, поэтому
# отключаем генерацию man-страниц.
#    -D man=false
# Определяет, убиваются ли процессы пользователя, если он выходит из системы.
# Значение по умолчанию 'true', но это не соответствует традиционному
# использованию мультиплексоров screen или tmux.
#    -D default-kill-user-processes=false
meson setup ..                            \
    --prefix=/usr                         \
    --buildtype=release                   \
    -D man=false                          \
    -D cgroup-controller=elogind          \
    -D dev-kvm-mode=0660                  \
    -D dbuspolicydir=/etc/dbus-1/system.d \
    -D default-kill-user-processes=false  \
    -D default-hierarchy=unified          \
    -D docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# /usr/lib/pkgconfig/
#    libsystemd.pc -> libelogind.pc
ln -sfv  libelogind.pc "${TMP_DIR}/usr/lib/pkgconfig/libsystemd.pc"

# /usr/include/
#    systemd -> elogind/
ln -sfvn elogind "${TMP_DIR}/usr/include/systemd"

### Конфигурация.
#    /etc/elogind/logind.conf
#    /etc/elogind/sleep.conf

LOGIND_CONF="/etc/elogind/logind.conf"
# Не убиваем пользовательские процессы, если юзер выходит из системы.
sed -e '/\[Login\]/a KillUserProcesses=no' -i "${TMP_DIR}${LOGIND_CONF}"

SLEEP_CONF="/etc/elogind/sleep.conf"
echo "SuspendState=mem" >> "${TMP_DIR}${SLEEP_CONF}"

if [ -f "${LOGIND_CONF}" ]; then
    mv "${LOGIND_CONF}" "${LOGIND_CONF}.old"
fi

if [ -f "${SLEEP_CONF}" ]; then
    mv "${SLEEP_CONF}" "${SLEEP_CONF}.old"
fi

### Конфигурация Linux PAM
# /etc/pam.d/system-session принадлежит пакету linux-pam.
if ! grep -q pam_elogind.so /etc/pam.d/system-session ; then
    cat << EOF >> /etc/pam.d/system-session
session   required    pam_loginuid.so
session   optional    pam_elogind.so

EOF
fi

cat << EOF > "${TMP_DIR}/etc/pam.d/elogind-user"
account  required    pam_access.so
account  include     system-account

session  required    pam_env.so
session  required    pam_limits.so
session  required    pam_unix.so
session  required    pam_loginuid.so
session  optional    pam_keyinit.so force revoke
session  optional    pam_elogind.so

auth     required    pam_deny.so
password required    pam_deny.so

EOF

killall elogind-daemon 2>/dev/null
killall elogind 2>/dev/null

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${LOGIND_CONF}"
config_file_processing "${SLEEP_CONF}"

/usr/libexec/elogind --daemon

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (logind extracted from systemd)
#
# elogind is the systemd projects logind, extracted to a standalone package. It
# integrates with Linux PAM to track all the users logged in to a system, and
# whether they are logged in graphically, on the console, or remotely. Elogind
# exposes this information via the standard org.freedesktop.login1 D-Bus
# interface, and also through the file system using systemd's standard
# /run/systemd layout.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
