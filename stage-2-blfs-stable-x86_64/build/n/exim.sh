#! /bin/bash

PRGNAME="exim"

### Exim (the Exim MTA - Mail Transfer Agent)
# Представляет собой универсальный и гибкий почтовик с широкими возможностями
# для проверки входящей электронной почты, а так же может быть интегрирован с
# другими инструментами для работы с электронной почтой.

# Required:    libnsl
#              pcre
# Recommended: no
# Optional:    tdb                      (https://sourceforge.net/projects/tdb/)
#              cyrus-sasl
#              libidn
#              linux-pam
#              mariadb or mysql         (https://www.mysql.com/)
#              openldap
#              gnutls
#              postgresql
#              sqlite
#              Graphical Environments
#              heimdal-gssapi           (https://github.com/heimdal/heimdal)
#              opendmarc                (http://www.trusteddomain.org/opendmarc/)

### Конфиги
#    /etc/exim.conf
#    /etc/aliases

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man8"
mkdir -pv "${TMP_DIR}${MAN}"

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
# искать директивы для включения зависимостей и расширения функционала exim.
# Например, если в системе установлен пакет linux-pam и мы хотим включить его
# поддержку, раскомментируем строку SUPPORT_PAM=yes в src/EDITME

sed -e 's,^BIN_DIR.*$,BIN_DIRECTORY=/usr/sbin,'    \
    -e 's,^CONF.*$,CONFIGURE_FILE=/etc/exim.conf,' \
    -e 's,^EXIM_USER.*$,EXIM_USER=exim,'           \
    -e 's,^SUPPORT_DANE,# SUPPORT_DANE,'           \
    -e 's,^EXIM_MONITOR,# EXIM_MONITOR,'           \
        src/EDITME > Local/Makefile || exit 1

# используем gdbm если berkeley-db не установлен
if command -v db_dump &>/dev/null; then
    printf "\nUSE_DB = yes\nDBMLIB = -ldb\n"     >> Local/Makefile
else
    printf "\nUSE_GDBM = yes\nDBMLIB = -lgdbm\n" >> Local/Makefile
fi

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# man-страница
install -v -m644 "doc/${PRGNAME}.8" "${TMP_DIR}${MAN}"

# ссылка в /usr/sbin/
#    sendmail -> exim
# для приложений, которым это необходимо, а exim принимает большинство
# параметров командной строки sendmail
(
    cd "${TMP_DIR}/usr/sbin" || exit
    ln -svf "${PRGNAME}" sendmail
)

install -v -d -m750 -o exim -g exim "${TMP_DIR}/var/spool/${PRGNAME}"

# писать в каталог /var/mail могут все (он уже установлен с lfs пакетом
# main-directory-tree)
chmod -v a+wt /var/mail

# конфиг /etc/aliases устанавливается во время установки пакета только если он
# еще не существует. По умолчанию он полностью закомментирован. Создадим в нем
# пару стандартных псевдонимов
ALIASES="/etc/aliases"
if ! grep -Eq '^postmaster:' "${TMP_DIR}${ALIASES}" &>/dev/null; then
    cat >> "${TMP_DIR}${ALIASES}" << "EOF"

postmaster: root
MAILER-DAEMON: root
EOF
fi

# установим скрипт для возможности автозагрузки exim при старте системы
(
    cd /root/src/lfs/blfs-bootscripts || exit 1
    make install-exim DESTDIR="${TMP_DIR}"
)

if [ -f "${ALIASES}" ]; then
    mv "${ALIASES}" "${ALIASES}.old"
fi

EXIM_CONF="/etc/exim.conf"
if [ -f "${EXIM_CONF}" ]; then
    mv "${EXIM_CONF}" "${EXIM_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${ALIASES}"
config_file_processing "${EXIM_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the Exim MTA - Mail Transfer Agent)
#
# Exim is a Mail Transfer Agent (MTA) used on Unix-like operating systems. It
# is freely available under the GNU GPL and it aims to be a general and
# flexible mailer with extensive facilities for checking incoming e-mail and
# can be integrated with other email tools.
#
# Home page: http://www.${PRGNAME}.org/
# Download:  https://downloads.${PRGNAME}.org/${PRGNAME}4/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
