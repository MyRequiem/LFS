#! /bin/bash

PRGNAME="openssh"

### OpenSSH (Secure Shell daemon and clients)
# Основной инструмент для безопасного удаленного управления компьютером и
# передачи файлов по шифрованным каналам.

# Required:    no
# Recommended: no
# Optional:    gdb                      (для тестов)
#              linux-pam
#              Graphical Environments
#              mit-kerberos-v5
#              net-tools                (runtime)
#              sysstat                  (runtime)
#              libedit                  (https://www.thrysoee.dk/editline)
#              libressl                 (http://www.libressl.org/)
#              opensc                   (https://github.com/OpenSC/OpenSC/wiki)
#              libsectok                (http://www.citi.umich.edu/projects/smartcard/sectok.html)

### Конфиги:
#    /etc/ssh/ssh_config
#    /etc/ssh/sshd_config
#    ~/.ssh/*

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}${MAN}"

# Каталог /var/lib/sshd должен существовать в системе.
install -v -g sys -m700 -d /var/lib/sshd
install -v -g sys -m700 -d "${TMP_DIR}/var/lib/sshd"

# Добавим группу sshd, если не существует.
! grep -qE "^sshd:" /etc/group  && \
    groupadd -g 50 sshd

# Добавим пользователя sshd, если не существует.
! grep -qE "^sshd:" /etc/passwd && \
    useradd -c 'sshd PrivSep' \
            -d /var/lib/sshd  \
            -g sshd           \
            -s /bin/false     \
            -u 50 sshd

./configure                                  \
    --prefix=/usr                            \
    --sysconfdir=/etc/ssh                    \
    --with-privsep-path=/var/lib/sshd        \
    --with-default-path=/usr/bin             \
    --with-superuser-path=/usr/sbin:/usr/bin \
    --with-pid-dir=/run                      \
    --without-pam || exit 1

make || exit 1
# make -j1 tests
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# /usr/bin/ssh-copy-id
install -v -m755 contrib/ssh-copy-id "${TMP_DIR}/usr/bin"
# Man-страница.
install -v -m644 contrib/ssh-copy-id.1 "${TMP_DIR}${MAN}"

# Для запуска SSH сервера при старте системы добавим скрипт инициализации в
# /etc/rc.d/init.d/ и ссылки в /etc/rc.d/rc{0-6}.d/
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-sshd DESTDIR="${TMP_DIR}"
)

SSH_CONFIG="/etc/ssh/ssh_config"
SSHD_CONFIG="/etc/ssh/sshd_config"

if [ -f "${SSH_CONFIG}" ]; then
    mv "${SSH_CONFIG}" "${SSH_CONFIG}.old"
fi

if [ -f "${SSHD_CONFIG}" ]; then
    mv "${SSHD_CONFIG}" "${SSHD_CONFIG}.old"
fi

# Остановим демон, если запущен (переустанавливаем пакет).
if [ -x /etc/rc.d/init.d/sshd ]; then
    /etc/rc.d/init.d/sshd stop
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SSH_CONFIG}"
config_file_processing "${SSHD_CONFIG}"

/etc/rc.d/init.d/sshd start

# Создадим новые хост-ключи /etc/ssh/ssh_host_*, если они еще не существуют:
! compgen -G "/etc/ssh/ssh_host_*" &>/dev/null && ssh-keygen -A

cp /etc/ssh/ssh_host_* "${TMP_DIR}/etc/ssh"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Secure Shell daemon and clients)
#
# ssh (Secure Shell) is a program for logging into a remote machine and for
# executing commands on a remote machine. It is intended to replace rlogin and
# rsh, and provide secure encrypted communications between two untrusted hosts
# over an insecure network. sshd (SSH Daemon) is the daemon program for ssh.
#
# Home page: https://www.${PRGNAME}.com/
# Download:  https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
