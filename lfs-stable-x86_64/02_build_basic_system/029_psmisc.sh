#! /bin/bash

PRGNAME="psmisc"

### Psmisc
# Программы для отображения информации о защенных процессах, а так же для
# управления такими процессами

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/psmisc.html

# Home page: http://psmisc.sourceforge.net/
# Download:  https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.2.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/bin"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов, поэтому сразу устанавливаем
make install
make install DESTDIR="${TMP_DIR}"

# переместим программы 'killall' и 'fuser' из /usr/bin в /bin
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin
mv -v "${TMP_DIR}/usr/bin/fuser"   "${TMP_DIR}/bin"
mv -v "${TMP_DIR}/usr/bin/killall" "${TMP_DIR}/bin"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (displaying information about running processes)
#
# The Psmisc package contains programs for displaying information about running
# processes.
#
# Home page: http://psmisc.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
