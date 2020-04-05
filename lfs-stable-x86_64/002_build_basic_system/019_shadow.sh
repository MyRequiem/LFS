#! /bin/bash

PRGNAME="shadow"

### Shadow
# Пакет содержит программы для безопасной работы с паролями

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/shadow.html

# Home page: https://github.com/shadow-maint/shadow/
# Download:  https://github.com/shadow-maint/shadow/releases/download/4.7/shadow-4.7.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

# отключим установку программы 'groups' и ее man-страниц, так как пакет
# Coreutils предоставляет лучшую версию. Также отменим установку ман-страниц,
# которые уже были установлены вместе с пакетом man-pages
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

# вместо использования DES метода шифрования паролей (по умолчанию) будем
# использовать более безопасный метод SHA-512, который также позволяет
# использовать пароли длиной более 8 символов. Также необходимо изменить
# устаревшее местоположение /var/spool/mail для пользовательских почтовых
# ящиков, которые Shadow использует по умолчанию, на /var/mail, используемое в
# LFS
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs

### Примечание
# Если нам нужно будет принудительно использовать надежные пароли для
# пользователей, обратимся к
# http://www.linuxfromscratch.org/blfs/view/9.0/postlfs/cracklib.html
# для установки CrackLib до сборки Shadow. Затем нужно будет изменить
# etc/login.defs
# sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs
# и добавить параметр конфигурации --with-libcrack

# сделаем первый номер группы, сгенерированный useradd == 100, а не 1000:
sed -i 's/1000/100/' etc/useradd

# максимальная длина имени пользователя или группы 32 символа
#    --with-group-name-max-length=32
./configure           \
    --sysconfdir=/etc \
    --with-group-name-max-length=32 || exit 1

make || exit 1

# бэкапим конфиг /etc/default/useradd если он уже существует
USERADD="/etc/default/useradd"
if [ -f "${USERADD}" ]; then
    mv "${USERADD}" "${USERADD}.old"
fi

# этот пакет не поставляется с тестовым набором, поэтому сразу его установим
make install

config_file_processing "${USERADD}"

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

# переместим программу passwd из /usr/bin/ в /bin/
mv -v /usr/bin/passwd /bin
mkdir -pv "${TMP_DIR}/bin"
mv -v "${TMP_DIR}/usr/bin/passwd" "${TMP_DIR}/bin/"

# ==================================
# Конфигурация Shadow
# ==================================
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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
