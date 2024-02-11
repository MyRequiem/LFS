#! /bin/bash

PRGNAME="elogind"

### elogind (logind extracted from systemd)
# elogind проекта systemd, извлеченный в отдельный автономный демон.
# Интегрируется с Linux PAM для отслеживания всех пользователей, вошедших в
# систему, и вошли ли они в систему графически, на консоли или удаленно. Эту
# информацию демон предоставляет через стандартный org.freedesktop.login1 D-Bus
# интерфейс.

# Required:    dbus
# Recommended: linux-pam
#              polkit
#              --- для сборки man-страниц ---
#              docbook-xml
#              docbook-xsl
#              libxslt
# Optional:    --- для тестов ---
#              lxml
#              gobject-introspection
#              zsh
#              valgrind
#              audit-userspace (https://github.com/linux-audit/audit-userspace)
#              bash-completion (https://github.com/scop/bash-completion)
#              kexec           (https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kexec/)
#              selinux         (https://selinuxproject.org/page/Main_Page)

### Конфигурация ядра
#    CONFIG_CGROUPS=y
#    CONFIG_INOTIFY_USER=y
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
#    if [ -x /usr/lib/elogind/elogind ]; then
#       echo "Starting elogind..."
#       /usr/lib/elogind/elogind --daemon
#    fi

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# позволим собирать пакет без установленного polkit
! command -v pkaction &>/dev/null && \
    sed -i '/Disable polkit/,+8 d' meson.build || exit 1

# позволим демону elogind завершить работу, когда он отключается от dbus
# (например, когда dbus killed)
sed '/request_name/i\
r = sd_bus_set_exit_on_disconnect(m->bus, true);\
if (r < 0)\
    return log_error_errno(r, "Failed to set exit on disconnect: %m");' \
    -i src/login/logind.c || exit 1

mkdir build
cd build || exit 1

MAN="false"
if [ -d /usr/share/xml/docbook/xml-dtd-* ]; then
    if [ -d /usr/share/xml/docbook/xsl-stylesheets-nons-* ]; then
        command -v xslt-config &>/dev/null && MAN="true"
    fi
fi

PAM="false"
[ -x /usr/lib/libpam.so ] && PAM="true"

# определяет, убиваются ли процессы пользователя, если он выходит из системы.
# Значение по умолчанию 'true', но это не соответствует традиционному
# использованию мультиплексоров screen или tmux
#    -Ddefault-kill-user-processes=false
meson                                               \
    --prefix=/usr                                   \
    --buildtype=release                             \
    -Dcgroup-controller=elogind                     \
    -Ddbuspolicydir=/etc/dbus-1/system.d            \
    -Ddefault-kill-user-processes=false             \
    -Dpam="${PAM}"                                  \
    -Dacl=true                                      \
    -Dman="${MAN}"                                  \
    -Dhtml=false                                    \
    -Ddocdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

ninja
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

# если используется Linux PAM
if [[ "${PAM}" == "true" ]]; then
    PAM_SYSTEM_SESSION="/etc/pam.d/system-session"
    if ! grep -q "elogind addition" "${PAM_SYSTEM_SESSION}"; then
        cat << EOF >> "${PAM_SYSTEM_SESSION}"

# Begin elogind addition

session  required    pam_loginuid.so
session  optional    pam_elogind.so

# End elogind addition
EOF
    fi

    ELOGIND_USER="/etc/pam.d/elogind-user"
    cat << EOF > "${TMP_DIR}${ELOGIND_USER}"
# Begin ${ELOGIND_USER}

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

# End ${ELOGIND_USER}
EOF
fi

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
