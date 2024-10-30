#! /bin/bash

PRGNAME="php"

### PHP (HTML-embedded scripting language)
# Скриптовый язык общего назначения, интенсивно применяемый для разработки
# веб-приложений

# Required:    apache-httpd
#              libxml2
# Recommended: no
# Optional:    ---------------------------------------
#              Optional System Utilities and Libraries
#              ---------------------------------------
#              aspell
#              enchant
#              libxslt
#              dovecot или exim или postfix или sendmail
#              pcre2
#              pth
#              apparmor          (https://wiki.ubuntu.com/AppArmor)
#              dmalloc           (https://dmalloc.com/)
#              net-snmp          (http://www.net-snmp.org/)
#              oniguruma         (https://github.com/kkos/oniguruma)
#              ossp-mm           (http://www.ossp.org/pkg/lib/mm/)
#              re2c              (https://re2c.org/)
#              xmlrpc-epi        (https://xmlrpc-epi.sourceforge.net/main.php)
#              ---------------------------------------
#              Optional Graphics Utilities and Libraries
#              ---------------------------------------
#              freetype
#              libexif
#              libjpeg-turbo
#              libpng
#              libtiff
#              libwebp
#              Graphical Environments
#              fdf-toolkit       (https://opensource.adobe.com/dc-acrobat-sdk-docs/acrobatsdk/)
#              libgd             (https://github.com/libgd/libgd)
#              t1lib             (https://www.t1lib.org/)
#              ---------------------------------------
#              Optional Web Utilities
#              ---------------------------------------
#              curl
#              tidy-html5
#              caudium           (https://sourceforge.net/projects/caudium/)
#              hyperwave         (https://www.hyperwave.com/en/)
#              mnogosearch       (http://www.mnogosearch.org/)
#              roxen-webserver   (https://download.roxen.com/6.1/)
#              wddx              (https://github.com/Bilal-S/WDDX.net)
#              ---------------------------------------
#              Optional Data Management Utilities and Libraries
#              ---------------------------------------
#              berkeley-db
#              libiodbc
#              lmdb
#              mariadb или mysql (https://www.mysql.com/)
#              openldap
#              postgresql
#              sqlite
#              unixodbc
#              adabas            (https://www.softwareag.com/en_corporate/platform/adabas-natural.html)
#              birdstep          (https://raima.com/product-overview/)
#              cdb               (https://cr.yp.to/cdb.html)
#              dbmaker           (https://www.dbmaker.com/)
#              empress           (http://www.empress.com/)
#              frontbase         (http://www.frontbase.com/cgi-bin/WebObjects/FBWebSite)
#              ibm-db2           (https://www.ibm.com/db2)
#              mini-sql          (https://hughestech.com.au/products/msql/)
#              monetra           (https://www.monetra.com/)
#              qdbm              (https://sourceforge.net/projects/qdbm/)
#              ---------------------------------------
#              Optional Security/Encryption Utilities and Libraries
#              ---------------------------------------
#              cyrus-sasl
#              mit-kerberos-v5
#              libmcrypt         (https://mcrypt.sourceforge.net/)
#              mhash             (https://mhash.sourceforge.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# для сборки и установки во временной директории (DESTDIR) должен существовать
# файл /etc/httpd/httpd.conf
mkdir -p "${TMP_DIR}/etc/httpd"
cat /etc/httpd/original/httpd.conf > "${TMP_DIR}/etc/httpd/httpd.conf"

./configure                                \
    --prefix=/usr                          \
    --sysconfdir=/etc                      \
    --localstatedir=/var                   \
    --datadir=/usr/share/php               \
    --mandir=/usr/share/man                \
    --with-pear                            \
    --with-apxs2=/usr/bin/apxs             \
    --enable-fpm                           \
    --with-fpm-user=apache                 \
    --with-fpm-group=apache                \
    --with-config-file-path=/etc           \
    --with-zlib                            \
    --with-bz2                             \
    --enable-bcmath                        \
    --enable-calendar                      \
    --enable-dba=shared                    \
    --with-gdbm                            \
    --with-gmp                             \
    --enable-ftp                           \
    --with-gettext                         \
    --enable-mbstring                      \
    --disable-mbregex                      \
    --with-readline                        \
    --enable-tokenizer                     \
    --enable-pcntl                         \
    --with-mysqli=shared                   \
    --with-layout=PHP                      \
    --disable-sigchild                     \
    --enable-xml                           \
    --enable-simplexml                     \
    --enable-xmlreader=shared              \
    --enable-dom                           \
    --enable-filter                        \
    --disable-debug                        \
    --with-openssl                         \
    --with-curl                            \
    --enable-ctype                         \
    --with-db4                             \
    --enable-exif                          \
    --with-iconv                           \
    --with-imap-ssl                        \
    --with-ldap                            \
    --with-iodbc                           \
    --enable-pdo                           \
    --with-pspell                          \
    --with-enchant                         \
    --enable-shmop=shared                  \
    --enable-soap                          \
    --enable-sockets                       \
    --with-sqlite3                         \
    --enable-sysvmsg                       \
    --enable-sysvsem                       \
    --enable-sysvshm                       \
    --with-xsl                             \
    --enable-intl                          \
    --enable-opcache                       \
    --enable-shared=yes                    \
    --enable-static=no                     \
    --with-gnu-ld                          \
    --with-pic                             \
    --enable-phpdbg                        \
    --with-pgsql=shared,/usr               \
    --with-pdo-pgsql=shared,/usr           \
    --with-pdo-mysql=shared                \
    --with-pdo-sqlite                      \
    --with-pdo-odbc=shared,iODBC,/usr      \
    --with-config-file-scan-dir=/etc/php.d \
    --with-mysql-sock=/run/mysqld/mysqld.sock || exit 1

