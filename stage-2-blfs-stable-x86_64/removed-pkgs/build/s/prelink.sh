#! /bin/bash

PRGNAME="prelink"

### prelink (ELF prelinking utility)
# Программа, которая модифицирует shared ELF библиотеки и динамически связаны
# двоичные файлы ELF. В итоге динамическому компоновщику требуется меньше
# времени для запуска программ.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
CRON_WEEKLY="/etc/cron.weekly"
mkdir -pv "${TMP_DIR}${CRON_WEEKLY}"

./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --localstatedir=/var    \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# добавим еженедельный запуск в fcron
PRELINK_SH="${CRON_WEEKLY}/${PRGNAME}.sh"
cat << EOF > "${TMP_DIR}${PRELINK_SH}"
#!/bin/bash

prelink -afRm
EOF
chmod 754 "${TMP_DIR}${PRELINK_SH}"

PRELINK_CONF="/etc/${PRGNAME}.conf"
cat << EOF > "${TMP_DIR}${PRELINK_CONF}"
# This config file contains a list of directories both with binaries and
# libraries prelink should consider by default. Config file is from Debian
# package of prelink and revised with Arch Linux prelink.conf
#
# If a directory name is prefixed with '-l ', the directory hierarchy will be
# walked as long as filesystem boundaries are not crossed.
#
# If a directory name is prefixed with '-h ', symbolic links in a directory
# hierarchy are followed.
#
# Directories or files with '-b ' prefix will be blacklisted.
#
# For more details check 'man prelink'

-b /lib64
-b /lib/firmware

-l /usr/bin
-l /usr/sbin
-l /usr/lib
-l /usr/libexec
-l /opt
EOF
chmod 644 "${TMP_DIR}${PRELINK_CONF}"

PRELINK_CACHE="/etc/prelink.cache"
touch     "${TMP_DIR}${PRELINK_CACHE}"
chmod 644 "${TMP_DIR}${PRELINK_CACHE}"

if [ -f "${PRELINK_CONF}" ]; then
    mv "${CONFIG}" "${PRELINK_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${PRELINK_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ELF prelinking utility)
#
# prelink is a program which modifies shared ELF libraries and dynamically
# linked ELF binaries so that the time the dynamic linker needs for their
# relocation at startup is significantly decreased. Also, due to fewer
# relocations, the run-time memory consumption of libraries/binaries is
# decreased.
#
# Home page: https://people.redhat.com/jakub/${PRGNAME}/
# Download:  https://people.redhat.com/jakub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
