#! /bin/bash

PRGNAME="gnome-nettool"

### GNOME Nettool (GNOME Nettool)
# Набор графических утилит для среды рабочего стола GNOME, который
# предоставляет удобный интерфейс для доступа к различным сетевым командам
# (таким как ping, netstat, ifconfig, traceroute, whois), позволяя
# пользователям Linux/UNIX легко просматривать и управлять сетевой информацией
# и подключениями. Это инструмент как для начинающих так и для опытных
# пользователей, упрощающий администрирование сети.

# Required:    gtk+3
#              itstool
#              libgtop
#              --- runtime ---
#              bind-utils
#              nmap
#              net-tools
#              traceroute
#              whois
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# адаптируем GNOME Nettool к изменениям в утилитах ping, ping6 и netstat
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-ping_and_netstat_fixes-1.patch" || exit 1

# исправление для новых версий meson
sed -i '/merge_file/s/(.*/(/' data/meson.build || exit 1

mkdir build
cd build || exit 1

meson setup       \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Nettool)
#
# The GNOME Nettool package is a network information tool which provides GUI
# interface for some of the most common command line network tools
#
# Home page: https://gitlab.gnome.org/Archive/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
