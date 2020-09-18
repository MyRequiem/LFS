#! /bin/bash

PRGNAME="fcron"

### Fcron (periodical command scheduler)
# Периодическое выполнения заданий в определённое время (планировщик команд).
# Fcron хорошо работает на системах, которые не запущены постоянно (ноутбуки,
# десктопы). В отличие от Dcron, Fcron может запускать пропущенные во время
# выключения машины задания.

# http://www.linuxfromscratch.org/blfs/view/stable/general/fcron.html

# Home page: http://fcron.free.fr
# Download:  http://fcron.free.fr/archives/fcron-3.2.1.src.tar.gz

# Required: no
# Optional: MTA (dovecot или exim или postfix или sendmail)
#           text editor (vim или любой другой)
#           linux-pam
#           docbook-utils

ROOT="/root"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | \
    sort | head -n 1 | rev | cut -d . -f 4- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# должны существовать пользователь и группа fcron

# добавим группу fcron, если не существует
! grep -qE "^fcron:" /etc/group  && \
    groupadd -g 22 fcron

# добавим пользователя fcron, если не существуют
! grep -qE "^fcron:" /etc/passwd && \
    useradd -c "Fcron User" \
            -d /dev/null    \
            -g fcron        \
            -s /bin/false   \
            -u 22 fcron

DOCBOOK_UTILS=""
DSSSL_PATH="/usr/share/sgml/docbook/dsssl-stylesheets-1.79"

command -v jw &>/dev/null && DOCBOOK_UTILS="--with-dsssl-dir=${DSSSL_PATH}"

# не отправлять результаты выполнения команд на почту
#    --without-sendmail
# не устанавливать скрипт инициализации при загрузке системы (мы есго установим
# из blfs-bootscripts, см. ниже)
#    --with-boot-install=no
# не собирать системные модули, которые не нужны для System V
#    --with-systemdsystemunitdir=no
# если установлен docbook-utils
#    --with-dsssl-dir=/usr/share/sgml/docbook/dsssl-stylesheets-1.79
./configure                    \
    --prefix=/usr              \
    --sysconfdir=/etc          \
    --localstatedir=/var       \
    --without-sendmail         \
    --with-boot-install=no     \
    --with-editor=/usr/bin/vim \
    ${DOCBOOK_UTILS}           \
    --with-systemdsystemunitdir=no || exit 1

make || exit 1

# пакет не содержит набора тестов

FCRON_CONF="/etc/fcron.conf"
if [ -f "${FCRON_CONF}" ]; then
    mv "${FCRON_CONF}" "${FCRON_CONF}.old"
fi

FCRON_ALLOW="/etc/fcron.allow"
if [ -f "${FCRON_ALLOW}" ]; then
    mv "${FCRON_ALLOW}" "${FCRON_ALLOW}.old"
fi

FCRON_DENY="/etc/fcron.deny"
if [ -f "${FCRON_DENY}" ]; then
    mv "${FCRON_DENY}" "${FCRON_DENY}.old"
fi

make install
make install DESTDIR="${TMP_DIR}"

config_file_processing "${FCRON_CONF}"
config_file_processing "${FCRON_ALLOW}"
config_file_processing "${FCRON_DENY}"

RUN_PARTS="/usr/bin/run-parts"
cat << EOF > "${RUN_PARTS}"
#!/bin/sh

# run-parts: Runs all the scripts found in a directory.
# From Slackware, by Patrick J. Volkerding with ideas borrowed from the Red Hat
# and Debian versions of this utility.

# keep going when something fails
set +e

if [ \$# -lt 1 ]; then
    echo "Usage: run-parts <directory>"
    exit 1
fi

if ! [ -d "\$1" ]; then
    echo "Not a directory: \$1"
    echo "Usage: run-parts <directory>"
    exit 1
fi

# there are several types of files that we would like to ignore automatically,
# as they are likely to be backups of other scripts:
IGNORE_SUFFIXES="~ ^ , .bak .new .rpmsave .rpmorig .rpmnew .swp"

for SCRIPT in "\$1"/* ; do
    # if this is not a regular file, skip it
    if ! [ -f "\${SCRIPT}" ]; then
        continue
    fi

    # determine if this file should be skipped by suffix
    SKIP="false"
    for SUFFIX in \${IGNORE_SUFFIXES} ; do
        if [[ "\$(basename "\${SCRIPT}" "\${SUFFIX}")" != \\
                "\$(basename "\${SCRIPT}")" ]]; then
            SKIP="true"
            break
        fi
    done

    if [[ "\${SKIP}" == "true" ]]; then
        continue
    fi

    # if we've made it this far, then run the script if it's executable
    if [ -x "\${SCRIPT}" ]; then
        \${SCRIPT} || echo "\${SCRIPT} failed"
    fi
done

exit 0
EOF

cp -v "${RUN_PARTS}" "${TMP_DIR}/usr/bin/"
chmod -v 755 /usr/bin/run-parts
chmod -v 755 "${TMP_DIR}/usr/bin/run-parts"

install -vdm754 /etc/cron.{hourly,daily,weekly,monthly}
install -vdm754 "${TMP_DIR}/etc/cron."{hourly,daily,weekly,monthly}

SYSTAB="/var/spool/fcron/systab"
if [ -f "${SYSTAB}.orig" ]; then
    mv "${SYSTAB}.orig" "${SYSTAB}.orig.old"
fi

cat << EOF > "${SYSTAB}.orig"
&bootrun 01 * * * * root run-parts /etc/cron.hourly
&bootrun 02 4 * * * root run-parts /etc/cron.daily
&bootrun 22 4 * * 0 root run-parts /etc/cron.weekly
&bootrun 42 4 1 * * root run-parts /etc/cron.monthly
EOF

cp -v "${SYSTAB}.orig" "${TMP_DIR}/var/spool/fcron/"
config_file_processing "${SYSTAB}.orig"

# для автозапуска fcron демона при загрузке системы установим скрипт
# инициализации /etc/rc.d/init.d/fcron
(
    cd /root/blfs-bootscripts || exit 1
    make install-fcron
    make install-fcron DESTDIR="${TMP_DIR}"
)

# запустим fcron демон (если не запущен) и сгенерируем файл
# /var/spool/fcron/systab
if ! [ -f /var/run/fcron.pid ]; then
    /etc/rc.d/init.d/fcron start
fi

fcrontab -z -u systab
touch "${TMP_DIR}/var/spool/fcron/systab"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (periodical command scheduler)
#
# Fcron is a periodical command scheduler which aims at replacing Vixie Cron
# and Anacron. Fcron works well on systems that are not continuously running
# such as laptops or desktops and it is loaded with features. When a machine is
# powered on, Fcron can start jobs that were skipped while the machine was
# powered off
#
# Home page: http://fcron.free.fr
# Download:  http://fcron.free.fr/archives/${PRGNAME}-${VERSION}.src.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
