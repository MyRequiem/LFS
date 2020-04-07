#! /bin/bash

PRGNAME="bash"

### Bash
# Bourne-Again SHell

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/bash.html

# Home page: http://www.gnu.org/software/bash/
# Download:  http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# использовать библиотеку readline, которая уже устанавлена в системе вместо
# использования собственной внутренней версии
#    --with-installed-readline
./configure                   \
    --prefix=/usr             \
    --without-bash-malloc     \
    --with-installed-readline \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты будем запускать от пользователя nobody
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=${PATH}:/tools/bin HOME=/home make tests"
chown -Rv root:root .

make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/bin"
make install DESTDIR="${TMP_DIR}"

# переместим bash из /usr/bin в /bin
mv -vf /usr/bin/bash /bin
mv -vf "${TMP_DIR}/usr/bin/bash" "${TMP_DIR}/bin"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Bourne-Again SHell - sh-compatible shell)
#
# The GNU Bourne-Again SHell. Bash is a sh-compatible command interpreter that
# executes commands read from the standard input or from a file. Bash also
# incorporates useful features from the Korn and C shells (ksh and csh). Bash
# must be present for the system to boot properly.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
