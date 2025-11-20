#! /bin/bash

PRGNAME="shadow"

### Shadow (shadow password suite)
# Пакет содержит программы для безопасной работы с паролями.

# Required:    linux-pam
# Recommended: no
# Optional:    libbsd       (https://libbsd.freedesktop.org/wiki/)
#              tcb          (https://www.openwall.com/tcb/)

### NOTE:
# Пакет уже установлен в LFS. После установки linux-pam пакет shadow нужно
# пересобрать и настроить для работы с PAM

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/pam.d"

# не устанавливаем утилиту groups (входит в состав пакета 'coreutils' и
# является предпочтительной)
# shellcheck disable=SC2016
sed -i 's/groups$(EXEEXT) //' src/Makefile.in                     || exit 1
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \; || exit 1

# не устанавливаем man-страницы getspnam.3 и passwd.5 (уже установлены с
# пакетом 'man-pages')
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; || exit 1
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \; || exit 1

# вместо использования DES метода шифрования паролей (по умолчанию) будем
# использовать более безопасный метод YESCRYPT, который также позволяет
# использовать пароли длиной более 8 символов. Также необходимо изменить
# устаревшее местоположение /var/spool/mail для пользовательских почтовых
# ящиков, которые Shadow использует по умолчанию, на /var/mail, используемое в
# LFS. Еще удалим /bin и /sbin из PATH, поскольку они являются символическими
# ссылками на свои аналоги в /usr
sed -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD YESCRYPT@' \
    -e 's@/var/spool/mail@/var/mail@'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs || exit 1

./configure           \
    --sysconfdir=/etc \
    --disable-static  \
    --without-libbsd  \
    --with-{b,yes}crypt || exit 1

make || exit 1
# пакет не имеет набора тестов

# предотвращаем установку поставляемых файлов конфигурации PAM в /etc/pam.d/
# мы создадим эти файлы конфигурации явно
#    pamddir=
make exec_prefix=/usr pamddir= install DESTDIR="${TMP_DIR}"
make -C man install-man DESTDIR="${TMP_DIR}"

###
# Конфигурация для работы с Linux-PAM
###

# Конфиги:
#    /etc/pam.d/* или как альтернатива /etc/pam.conf
#    /etc/login.defs
#    /etc/security/*

LOGIN_DEFS="/etc/login.defs"
for FUNCTION in FAIL_DELAY               \
                FAILLOG_ENAB             \
                LASTLOG_ENAB             \
                MAIL_CHECK_ENAB          \
                OBSCURE_CHECKS_ENAB      \
                PORTTIME_CHECKS_ENAB     \
                QUOTAS_ENAB              \
                CONSOLE MOTD_FILE        \
                FTMP_FILE NOLOGINS_FILE  \
                ENV_HZ PASS_MIN_LEN      \
                SU_WHEEL_ONLY            \
                PASS_CHANGE_TRIES        \
                PASS_ALWAYS_WARN         \
                CHFN_AUTH ENCRYPT_METHOD \
                ENVIRON_FILE
do
    sed -i "s/^${FUNCTION}/# &/" "${TMP_DIR}${LOGIN_DEFS}"
done

PAM_D_LOGIN="/etc/pam.d/login"
cat << EOF > "${TMP_DIR}${PAM_D_LOGIN}"
# Set failure delay before next prompt to 3 seconds
# auth      optional    pam_faildelay.so  delay=3000000
auth      optional    pam_faildelay.so  delay=0

# Check to make sure that the user is allowed to login
auth      requisite   pam_nologin.so

# Check to make sure that root is allowed to login Disabled by default. You
# will need to create /etc/securetty file for this module to function. See man
# 5 securetty
#auth      required    pam_securetty.so

# Additional group memberships - disabled by default
#auth      optional    pam_group.so

# include system auth settings
auth      include     system-auth

# check access for the user
account   required    pam_access.so

# include system account settings
account   include     system-account

# Set default environment variables for the user
session   required    pam_env.so

# Set resource limits for the user
session   required    pam_limits.so

# Display the message of the day - Disabled by default
#session   optional    pam_motd.so

# Check user's mail - Disabled by default
#session   optional    pam_mail.so      standard quiet

# include system session and password settings
session   include     system-session
password  include     system-password

EOF

