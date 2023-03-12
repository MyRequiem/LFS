#! /bin/bash

PRGNAME="shadow"

### Shadow (shadow password suite)
# Пакет содержит программы для безопасной работы с паролями

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
ETC_DEFAULT="/etc/default"
mkdir -pv "${TMP_DIR}${ETC_DEFAULT}"

# отключим установку программы 'groups' и ее man-страниц, так как пакет
# Coreutils предоставляет лучшую версию этой утилиты. Также отменим установку
# ман-страниц, которые уже были установлены вместе с пакетом man-pages
sed -i 's/groups$(EXEEXT) //' src/Makefile.in || exit 1
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

# вместо использования DES метода шифрования паролей (по умолчанию) будем
# использовать более безопасный метод SHA-512, который также позволяет
# использовать пароли длиной более 8 символов. Также необходимо изменить
# устаревшее местоположение /var/spool/mail для пользовательских почтовых
# ящиков, которые Shadow использует по умолчанию, на /var/mail, используемое в
# LFS
sed -e 's:#ENCRYPT_METHOD.*:ENCRYPT_METHOD SHA512:'        \
    -e 's@#\(SHA_CRYPT_..._ROUNDS 5000\)@\100@'            \
    -e 's:MAIL_DIR.*:MAIL_DIR /var/mail:'                  \
    -e 's:/var/spool/mail:/var/mail:'                      \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                     \
    -e 's:FAIL_DELAY.*:FAIL_DELAY 0:'                      \
    -e 's:FAILLOG_ENAB.*:FAILLOG_ENAB no:'                 \
    -e 's:LASTLOG_ENAB.*:LASTLOG_ENAB no:'                 \
    -e 's:MAIL_CHECK_ENAB.*:MAIL_CHECK_ENAB no:'           \
    -e 's:OBSCURE_CHECKS_ENAB.*:OBSCURE_CHECKS_ENAB no:'   \
    -e 's:PORTTIME_CHECKS_ENAB.*:PORTTIME_CHECKS_ENAB no:' \
    -e 's:QUOTAS_ENAB.*:QUOTAS_ENAB no:'                   \
    -e 's:SYSLOG_SU_ENAB.*:SYSLOG_SU_ENAB no:'             \
    -e 's:SYSLOG_SG_ENAB.*:SYSLOG_SG_ENAB no:'             \
    -e 's:PASS_ALWAYS_WARN.*:PASS_ALWAYS_WARN no:'         \
    -i etc/login.defs || exit 1

### Примечание
# Если мы хотим принудительно использовать надежные пароли, то в системе должен
# быть установлен пакет cracklib, который описан в blfs:
#    http://www.linuxfromscratch.org/blfs/view/stable/postlfs/cracklib.html
# После его установки нужно пересобрать shadow с параметром конфигурации
#    --with-libcrack
# а так же внести изменения в etc/login.defs
# sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs

# /usr/bin/passwd должен существовать перед сборкой, потому что его
# расположение жестко закодировано в некоторых утилитах пакета
PASSWD="/usr/bin/passwd"
! [ -r "${PASSWD}" ] && touch "${PASSWD}"

# максимальная длина имени пользователя или группы 32 символа
#    --with-group-name-max-length=32
./configure           \
    --sysconfdir=/etc \
    --disable-static  \
    --with-group-name-max-length=32 || exit 1

make || make -j1 || exit 1
# пакет не имеет тестового набора
make exec_prefix=/usr install DESTDIR="${TMP_DIR}"
make -C man install-man DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

###
# Конфигурация
###

# создадим файл /etc/default/useradd
mkdir -p "${ETC_DEFAULT}"
useradd -D --gid 999
# /etc/default/useradd содержит параметр CREATE_MAIL_SPOOL=yes, который
# заставляет утилиту useradd создать файл почтового ящика для вновь созданного
# пользователя. Отключим создание почтовых ящиков:
sed -i '/MAIL/s/yes/no/' "${ETC_DEFAULT}/useradd" || exit 1
cp "${ETC_DEFAULT}/useradd" "${TMP_DIR}${ETC_DEFAULT}"

# на утилиту 'passwd' установим suid бит, чтобы любой пользователь мог ее
# запустить с правами владельца (root). Необходимо, чтобы пользователь сам мог
# менять свой пароль.
chmod 4711 "/usr/bin/passwd"

# включим теневые пароли
pwconv
# включим теневые групповые пароли
grpconv

# установим пароль для суперпользователя
passwd root

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (shadow password suite)
#
# This set of login related programs utilizes an alternate, non-readable file
# to contain the actual encrypted passwords. This is presumed to increase
# system security by increasing the difficulty with which system crackers
# obtain encrypted passwords. Also package provides 'login', which is needed to
# log into the system.
#
# Home page: https://github.com/shadow-maint/${PRGNAME}/
# Download:  https://github.com/shadow-maint/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
