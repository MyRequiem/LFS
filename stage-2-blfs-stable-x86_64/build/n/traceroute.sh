#! /bin/bash

PRGNAME="traceroute"

### Traceroute (IP packet route tracing utility)
# Утилита, которая используется для отображения сетевого маршрута, по которому
# пакеты достигают определенного хоста. Если обнаруживается проблема
# подключения к другой системе, traceroute может помочь ее определить.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN_PAGE="/usr/share/man/man8"
mkdir -pv "${TMP_DIR}"{/usr/bin,"${MAN_PAGE}"}

make || exit 1
make prefix=/usr install DESTDIR="${TMP_DIR}"

ln -sv -f traceroute   "${TMP_DIR}/usr/bin/traceroute6"
ln -sv -f traceroute.8 "${TMP_DIR}/usr/share/man/man8/traceroute6.8"

# этот пакет перезаписывает утилиту traceroute, установленную в LFS с пакетом
# inetutils. Данная версия более мощная и имеет многие дополнительные опции
rm -f /usr/bin/traceroute
rm -f /usr/share/man/man1/traceroute.1

sed '/\/usr\/bin\/traceroute/d'                -i /var/log/packages/inetutils-*
sed '/\/usr\/share\/man\/man1\/traceroute.1/d' -i /var/log/packages/inetutils-*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (IP packet route tracing utility)
#
# The Traceroute package contains a program which is used to display the
# network route that packets take to reach a specified host. This is a standard
# network troubleshooting tool. If you find yourself unable to connect to
# another system, traceroute can help pinpoint the problem.
#
# Home page: https://downloads.sourceforge.net/${PRGNAME}
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
