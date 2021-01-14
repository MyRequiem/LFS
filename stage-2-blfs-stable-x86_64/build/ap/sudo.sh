#! /bin/bash

PRGNAME="sudo"

### Sudo (give limited root privileges to certain users)
# Программа для системного администрирования UNIX-систем, позволяющая
# делегировать те или иные привилегированные ресурсы пользователям с ведением
# протокола работы, т.е. предоставляет возможность пользователям выполнять
# команды от имени суперпользователя root либо других пользователей.

# Required:    no
# Recommended: no
# Optional:    linux-pam
#              mit-kerberos-v5
#              openldap
#              MTA  (dovecot или exim или postfix или sendmail)
#              afs  (http://www.openafs.org/)
#              fwtk (http://www.fwtk.org/)
#              opie (https://sourceforge.net/projects/opie/files/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

PAM="--without-pam"
OPENLDAP="--without-ldap"

command -v pam_tally &>/dev/null && PAM="--with-pam"
command -v ldapadd   &>/dev/null && OPENLDAP="--with-ldap"

# использовать переменную окружения EDITOR для visudo
#    --with-env-editor
./configure                                         \
    --prefix=/usr                                   \
    --libexecdir=/usr/lib                           \
    --with-secure-path                              \
    --with-all-insults                              \
    --with-env-editor                               \
    "${PAM}"                                        \
    "${OPENLDAP}"                                   \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    --with-passprompt="[sudo] password for %p: " || exit 1

make || exit 1

# тесты
#    # env LC_ALL=C make check 2>&1 | tee ../make-check.log
# проверим результаты
#    # grep failed ../make-check.log

make install DESTDIR="${TMP_DIR}"

(
    # ссылка в /usr/lib/sudo/
    #    libsudo_util.so.0 -> libsudo_util.so.0.0.0
    cd "${TMP_DIR}/usr/lib/sudo/" || exit 1
    ln -sfv libsudo_util.so.0.0.0 libsudo_util.so.0
)

# закомментируем строку 'root ALL=(ALL) ALL' в /etc/sudoers
SUDOERS="/etc/sudoers"
sed -e "s#^root ALL=(ALL) ALL#\# root ALL=(ALL) ALL#" -i "${TMP_DIR}${SUDOERS}"

### Конфигурация в /etc/sudoers.d/
SUDOERS_D_MYREQUIEM="/etc/sudoers.d/myrequiem"
cat << EOF > "${TMP_DIR}${SUDOERS_D_MYREQUIEM}"
# Begin ${SUDOERS_D_MYREQUIEM}

User_Alias TRUSTED = myrequiem
TRUSTED ALL = (ALL:ALL) NOPASSWD: ALL

%users ALL = NOPASSWD: /bin/mount,             \\
                       /bin/umount,            \\
                       /usr/bin/mkisofs,       \\
                       /usr/bin/cdrecord,      \\
                       /usr/bin/cdda2wav,      \\
                       /usr/bin/cdrdao,        \\
                       /usr/bin/dvd+rw-format, \\
                       /bin/kill

# End ${SUDOERS_D_MYREQUIEM}
EOF

chmod 440 "${TMP_DIR}${SUDOERS_D_MYREQUIEM}"

if [ -f "${SUDOERS}" ]; then
    mv "${SUDOERS}" "${SUDOERS}.old"
fi

if [ -f "${SUDOERS_D_MYREQUIEM}" ]; then
    mv "${SUDOERS_D_MYREQUIEM}" "${SUDOERS_D_MYREQUIEM}.old"
fi

rm -rf "${TMP_DIR}/run"
source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SUDOERS}"
config_file_processing "${SUDOERS_D_MYREQUIEM}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (give limited root privileges to certain users)
#
# 'sudo' is a command that allows users to execute some commands as root. The
# /etc/sudoers file (edited with 'visudo') specifies which users have access to
# sudo and which commands they can run. 'sudo' logs all its activities to
# /var/log/ so the system administrator can keep an eye on things
#
# Home page: https://www.sudo.ws/
# Download:  http://www.sudo.ws/dist/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
