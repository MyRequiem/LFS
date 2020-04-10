#! /bin/bash

PRGNAME="lsb-release"

### lsb_release
# Сценарий lsb_release предоставляет информацию о статусе рассылок базы
# стандартов Linux (LSB)

# http://www.linuxfromscratch.org/blfs/view/9.0/postlfs/lsb-release.html

# Home page: https://downloads.sourceforge.net/lsb/
# Download:  https://downloads.sourceforge.net/lsb/lsb-release-1.4.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/usr/{bin,share/man/man1}

# исправим небольшую проблему с отображением
sed -i "s|n/a|unavailable|" lsb_release

# собираем
./help2man                           \
    -N                               \
    --include ./lsb_release.examples \
    --alt_version_key=program_version ./lsb_release > lsb_release.1

# устанавливаем
install -v -m 644 lsb_release.1 /usr/share/man/man1
install -v -m 755 lsb_release   /usr/bin
install -v -m 644 lsb_release.1 "${TMP_DIR}/usr/share/man/man1"
install -v -m 755 lsb_release   "${TMP_DIR}/usr/bin"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (script to give LSB data)
#
# The lsb_release script gives information about the Linux Standards Base (LSB)
# status of the distribution.
#
# Home page: https://downloads.sourceforge.net/lsb/
# Download:  https://downloads.sourceforge.net/lsb/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
