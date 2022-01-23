#! /bin/bash

PRGNAME="apache-httpd"
ARCH_NAME="httpd"

### Apache HTTPD (The Apache HTTP Server)
# Кроссплатформенный HTTP сервер. Поддерживается Linux, BSD, Mac OS, Microsoft
# Windows, Novell NetWare, BeOS

# Required:    apr-util
#              pcre
# Recommended: no
# Optional:    brotli
#              berkeley-db
#              doxygen
#              libxml2
#              lua
#              lynx или links или elinks (http://elinks.or.cz/)
#              nghttp2
#              openldap
#              rsync
#              distcache (https://sourceforge.net/projects/distcache/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/config_file_processing.sh"               || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/lib/httpd"

# по соображениям безопасности запуск сервера apache в качестве демона должен
# производиться от пользователя apache входящего в группу apache
! grep -qE "^apache:" /etc/group  && \
    groupadd -g 25 apache

! grep -qE "^apache:" /etc/passwd && \
    useradd                \
        -c "Apache Server" \
        -d /srv/www        \
        -g apache          \
        -s /bin/false      \
        -u 25 apache

# адаптируем модуль Lua к изменениям API в Lua-5.4
sed -i 's/lua_resume(a, NULL, b)/lua_resume(a, NULL, b, NULL)/' \
    modules/lua/mod_lua.h || exit 1

# патч исправляет пути для специфики blfs и настраивает правильные разрешения
# на установленные файлы и каталоги
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-blfs_layout-1.patch" || exit 1

# заставим утилиту apxs использовать абсолютные пути для модулей
sed '/dir.*CFG_PREFIX/s@^@#@' -i support/apxs.in || exit 1

LDAP="--disable-ldap"
LDAP_AUTHNZ="--disable-authnz-ldap"

if command -v ldapadd &>/dev/null; then
    LDAP="--enable-ldap"
    LDAP_AUTHNZ="--enable-authnz-ldap"
fi

# аутентификация и авторизация на основе авторизатора FastCGI
# (модуль mod_authnz_fcgi.so fast CGI)
#    --enable-authnz-fcgi
#
# модули должны быть скомпилированы и использованы как динамические общие
# объекты (DSO), чтобы их можно было включать и исключать из сервера с помощью
# директив конфигурации во время выполнения
#    --enable-mods-shared="all cgi"
#
# все MPM (многопроцессорные модули) компилирутся как динамические общие
# объекты (DSO), поэтому пользователь может выбирать, какие из них использовать
# во время выполнения
#    --enable-mpms-shared=all
#
# включаем сборку модуля suEXEC, который можно использовать для разрешения
# пользователям запускать сценарии CGI и SSI под идентификаторами
# пользователей, отличными от ID пользователей вызывающего веб-сервера
#    --enable-suexec
#
# управление поведением модуля suEXEC, например корневым каталогом документов
# по умолчанию, минимальный UID, который можно использовать для запуска скрипта
# под suEXEC
#    --with-suexec-*
#
# помещаем оболочку suexec в нужное место
#    --with-suexec-bin=/usr/lib/httpd/suexec
./configure                                 \
    --enable-authnz-fcgi                    \
    --enable-layout=BLFS                    \
    --enable-mods-shared="all cgi"          \
    --enable-mpms-shared=all                \
    --enable-suexec=shared                  \
    --with-apr=/usr/bin/apr-1-config        \
    --with-apr-util=/usr/bin/apu-1-config   \
    --with-suexec-bin=/usr/lib/httpd/suexec \
    --with-suexec-caller=apache             \
    --with-suexec-docroot="/srv/www"        \
    --with-suexec-uidmin=100                \
    --with-suexec-userdir=public_html       \
    --enable-so                             \
    --enable-pie                            \
    --enable-cgi                            \
    --with-pcre                             \
    --enable-ssl                            \
    --enable-rewrite                        \
    --enable-vhost-alias                    \
    --enable-proxy                          \
    --enable-proxy-http                     \
    --enable-proxy-ftp                      \
    --enable-cache                          \
    --enable-mem-cache                      \
    --enable-file-cache                     \
    --enable-disk-cache                     \
    --enable-dav                            \
    --enable-dav-fs                         \
    "${LDAP}"                               \
    "${LDAP_AUTHNZ}"                        \
    --enable-authn-anon                     \
    --enable-authn-alias                    \
    --with-suexec-logfile="/var/log/httpd/suexec.log" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}"/var/run

mv -v "${TMP_DIR}/usr/sbin/suexec" "${TMP_DIR}/usr/lib/httpd/"
chgrp apache "${TMP_DIR}/usr/lib/httpd/suexec"
chmod 4754   "${TMP_DIR}/usr/lib/httpd/suexec"

# мануал перемещаем в /srv/www/ и оставляем только английский язык
mv "${TMP_DIR}/usr/share/httpd/manual" "${TMP_DIR}/srv/www/httpd-manual"
(
    cd "${TMP_DIR}/srv/www/httpd-manual" || exit 1
    HTMLS=$(find . -type f -name "*.html")
    for HTML in ${HTMLS} ; do
        if [ -f "${HTML}.en" ]; then
            cp "${HTML}.en" "${HTML}"
            rm -f "${HTML}."*
        fi
    done
)

chown -vR apache:apache "${TMP_DIR}/srv/www"

# init script: /etc/rc.d/init.d/httpd
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-httpd DESTDIR="${TMP_DIR}"
)

# конфиг
HTTPD_CONF="/etc/httpd/httpd.conf"

# дополним конфиг
cat << EOF >> "${TMP_DIR}${HTTPD_CONF}"
# Uncomment the following line to enable PHP
#Include /etc/httpd/mod_php.conf

# Uncomment the following lines (and mod_dav above) to enable svn support
#LoadModule dav_svn_module lib/httpd/modules/mod_dav_svn.so
#LoadModule authz_svn_module lib/httpd/modules/mod_authz_svn.so
EOF

if [ -f "${HTTPD_CONF}" ]; then
    mv "${HTTPD_CONF}" "${HTTPD_CONF}.old"
fi

INDEX_HTML="/srv/www/index.html"
if [ -f "${INDEX_HTML}" ]; then
    mv "${INDEX_HTML}" "${INDEX_HTML}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${HTTPD_CONF}"
config_file_processing "${INDEX_HTML}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Apache HTTP Server)
#
# The Apache HTTPD package contains an open-source HTTP server. It is useful
# for creating local intranet web sites or running huge web serving operations.
#
# Home page: https://www.apache.org/
# Download:  https://archive.apache.org/dist/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
