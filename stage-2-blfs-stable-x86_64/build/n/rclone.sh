#! /bin/bash

PRGNAME="rclone"

### rclone (rsync for cloud storage)
# Универсальный инструмент, который позволяет подключать удаленные папки (через
# FTP, SSH/SFTP и другие протоколы) как обычные диски на вашем компьютере. С
# его помощью можно легко копировать, синхронизировать и просматривать файлы на
# сервере так же просто, как на флешке.

# Required:    no
# Recommended: no
# Optional:    no

# NOTE:
#    Мы не лентяи, но rclone написан на Go и компилировать его из исходников -
#    сомнительное удовольствие, поэтому берем с github готовый .deb пакет и
#    излекаем из него уже собранный rclone (бинарник)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.deb" 2>/dev/null | sort | head -n 1 | \
    cut -d - -f 2 | cut -d v -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}/${PRGNAME}-${VERSION}"
cd "${BUILD_DIR}/${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

ar x "${SOURCES}/${PRGNAME}-v${VERSION}-linux-amd64.deb"
tar -xvf data.tar.gz

install -m 755 -D "usr/bin/${PRGNAME}" "${TMP_DIR}/usr/bin/${PRGNAME}"
chown root:root "${TMP_DIR}/usr/bin/${PRGNAME}"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (rsync for cloud storage)
#
# Rclone is a command-line program to manage files on cloud storage. It is a
# feature-rich alternative to cloud vendors' web storage interfaces. Over 40
# cloud storage products support rclone including S3 object stores, business &
# consumer file storage services, as well as standard transfer protocols.
#
# Rclone has powerful cloud equivalents to the unix commands rsync, cp, mv,
# mount, ls, ncdu, tree, rm, and cat. Rclone's familiar syntax includes shell
# pipeline support, and --dry-run protection. It is used at the command line,
# in scripts or via its API.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-v${VERSION}-linux-amd64.deb
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
