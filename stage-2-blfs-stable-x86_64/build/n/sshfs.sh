#! /bin/bash

PRGNAME="sshfs"

### sshfs (Secure SHell FileSystem)
# Утилита, позволяющая подключить папку с удаленного сервера так, будто она
# находится прямо на вашем компьютере, через протокол SSH.

# Required:    fuse3
#              glib
#              openssh
# Recommended: no
# Optional:    python3-docutils (для создания man-страниц)

###
# HOW TO:
###
# Например, чтобы подключить удаленную директорию к локальному пути
# ~/examplepath (каталог должен существовать, и у вас должны быть разрешения на
# запись в него):
#    $ sshfs example.com:/home/username ~/examplepath
#
# Размонтировать можно несколькими способами:
#    $ fusermount3 -u ~/examplepath
#    или
#    $ umount ~/examplepath
#
# Монтируем удаленную директорию /home/myrequiem/tmp в локальную ~/tmp/slackSSH
#    $ mkdir -p ~/tmp/slackSSH
#    $ sshfs myrequiem@slack:/home/myrequiem/tmp ~/tmp/slackSSH

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..    \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# пакет не содержит набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Secure SHell FileSystem)
#
# The Sshfs package contains a filesystem client based on the SSH File Transfer
# Protocol. This is useful for mounting a remote computer that you have ssh
# access to as a local filesystem. This allows you to drag and drop files or
# run shell commands on the remote files as if they were on your local
# computer.
#
# Home page: https://github.com/libfuse/${PRGNAME}/
# Download:  https://github.com/libfuse/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
