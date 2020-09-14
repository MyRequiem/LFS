#! /bin/bash

PRGNAME="smartmontools"

### smartmontools (S.M.A.R.T. Monitoring Tools)
# Утилиты для контроля, анализа и вывода отчетности S.M.A.R.T. параметров ATA и
# SCSI жестких дисков. Используются для проверки надежности и прогнозирования
# отказов жестких дисков.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/smartmontools.html

# Home page: https://sourceforge.net/projects/smartmontools/
# Download:  https://downloads.sourceforge.net/smartmontools/smartmontools-7.1.tar.gz

# Required: no
# Optional: curl or lynx or wget
#           gnupg

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GPG="no"
command -v gpg &>/dev/null && GPG="yes"

# не создавать скрипт инициализации smartd по умолчанию
#    --with-initscriptdir=no
./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --with-initscriptdir=no \
    --with-libsystemd=no    \
    --with-gnupg="${GPG}"   \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не содержит набора тестов

# конфиг /etc/smartd.conf
SMARTD_CONF="/etc/smartd.conf"
if [ -f "${SMARTD_CONF}" ]; then
    mv "${SMARTD_CONF}" "${SMARTD_CONF}.old"
fi

make install
make install DESTDIR="${TMP_DIR}"

config_file_processing "${SMARTD_CONF}"

# для автозапуска демона smartd при загрузке системы установим скрипт
# инициализации /etc/rc.d/init.d/smartd
(
    cd /root/blfs-bootscripts || exit 1
    make install-smartd
    make install-smartd DESTDIR="${TMP_DIR}"
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (hard drive monitoring utilities)
#
# SMARTMONTOOLS contains utilities that control and monitor storage devices
# using the Self-Monitoring, Analysis, and Reporting Technology (S.M.A.R.T.)
# system build into ATA and SCSI Hard Drives. This is used to check the
# reliability of the hard drive and to predict drive failures.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