PAM_D_PASSWD="/etc/pam.d/passwd"
cat << EOF > "${TMP_DIR}${PAM_D_PASSWD}"
password  include     system-password

EOF

PAM_D_SU="/etc/pam.d/su"
cat << EOF > "${TMP_DIR}${PAM_D_SU}"
# always allow root
auth      sufficient  pam_rootok.so

# Allow users in the wheel group to execute su without a password disabled by
# default
#auth      sufficient  pam_wheel.so trust use_uid

# include system auth settings
auth      include     system-auth

# limit su to users in the wheel group
# disabled by default
#auth      required    pam_wheel.so use_uid

# include system account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session settings
session   include     system-session

EOF

PAM_D_CHPASSWD="/etc/pam.d/chpasswd"
cat << EOF > "${TMP_DIR}${PAM_D_CHPASSWD}"
# always allow root
auth      sufficient  pam_rootok.so

# include system auth and account settings
auth      include     system-auth
account   include     system-account
password  include     system-password

EOF

PAM_D_NEWUSERS="/etc/pam.d/newusers"
sed -e s/chpasswd/newusers/ \
    "${TMP_DIR}${PAM_D_CHPASSWD}" > "${TMP_DIR}${PAM_D_NEWUSERS}"

CHAGE="/etc/pam.d/chage"
cat << EOF > "${TMP_DIR}${CHAGE}"
# always allow root
auth      sufficient  pam_rootok.so

# include system auth and account settings
auth      include     system-auth
account   include     system-account

EOF

for PROGRAM in chfn chgpasswd chsh groupadd groupdel \
        groupmems groupmod useradd userdel usermod ; do
            install -v -m644 "${TMP_DIR}/etc/pam.d/chage" \
                "${TMP_DIR}/etc/pam.d/${PROGRAM}"
            sed -i "s/chage/$PROGRAM/" "${TMP_DIR}/etc/pam.d/${PROGRAM}"
done

if [ -f "${LOGIN_DEFS}" ]; then
    mv "${LOGIN_DEFS}" "${LOGIN_DEFS}.old"
fi

if [ -f "${PAM_D_LOGIN}" ]; then
    mv "${PAM_D_LOGIN}" "${PAM_D_LOGIN}.old"
fi

if [ -f "${PAM_D_PASSWD}" ]; then
    mv "${PAM_D_PASSWD}" "${PAM_D_PASSWD}.old"
fi

if [ -f "${PAM_D_SU}" ]; then
    mv "${PAM_D_SU}" "${PAM_D_SU}.old"
fi

if [ -f "${PAM_D_CHPASSWD}" ]; then
    mv "${PAM_D_CHPASSWD}" "${PAM_D_CHPASSWD}.old"
fi

if [ -f "${PAM_D_NEWUSERS}" ]; then
    mv "${PAM_D_NEWUSERS}" "${PAM_D_NEWUSERS}.old"
fi

if [ -f "${CHAGE}" ]; then
    mv "${CHAGE}" "${CHAGE}.old"
fi

USERADD="/etc/default/useradd"
if [ -f "${USERADD}" ]; then
    mv "${USERADD}" "${USERADD}.old"
fi

LIMITS="/etc/limits"
if [ -f "${LIMITS}" ]; then
    mv "${LIMITS}" "${LIMITS}.old"
fi

LOGIN_ACCESS="/etc/login.access"
if [ -f "${LOGIN_ACCESS}" ]; then
    mv "${LOGIN_ACCESS}" "${LOGIN_ACCESS}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${LOGIN_DEFS}"
config_file_processing "${PAM_D_LOGIN}"
config_file_processing "${PAM_D_PASSWD}"
config_file_processing "${PAM_D_SU}"
config_file_processing "${PAM_D_CHPASSWD}"
config_file_processing "${PAM_D_NEWUSERS}"
config_file_processing "${CHAGE}"
config_file_processing "${USERADD}"
config_file_processing "${LIMITS}"
config_file_processing "${LOGIN_ACCESS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (shadow password suite)
#
# This set of login related programs utilizes an alternate, non-readable file
# to contain the actual encrypted passwords. This is presumed to increase
# system security by increasing the difficulty with which system crackers
# obtain encrypted passwords. Also package provides 'login', which is needed to
# log into the system
#
# Home page: https://github.com/${PRGNAME}-maint/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}-maint/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
