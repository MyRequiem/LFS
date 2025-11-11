#! /bin/bash

PRGNAME="libssh2"

### Libssh2 (SSH2 library)
# Многоплатформенная библиотека C, реализующая протоколы SSHv2 на стороне
# клиента и сервера. С libssh можно удаленно выполнять программы, передавать
# файлы и использовать безопасный и прозрачный туннель

# Required:    no
# Recommended: no
# Optional:    cmake               (можно использовать вместо скрипта configure)
#              libgcrypt           (можно использовать вместо openssl)
#              --- для тестов ---
#              openssh
#              docker              (https://www.docker.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                \
    --prefix=/usr          \
    --disable-docker-tests \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SSH2 library)
#
# Libssh2 package is a client-side C library implementing the SSH2 protocol.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://www.${PRGNAME}.org/download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
