#! /bin/bash

PRGNAME="rsync"

### rsync (remote file sync)
# Утилита для синхронизации больших файловых архивов по сети с минимизированием
# трафика (отправляются только различия в файлах) и кодированием данных при
# необходимости.

# Required:    no
# Recommended: popt
# Optional:    doxygen
#              xxhash  (https://xxhash.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

# по соображениям безопасности запуск сервера rsync в качестве демона должен
# производиться от пользователя rsyncd входящего в группу rsyncd
! grep -qE "^rsyncd:" /etc/group  && \
    groupadd -g 48 rsyncd

! grep -qE "^rsyncd:" /etc/passwd && \
    useradd -c "rsyncd Daemon" \
            -m                 \
            -d /home/rsync     \
            -g rsyncd          \
            -s /bin/false      \
            -u 48 rsyncd

# используем zlib установленный в системе
#    --without-included-zlib
./configure          \
    --prefix=/usr    \
    --disable-xxhash \
    --without-included-zlib || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# конфиг
RSYNCD_CONF="/etc/rsyncd.conf"
cat << EOF > "${TMP_DIR}${RSYNCD_CONF}"
# This is a basic rsync configuration file. It exports a single module without
# user authentication.

motd file = /home/rsync/welcome.msg
use chroot = yes

[localhost]
    path = /home/rsync
    comment = Default rsync module
    read only = yes
    list = yes
    uid = rsyncd
    gid = rsyncd
EOF

# init script: /etc/rc.d/init.d/rsyncd
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-rsyncd DESTDIR="${TMP_DIR}"
)

if [ -f "${RSYNCD_CONF}" ]; then
    mv "${RSYNCD_CONF}" "${RSYNCD_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${RSYNCD_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (remote file sync)
#
# The rsync package contains the rsync utility. This is useful for
# synchronizing large file archives over a network. It is a replacement for rcp
# that has many more features. It uses the "rsync algorithm" which provides a
# very fast method for bringing remote files into sync. It does this by sending
# just the differences in the files across the link, without requiring that
# both sets of files are present at one of the ends of the link beforehand.
#
# Home page: https://${PRGNAME}.samba.org
# Download:  https://www.samba.org/ftp/${PRGNAME}/src/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
