#! /bin/bash

PRGNAME="procps-ng"

### Procps-ng (utilities for displaying process information)
# Программы для мониторинга процессов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/procps-ng.html

# Home page: https://sourceforge.net/projects/procps-ng
# Download:  https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-3.3.15.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

# отключаем сборку утилиты kill, которая будет установлена с пакетом util-linux
#    --disable-kill
./configure           \
    --prefix=/usr     \
    --exec-prefix=    \
    --libdir=/usr/lib \
    --disable-static  \
    --disable-kill    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# набор тестов нуждается в некоторых пользовательских модификациях для LFS.
# Удалим тест, который дает сбой, когда сценарии не используют tty-устройство и
# исправим два других теста
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp   || exit 1
sed -i '/set tty/d'                   testsuite/pkill.test/pkill.exp || exit 1
rm testsuite/pgrep.test/pgrep.exp
make check

make install
make install DESTDIR="${TMP_DIR}"

# переместим библиотеку libprocps.so из /usr/lib в /lib
mv -v /usr/lib/libprocps.so.* /lib
mv -v "${TMP_DIR}/usr/lib"/libprocps.so.* "${TMP_DIR}/lib"

# установим ссылку в /usr/lib
# libprocps.so -> ../../lib/libprocps.so.7.1.0
ln -sfv "../../lib/$(readlink /usr/lib/libprocps.so)" /usr/lib/libprocps.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libprocps.so)" libprocps.so
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (utilities for displaying process information)
#
# The procps-ng package provides the classic set of utilities used to display
# information about the processes currently running on the machine.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/Production/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
