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
mkdir -pv "${TMP_DIR}"{/bin,"${MAN_PAGE}"}

make || exit 1

# пакет не имеет набора тестов

cp "${PRGNAME}/${PRGNAME}"   "${TMP_DIR}/bin"
cp "${PRGNAME}/${PRGNAME}.8" "${TMP_DIR}${MAN_PAGE}"
(
    # ссылка в /bin
    #    traceroute6 -> traceroute
    cd "${TMP_DIR}/bin" || exit 1
    ln -sv "${PRGNAME}" "${PRGNAME}6"
    # ссылка в /usr/share/man/man8
    #    traceroute6.8 -> traceroute.8
    cd "${TMP_DIR}/usr/share/man/man8" || exit 1
    ln -sv "${PRGNAME}.8" "${PRGNAME}6.8"
)

# этот пакет перезаписывает утилиту traceroute, установленную в LFS с пакетом
# inetutils. Данная версия более мощная и имеет многие дополнительные опции.
INETUTILS_PKG="/var/log/packages/inetutils"
rm -rf /bin/traceroute
sed '/\/bin\/traceroute/d' -i "${INETUTILS_PKG}"-*

# man-страница traceroute.1, установленная в LFS с пакетом inetutils, больше не
# соответстветствует утилите traceroute, удалим ее
rm -fv "/usr/share/man/man1/${PRGNAME}.1"
sed '/\/usr\/share\/man\/man1\/traceroute.1/d' -i "${INETUTILS_PKG}"-*

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
