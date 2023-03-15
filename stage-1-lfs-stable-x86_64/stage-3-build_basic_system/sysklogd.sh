#! /bin/bash

PRGNAME="sysklogd"

### Sysklogd (Linux system logging utilities)
# Программы для регистрации системных сообщений (логирования)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"/{etc,usr/sbin,usr/share/man/{man5,man8}}

# исправим проблему, которая вызывает segmentation fault в некоторых ситуациях
# в klogd, а так же исправим устаревшую конструкцию в исходном коде syslogd.c
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c || exit 1
sed -i 's/union wait/int/' syslogd.c                      || exit 1

make || make -j1 || exit 1
# пакет не содержит набора тестов
make BINDIR="${TMP_DIR}/usr/sbin" MANDIR="${TMP_DIR}/usr/share/man" install

### конфиг /etc/syslog.conf
SYSLOG_CONF="/etc/syslog.conf"
cat << EOF > "${TMP_DIR}${SYSLOG_CONF}"
# Begin ${SYSLOG_CONF} - configuration file for syslogd(8)

# all messages with the priority 'crit'
.=crit                      -/var/log/critical

# kernel messages
kern.*                      -/var/log/kernel

# log anything 'info' or higher, but lower than 'warn', exclude authpriv, cron,
# mail, and news
*.info;\\
    *.!warn;\\
    authpriv.none;\\
    cron.none;\\
    mail.none;\\
    news.none               -/var/log/messages

# log anything 'warn' or higher, exclude authpriv, cron, mail, and news
*.warn;*.warning\\
    authpriv.none;\\
    cron.none;\\
    mail.none;\\
    news.none               -/var/log/syslog

# debugging information is logged here
*.=debug                    -/var/log/debug

# authentication message logging
authpriv.*                  -/var/log/secure
auth.*                      -/var/log/auth

# cron related logs
cron.*                      -/var/log/cron
fcron.*                     -/var/log/fcron

# mail related logs
mail.*                      -/var/log/mail

# emergency level messages go to all users
*.emerg                     *

daemon.*                    -/var/log/daemon
user.*                      -/var/log/user

# End ${SYSLOG_CONF}
EOF

# бэкапим /etc/syslog.conf
if [ -f "${SYSLOG_CONF}" ]; then
    mv "${SYSLOG_CONF}" "${SYSLOG_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

config_file_processing "${SYSLOG_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Linux system logging utilities)
#
# The Sysklogd package contains programs for logging system messages, such as
# those given by the kernel when unusual things happen.
#
# Home page: http://www.infodrom.org/projects/${PRGNAME}/
# Download:  http://www.infodrom.org/projects/${PRGNAME}/download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
