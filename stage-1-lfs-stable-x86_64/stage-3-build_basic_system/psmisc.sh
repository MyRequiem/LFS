#! /bin/bash

PRGNAME="psmisc"

### Psmisc (displaying information about running processes)
# Программы для отображения информации о защенных процессах, а так же для
# управления этими процессами: fuser, killall, peekfd, prtstat, pslog, pstree,
# pstree.x11

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/bin"

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

# переместим программы 'killall' и 'fuser' из /usr/bin в /bin
mv -v "${TMP_DIR}/usr/bin/fuser"   "${TMP_DIR}/bin"
mv -v "${TMP_DIR}/usr/bin/killall" "${TMP_DIR}/bin"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (displaying information about running processes)
#
# The Psmisc package contains programs for displaying information about running
# processes: fuser, killall, peekfd, prtstat, pslog, pstree, pstree.x11
#
# Home page: http://psmisc.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
