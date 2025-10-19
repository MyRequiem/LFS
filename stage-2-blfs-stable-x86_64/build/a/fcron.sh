#! /bin/bash

PRGNAME="fcron"

### Fcron (periodical command scheduler)
# Периодическое выполнения заданий в определённое время (планировщик команд).
# Fcron хорошо работает на системах, которые не запущены постоянно (ноутбуки,
# десктопы). В отличие от Dcron, Fcron может запускать пропущенные во время
# выключения машины задания.

# Required:    no
# Recommended: no
# Optional:    MTA            dovecot, exim, postfix или sendmail
#              vim            (или любой другой текстовый редактор)
#              linux-pam
#              docbook-utils

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | \
    sort | head -n 1 | rev | cut -d . -f 4- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/var/spool/fcron"

### должны существовать пользователь и группа fcron
# добавим группу fcron, если не существует
! grep -qE "^fcron:" /etc/group  && \
    groupadd -g 22 fcron

# добавим пользователя fcron, если не существует
! grep -qE "^fcron:" /etc/passwd && \
    useradd -c "Fcron User" \
            -d /dev/null    \
            -g fcron        \
            -s /bin/false   \
            -u 22 fcron

# исправим некоторые пути, жестко закодированные в документации
find doc -type f -exec sed -i 's:/usr/local::g' {} \;

# не отправлять результаты выполнения команд на почту
#    --without-sendmail
# не устанавливать скрипт инициализации при загрузке системы (мы есго установим
# из blfs-bootscripts, см. ниже)
#    --with-boot-install=no
# не собирать системные модули, которые не нужны для System V
#    --with-systemdsystemunitdir=no
./configure                \
    --prefix=/usr          \
    --sysconfdir=/etc      \
    --localstatedir=/var   \
    --without-sendmail     \
    --with-boot-install=no \
    --with-systemdsystemunitdir=no || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

# скрипт run-parts from Slackware
RUN_PARTS="/usr/bin/run-parts"
cat << EOF > "${TMP_DIR}${RUN_PARTS}"
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
chmod -v 755 "${TMP_DIR}${RUN_PARTS}"

install -vdm754 "${TMP_DIR}/etc/"cron.{hourly,daily,weekly,monthly}

SYSTAB="/var/spool/fcron/systab"
cat << EOF > "${TMP_DIR}${SYSTAB}.orig"
### NOTE:
# To create /var/spool/fcron/systab enter the following command after editing
# current file:
#    # fcrontab -z -u systab

&bootrun 00 0,12,18 * * *    root run-parts /etc/cron.hourly
&bootrun 59 23      * * *    root run-parts /etc/cron.daily
&bootrun 22 12      * * 0    root run-parts /etc/cron.weekly
&bootrun 42 12      1 * *    root run-parts /etc/cron.monthly
EOF

# для автозапуска fcron демона при загрузке системы установим скрипт
# инициализации /etc/rc.d/init.d/fcron
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-fcron DESTDIR="${TMP_DIR}"
)

rm -rf "${TMP_DIR}/var/run"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# запустим fcron демон
/etc/rc.d/init.d/fcron start
# сгенерируем /var/spool/fcron/systab
fcrontab -z -u systab

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (periodical command scheduler)
#
# Fcron is a periodical command scheduler which aims at replacing Vixie Cron
# and Anacron. Fcron works well on systems that are not continuously running
# such as laptops or desktops and it is loaded with features. When a machine is
# powered on, Fcron can start jobs that were skipped while the machine was
# powered off
#
# Home page: http://${PRGNAME}.free.fr/
# Download:  http://${PRGNAME}.free.fr/archives/${PRGNAME}-${VERSION}.src.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
