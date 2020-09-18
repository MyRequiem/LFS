#! /bin/bash

PRGNAME="libssh2"

### Libssh2 (SSH2 library)
# Многоплатформенная библиотека C, реализующая протоколы SSHv2 на стороне
# клиента и сервера. С libssh можно удаленно выполнять программы, передавать
# файлы и использовать безопасный и прозрачный туннель

# http://www.linuxfromscratch.org/blfs/view/stable/general/libssh2.html

# Home page: http://www.libssh2.org/
# Download:  https://www.libssh2.org/download/libssh2-1.9.0.tar.gz

# Required: no
# Optional: gnupg
#           libgcrypt
#           openssh

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SSH2 library)
#
# Libssh2 package is a client-side C library implementing the SSH2 protocol.
#
# Home page: http://www.libssh2.org/
# Download:  https://www.libssh2.org/download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
