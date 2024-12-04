#! /bin/bash

PRGNAME="nmap"

### Nmap (network scanner)
# Утилита для исследования и аудита безопасности сети. Поддерживает
# сканирование ping, сканирование портов и снятие отпечатков TCP/IP

# Required:    no
# Recommended: libpcap
#              lua
#              pcre2
#              liblinear
# Optional:    python2-pygtk  (для сборки утилиты zenmap)
#              python2        (для сборки утилиты ndiff)
#              libssh2

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# тесты следует проводить в графической среде
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (network scanner)
#
# Nmap is a utility for network exploration and security auditing. It supports
# ping scanning, port scanning and TCP/IP fingerprinting.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/dist/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
