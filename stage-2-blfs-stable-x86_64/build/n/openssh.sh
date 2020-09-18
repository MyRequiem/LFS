#! /bin/bash

PRGNAME="openssh"

### OpenSSH (Secure Shell daemon and clients)
# Набор программ, предоставляющих шифрование сеансов связи по компьютерным
# сетям с использованием протокола SSH

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/openssh.html

# Home page: http://www.openssh.com/
# Download:  http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.2p1.tar.gz

# Required: no
# Optional: gdb (для тестов)
#           linux-pam
#           xauth
#           mit-kerberos-v5
#           libedit (https://www.thrysoee.dk/editline)
#           libressl (http://www.libressl.org/)
#           opensc (https://github.com/OpenSC/OpenSC/wiki)
#           libsectok (http://www.citi.umich.edu/projects/smartcard/sectok.html)
#           openjdk
#           net-tools
#           sysstat

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}"{"${DOCS}",${MAN},/var/lib/sshd}

install -v -m700 -d /var/lib/sshd
chown   -v root:sys /var/lib/sshd

# добавим группу sshd, если не существует
! grep -qE "^sshd:" /etc/group  && \
    groupadd -g 50 sshd

# добавим пользователя sshd, если не существуют
! grep -qE "^sshd:" /etc/passwd && \
    useradd -c 'sshd PrivSep' \
            -d /var/lib/sshd  \
            -g sshd           \
            -s /bin/false     \
            -u 50 sshd

LIBEDIT="--without-libedit"
PAM="--without-pam"
XAUTH="--without-xauth"
KERBEROS5="--without-kerberos5"

[ -x /usr/lib/libedit.so ] && LIBEDIT="--with-libedit"
command -v pam_tally   &>/dev/null && PAM="--with-pam"
command -v xauth       &>/dev/null && XAUTH="--with-xauth=/usr/bin/xauth"
command -v krb5-config &>/dev/null && KERBEROS5="--with-kerberos5=/usr"

# использовать пароли MD5
#    --with-md5-passwords
./configure               \
    --prefix=/usr         \
    --sysconfdir=/etc/ssh \
    --with-md5-passwords  \
    "${LIBEDIT}"          \
    "${PAM}"              \
    "${XAUTH}"            \
    "${KERBEROS5}"        \
    --with-privsep-path=/var/lib/sshd || exit 1

make || exit 1

# для выполнения тестов требуется установленная утилита 'scp', поэтому
# скопируем ее в /usr/bin, если она не существует (openssh устанавливается в
# первый раз)
if ! [ -e /usr/bin/scp ]; then
    cp scp /usr/bin
fi

# make tests

make install
make install DESTDIR="${TMP_DIR}"

cp -v /etc/ssh/* "${TMP_DIR}/etc/ssh/"

# /usr/bin/ssh-copy-id
install -v -m755    contrib/ssh-copy-id /usr/bin
install -v -m755    contrib/ssh-copy-id "${TMP_DIR}/usr/bin"

# man-страницы
install -v -m644    contrib/ssh-copy-id.1 "${MAN}"
install -v -m644    contrib/ssh-copy-id.1 "${TMP_DIR}${MAN}"

# документация
install -v -m755 -d "${DOCS}"
install -v -m644    INSTALL LICENCE OVERVIEW README* "${DOCS}"
install -v -m644    INSTALL LICENCE OVERVIEW README* "${TMP_DIR}${DOCS}"

# для запуска SSH сервера при старте системы добавим скрипт инициализации в
# /etc/rc.d/init.d/ и ссылки в /etc/rc.d/rc{0-6}.d/
(
    cd /root/blfs-bootscripts || exit 1
    make install-sshd
    make install-sshd DESTDIR="${TMP_DIR}"
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Secure Shell daemon and clients)
#
# ssh (Secure Shell) is a program for logging into a remote machine and for
# executing commands on a remote machine. It is intended to replace rlogin and
# rsh, and provide secure encrypted communications between two untrusted hosts
# over an insecure network. sshd (SSH Daemon) is the daemon program for ssh.
#
# Home page: http://www.openssh.com/
# Download:  http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
