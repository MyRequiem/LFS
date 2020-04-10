#! /bin/bash

PRGNAME="libssh"

### libssh
# Многоплатформенная библиотека C, реализующая протоколы SSHv1 и SSHv2 на
# стороне клиента и сервера. С libssh можно удаленно выполнять программы,
# передавать файлы и использовать безопасный и прозрачный туннель

# нет в LFS и BLFS (только libssh2)

# Home page: http://www.libssh.org/
# Download:  https://www.libssh.org/files/0.9/libssh-0.9.3.tar.xz

# Required: cmake
#           openssl
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1
cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DWITH_GCRYPT=1             \
    -DWITH_SSH1=1               \
    -DWITH_PCAP=1               \
    -DWITH_SFTP=1               \
    -DWITH_SERVER=1             \
    -DWITH_STATIC_LIB=0         \
    .. || exit 1

make || exit 1
make install
make install DESTDIR="${TMP_DIR}"

# документация
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -m755 -d "${DOCS}"
install -v -m755 -d "${TMP_DIR}${DOCS}"

cd .. || exit 1
cp -a  AUTHORS BSD COPYING ChangeLog INSTALL README "${DOCS}"
cp -a  AUTHORS BSD COPYING ChangeLog INSTALL README "${TMP_DIR}${DOCS}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library implementing ssh protocols)
#
# libssh is a mulitplatform C library implementing the SSHv2 and SSHv1 protocol
# on client and server side.  With libssh, you can remotely execute programs,
# transfer files, and use a secure and transparent tunnel for your remote
# applications
#
# Home page: http://www.libssh.org/
# Download:  https://www.libssh.org/files/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
