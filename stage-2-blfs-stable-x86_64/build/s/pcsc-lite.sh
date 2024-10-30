#! /bin/bash

PRGNAME="pcsc-lite"

### PC/SC-lite (Middleware to access a smart card using SCard API)
# Популярный набор спецификаций для доступа к смарткартам. Спецификации
# регламентируют программный интерфейс пользователя (автора приложения с
# использованием смарткарт) с одной стороны и программный интерфейс драйверов
# считывателей смарткарт с другой стороны.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# добавим группу pcscd, если не существует
! grep -qE "^pcscd:" /etc/group  && \
    groupadd -g 257 pcscd

# добавим пользователя pcscd, если не существует
! grep -qE "^pcscd:" /etc/passwd && \
    useradd -c 'pcsc-lite daemon' \
            -d /var/run/pcscd     \
            -g pcscd              \
            -s /bin/false         \
            -u 257 pcscd

mkdir build
cd build || exit 1

meson                  \
    --prefix=/usr      \
    -Dlibsystemd=false \
    -Dlibudev=true     \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Middleware to access a smart card using SCard API)
#
# PC/SC-lite is a middleware to access a smart card using SCard API (PC/SC) Its
# purpose is to provide a Windows(R) SCard interface in a very small form
# factor for communicating to smart cards and readers.
#
# Home page: https://pcsclite.apdu.fr/
# Download:  https://pcsclite.apdu.fr/files/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