make || exit 1

# несколько тестов могут потерпеть неудачу, и в этом случае задается вопрос
# "хотите ли вы отправить отчет PHP-разработчикам?". Если мы хотим
# автоматизировать процесс тестирования, будем на все вопросы ответчать 'n'
# yes "n" | make test

make install INSTALL_ROOT="${TMP_DIR}"

# PHP при установке иногда помещает мусор в корневой каталог, удалим его
rm -rf "${TMP_DIR}"/{.channels,.registry,.depdb,.depdblock,.filemap,.lock}

# удалим ранее созданный /etc/httpd/httpd.conf во временном каталоге
rm -f "${TMP_DIR}/etc/httpd/httpd.conf"*

# удалим /run (монтируется в tmpfs) и /var во временной директории
(
    cd "${TMP_DIR}" || exit 1
    rm -rf run var
)

# init script: /etc/rc.d/init.d/php-fpm
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-php DESTDIR="${TMP_DIR}"
)

# конфиги
PHP_INI="/etc/php.ini"
install -v -m644 php.ini-production "${TMP_DIR}${PHP_INI}"

PEAR_CONF="/etc/pear.conf"
PHP_FPM_CONF="/etc/php-fpm.conf"
PHP_FPM_CONF_DEFAULT="/etc/php-fpm.conf.default"
WWW_CONF="/etc/php-fpm.d/www.conf"
WWW_CONF_DEFAULT="/etc/php-fpm.d/www.conf.default"

cat "${TMP_DIR}${PHP_FPM_CONF_DEFAULT}" > "${TMP_DIR}${PHP_FPM_CONF}"
cat "${TMP_DIR}${WWW_CONF_DEFAULT}"     > "${TMP_DIR}${WWW_CONF}"

MOD_PHP_CONF="/etc/httpd/mod_php.conf"
cat << EOF > "${TMP_DIR}${MOD_PHP_CONF}"
#
# mod_php - PHP Hypertext Preprocessor module
#

# Load the PHP module
LoadModule php_module /usr/lib/httpd/modules/libphp.so

# Tell Apache to feed all *.php files through PHP
<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
EOF

# добавим в /etc/php.ini директиву
#    include_path = ".:/usr/lib/php"
sed -i 's@php/includes"@&\ninclude_path = ".:/usr/lib/php"@' \
    "${TMP_DIR}${PHP_INI}"

if [ -f "${PHP_INI}" ]; then
    mv "${PHP_INI}" "${PHP_INI}.old"
fi

if [ -f "${PEAR_CONF}" ]; then
    mv "${PEAR_CONF}" "${PEAR_CONF}.old"
fi

if [ -f "${PHP_FPM_CONF}" ]; then
    mv "${PHP_FPM_CONF}" "${PHP_FPM_CONF}.old"
fi

if [ -f "${PHP_FPM_CONF_DEFAULT}" ]; then
    mv "${PHP_FPM_CONF_DEFAULT}" "${PHP_FPM_CONF_DEFAULT}.old"
fi

if [ -f "${WWW_CONF}" ]; then
    mv "${WWW_CONF}" "${WWW_CONF}.old"
fi

if [ -f "${WWW_CONF_DEFAULT}" ]; then
    mv "${WWW_CONF_DEFAULT}" "${WWW_CONF_DEFAULT}.old"
fi

if [ -f "${MOD_PHP_CONF}" ]; then
    mv "${MOD_PHP_CONF}" "${MOD_PHP_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${PHP_INI}"
config_file_processing "${PEAR_CONF}"
config_file_processing "${PHP_FPM_CONF}"
config_file_processing "${PHP_FPM_CONF_DEFAULT}"
config_file_processing "${WWW_CONF}"
config_file_processing "${WWW_CONF_DEFAULT}"
config_file_processing "${MOD_PHP_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (HTML-embedded scripting language)
#
# PHP is the PHP Hypertext Preprocessor. It shares syntax characteristics with
# C, Java, and Perl. Primarily used in dynamic web sites, it allows for
# programming code to be directly embedded into the HTML markup. It is also
# useful as a general purpose scripting language.
#
# Home page: https://www.${PRGNAME}.net/
# Download:  https://www.${PRGNAME}.net/distributions/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
