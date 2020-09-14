#! /bin/bash

PRGNAME="exim"
# версия info документации (exim-texinfo)
INFO_VERSION="4.71"

### Exim (the Exim MTA - Mail Transfer Agent)
# Представляет собой универсальный и гибкий почтовик с широкими возможностями
# для проверки входящей электронной почты, а так же может быть интегрирован с
# другими инструментами для работы с электронной почтой.

# http://www.linuxfromscratch.org/blfs/view/stable/server/exim.html

# Home page:  http://www.exim.org/
# Download:   https://ftp.exim.org/pub/exim/exim4/old/exim-4.93.tar.xz
# HTML-docs:  https://ftp.exim.org/pub/exim/exim4/old/exim-html-4.93.tar.xz
# Info Pages: https://ftp.exim.org/pub/exim/exim4/old/exim-texinfo-4.71.tar.bz2

# Required: libnsl
#           pcre
# Optional: cyrus-sasl
#           libidn
#           linux-pam
#           mariadb or mysql (https://www.mysql.com/)
#           postgresql
#           openldap
#           gnutls
#           sqlite
#           X Window System Environment
#           tdb (alternative to gdbm) https://sourceforge.net/projects/tdb/
#           heimdal-gssapi (https://github.com/heimdal/)
#           opendmarc (http://www.trusteddomain.org/opendmarc/)

### Конфигурационные файлы
#    /etc/exim.conf
#    /etc/aliases

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man8"
mkdir -pv "${TMP_DIR}"{"${DOCS}","${MAN}"}

# распакуем документацию
tar xvf "${SOURCES}/${PRGNAME}-html-${VERSION}"*.tar.?z* || exit 1
tar xvf "${SOURCES}/${PRGNAME}-texinfo-${INFO_VERSION}"*.tar.?z* || exit 1
cp -v "exim-texinfo-${INFO_VERSION}/doc"/* doc/

# перед установкой Exim должны существовать группа и пользователь exim
! grep -qE "^exim:" /etc/group  && \
    groupadd -g 31 exim

! grep -qE "^exim:" /etc/passwd && \
    useradd -c "Exim Daemon" \
            -d /dev/null \
            -g exim \
            -s /bin/false \
            -u 31 exim

# параметры конфигурации exim определяются в Local/Makefile, который мы
# создадим из файла конфигурации по умолчанию src/EDITME В этом же файле будем
# искать директивы для включения зависимостей и расширение функционала exim.
# Например, если в системе установлен пакет linux-pam (Pluggable Authentication
# Modules) и мы хотим включить его поддержку, раскомментируем строку
# SUPPORT_PAM=yes в src/EDITME

# Монитор exim (директива EXIM_MONITOR в src/EDITME, по умолчанию
# закомментирована) - GUI-приложение, которое отображает информацию о состоянии
# очереди exim и о том, что делает exim. Пользователь с правами администратора
# может выполнять определенные операции с сообщениями из этого интерфейса.
# Однако весь этот функционал доступен из командной строки, а сам монитор,
# естественно, требует установленных "Иксов", поэтому включать его в сборку не
# будем.

# если нам нужно встроить интерфейсы exim для вызова программ сканирования на
# вирусы и спам непосредственно из списков контроля доступа, раскомментируем
# параметр WITH_CONTENT_SCAN=yes
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch45.html

# чтобы использовать внутреннюю базу данных, отличную от Berkeley DB (по
# умолчанию), смотрим
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch04.html#SECTdb

# настройка SSL функционала
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch04.html#SECTinctlsssl
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch42.html

# tcpwrappers функционал
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch04.html#SECID27.

# добавление различных механизмов аутентификации, см. главы 33—41
# http://exim.org/exim-html-4.93/doc/html/spec_html/index.html

# настройка Linux-PAM
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch11.html#SECTexpcond.

# связывание библиотек ядра базы данных, используемых для поиска имен
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch09.html

# добавление поддержки Readline при запуске в режиме "test extension" (-be)
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch05.html#id2525974

# писать syslog вместо /var/spool/exim/log (по умолчанию)
# http://exim.org/exim-html-4.93/doc/html/spec_html/ch52.html

sed -e 's,^BIN_DIR.*$,BIN_DIRECTORY=/usr/sbin,'                              \
    -e 's,^CONF.*$,CONFIGURE_FILE=/etc/exim.conf,'                           \
    -e '/# INFO_DIRECTORY=\/usr\/share\/info/s,^# ,,'                        \
    -e 's,^EXIM_USER.*$,EXIM_USER=exim,'                                     \
    -e '/# USE_OPENSSL/s,^# ,,'                                              \
    -e 's,^# LOG_FILE_PATH=/var/.*$,LOG_FILE_PATH=/var/log/exim/exim_%slog,' \
        src/EDITME > Local/Makefile || exit 1

make || exit 1

# пакет не имеет набора тестов

EXIM_CONF="/etc/exim.conf"
if [ -f "${EXIM_CONF}" ]; then
    mv "${EXIM_CONF}" "${EXIM_CONF}.old"
fi

make install
make DESTDIR="${TMP_DIR}" install

config_file_processing "${EXIM_CONF}"

# man-страница
install -v -m644 doc/exim.8 "${MAN}"
install -v -m644 doc/exim.8 "${TMP_DIR}${MAN}"

# документация
install -v -d -m755 "${DOCS}"
install -v -m644 doc/* "${DOCS}"
install -v -m644 doc/* "${TMP_DIR}${DOCS}"
cp -vR "${PRGNAME}-html-${VERSION}/${PRGNAME}-html-${VERSION}/doc"/* \
    "${DOCS}"
cp -vR "${PRGNAME}-html-${VERSION}/${PRGNAME}-html-${VERSION}/doc"/* \
    "${TMP_DIR}${DOCS}"

# ссылка в /usr/bin sendmail -> exim
# для приложений, которым это необходимо, и exim принимает большинство
# параметров командной строки sendmail
ln -svf exim /usr/sbin/sendmail
(
    cd "${TMP_DIR}/usr/sbin" || exit
    ln -svf exim sendmail
)

install -v -d -m750 -o exim -g exim /var/log/exim
install -v -d -m750 -o exim -g exim /var/spool/exim
install -v -d -m750 -o exim -g exim "${TMP_DIR}/var/log/exim"
install -v -d -m750 -o exim -g exim "${TMP_DIR}/var/spool/exim"

# писать в каталог /var/mail могут все (он уже установлен с lfs пакетом
# main-directory-tree)
chmod -v a+wt /var/mail

# конфиг /etc/aliases устанавливается во время установки пакета только если он
# еще не существует. По умолчанию он полностью закомментирован. Создадим в нем
# пару стандартных псевдонимов
ALIASES="/etc/aliases"
if ! grep -Eq '^postmaster:' "${ALIASES}" &>/dev/null; then
    cat >> "${ALIASES}" << "EOF"

postmaster: root
mailer-daemon: postmaster
EOF
fi

# установим скрипт для возможной автозагрузки exim при старте системы
(
    cd /root/blfs-bootscripts || exit 1
    make install-exim
    make install-exim DESTDIR="${TMP_DIR}"
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the Exim MTA - Mail Transfer Agent)
#
# Exim is a Mail Transfer Agent (MTA) used on Unix-like operating systems. It
# is freely available under the GNU GPL and it aims to be a general and
# flexible mailer with extensive facilities for checking incoming e-mail and
# can be integrated with other email tools.
#
# Home page: http://www.exim.org/
# Download:  https://ftp.exim.org/pub/${PRGNAME}/${PRGNAME}4/old/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
