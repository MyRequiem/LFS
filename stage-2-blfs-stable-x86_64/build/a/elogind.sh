#! /bin/bash

PRGNAME="elogind"

### elogind (logind extracted from systemd)
# elogind проекта systemd, извлеченный в отдельный автономный демон.
# Интегрируется с Linux PAM для отслеживания всех пользователей, вошедших в
# систему, и вошли ли они в систему графически, на консоли или удаленно. Эту
# информацию демон предоставляет через стандартный org.freedesktop.login1 D-Bus
# интерфейс.

# Required:    no
# Recommended: dbus         (runtime)
#              linux-pam
#              polkit       (runtime)
#              --- для сборки man-страниц ---
#              docbook-xml
#              docbook-xsl
#              libxslt
# Optional:    --- для тестов ---
#              python3-lxml
#              zsh
#              valgrind
#              audit-userspace (https://github.com/linux-audit/audit-userspace)
#              bash-completion (https://github.com/scop/bash-completion)
#              kexec           (https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kexec/)
#              selinux         (https://selinuxproject.org/page/Main_Page)

### Конфигурация ядра
#    CONFIG_CGROUPS=y
#    CONFIG_INOTIFY_USER=y
#    CONFIG_TMPFS=y
#    CONFIG_TMPFS_POSIX_ACL=y
#
# кроме того, для некоторых тестов требуется криптографическое API ядра
# пользовательского пространства
#    CONFIG_CRYPTO=y
#    CONFIG_CRYPTO_USER=m|y
#    CONFIG_CRYPTO_USER_API_HASH=m|y

###
# NOTE:
# для автозапуска демона добавляем в /etc/rc.d/rc.local
###
# start elogind
# if [ -x /usr/libexec/elogind ]; then
#     echo -n "  *   Starting elogind: /usr/libexec/elogind --daemon ..."
#     /usr/libexec/elogind --daemon && echo " [  OK  ]"
# fi

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# определяет, убиваются ли процессы пользователя, если он выходит из системы.
# Значение по умолчанию 'true', но это не соответствует традиционному
# использованию мультиплексоров screen или tmux
#    -Ddefault-kill-user-processes=false
meson setup ..                            \
    --prefix=/usr                         \
    --buildtype=release                   \
    -D man=disabled                       \
    -D cgroup-controller=elogind          \
    -D dev-kvm-mode=0660                  \
    -D dbuspolicydir=/etc/dbus-1/system.d \
    -D default-kill-user-processes=false  \
    -D docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# /usr/lib/pkgconfig/
#    libsystemd.pc -> libelogind.pc
ln -sfv  libelogind.pc "${TMP_DIR}/usr/lib/pkgconfig/libsystemd.pc"

# /usr/include/
#    systemd -> elogind/
ln -sfvn elogind "${TMP_DIR}/usr/include/systemd"

### Конфигурация
#    /etc/elogind/logind.conf

LOGIND_CONF="/etc/elogind/logind.conf"
# не убиваем пользовательские процессы, если он выходит из системы
sed -e '/\[Login\]/a KillUserProcesses=no' -i "${TMP_DIR}${LOGIND_CONF}"

if [ -f "${LOGIND_CONF}" ]; then
    mv "${LOGIND_CONF}" "${LOGIND_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${LOGIND_CONF}"

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
