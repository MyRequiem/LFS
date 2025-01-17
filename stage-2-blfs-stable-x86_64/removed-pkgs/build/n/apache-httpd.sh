#! /bin/bash

PRGNAME="apache-httpd"
ARCH_NAME="httpd"

### Apache HTTPD (The Apache HTTP Server)
# Кроссплатформенный HTTP сервер. Поддерживается Linux, BSD, Mac OS, Microsoft
# Windows, Novell NetWare, BeOS

# Required:    apr-util
#              pcre2
# Recommended: no
# Optional:    brotli
#              doxygen
#              libxml2
#              lua
#              lynx или links или elinks (http://elinks.or.cz/)
#              nghttp2
#              openldap
#              rsync
#              berkeley-db               (https://www.oracle.com/database/technologies/related/berkeleydb.html)
#              distcache                 (https://sourceforge.net/projects/distcache/)

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

# патч исправляет пути для специфики blfs и настраивает правильные разрешения
# на установленные файлы и каталоги
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-blfs_layout-1.patch" || exit 1

# заставим утилиту apxs использовать абсолютные пути для модулей
sed '/dir.*CFG_PREFIX/s@^@#@' -i support/apxs.in || exit 1

sed -e '/HTTPD_ROOT/s:${ap_prefix}:/etc/httpd:'       \
    -e '/SERVER_CONFIG_FILE/s:${rel_sysconfdir}/::'   \
    -e '/AP_TYPES_CONFIG_FILE/s:${rel_sysconfdir}/::' \
    -i configure || exit 1

./configure                                         \
    --enable-authnz-fcgi                            \
    --enable-layout=BLFS                            \
    --enable-mods-shared="all cgi"                  \
    --enable-mpms-shared=all                        \
    --enable-suexec=shared                          \
    --with-apr=/usr/bin/apr-1-config                \
    --with-apr-util=/usr/bin/apu-1-config           \
    --with-suexec-bin=/usr/lib/httpd/suexec         \
    --with-suexec-caller=apache                     \
    --with-suexec-docroot=/srv/www                  \
    --with-suexec-logfile=/var/log/httpd/suexec.log \
    --with-suexec-uidmin=100                        \
    --with-suexec-userdir=public_html || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}"/{run,var/run}

mv -v        "${TMP_DIR}/usr/sbin/suexec" "${TMP_DIR}/usr/lib/httpd/suexec"
chgrp apache "${TMP_DIR}/usr/lib/httpd/suexec"
chmod 4754   "${TMP_DIR}/usr/lib/httpd/suexec"

chown -v -R apache:apache "${TMP_DIR}/srv/www"

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
