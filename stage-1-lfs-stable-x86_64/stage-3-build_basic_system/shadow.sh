#! /bin/bash

PRGNAME="shadow"

### Shadow (shadow password suite)
# Пакет содержит программы для безопасной работы с паролями

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/shadow.html

# Home page: https://github.com/shadow-maint/shadow/

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

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
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -i etc/login.defs || exit 1

### Примечание
# Если мы хотим принудительно использовать надежные пароли, то в системе должен
# быть установлен пакет cracklib, который описан в blfs:
#    http://www.linuxfromscratch.org/blfs/view/stable/postlfs/cracklib.html
# После его установки нужно пересобрать shadow с параметром конфигурации
#    --with-libcrack
# а так же внести изменения в etc/login.defs
# sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs

# сделаем первый номер группы, сгенерированный useradd был 1000, а не 1001
sed -i 's/1000/999/' etc/useradd

# /usr/bin/ passwd должен существовать перед сборкой, потому что его
# расположение жестко закодировано в некоторых утилитах пакета
PASSWD="/usr/bin/passwd"
! [ -r "${PASSWD}" ] && touch "${PASSWD}"

# максимальная длина имени пользователя или группы 32 символа
#    --with-group-name-max-length=32
./configure           \
    --sysconfdir=/etc \
    --with-group-name-max-length=32 || exit 1

make || make -j1 || exit 1

# пакет не имеет тестового набора

make install DESTDIR="${TMP_DIR}"

# конфиг /etc/default/useradd содержит параметр CREATE_MAIL_SPOOL=yes, который
# заставляет утилиту useradd создать файл почтового ящика для вновь созданного
# пользователя. Отключим создание почтовых ящиков:
USERADD="/etc/default/useradd"
sed -i 's/yes/no/' "${TMP_DIR}${USERADD}"

# бэкапим конфиг /etc/default/useradd если он уже существует
if [ -f "${USERADD}" ]; then
    mv "${USERADD}" "${USERADD}.old"
fi

/bin/cp -vR "${TMP_DIR}"/* /

config_file_processing "${USERADD}"

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
