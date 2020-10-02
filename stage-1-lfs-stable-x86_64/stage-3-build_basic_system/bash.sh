#! /bin/bash

PRGNAME="bash"

### Bash (Bourne-Again SHell - sh-compatible shell)
# Командная оболочка UNIX

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/bin"

# применим патч с некоторыми исправлениями
patch --verbose -Np1 -i \
    "/sources/${PRGNAME}-${VERSION}-upstream_fixes-1.patch" || exit 1

# использовать библиотеку readline, которая уже устанавлена в системе вместо
# использования собственной внутренней версии
#    --with-installed-readline
./configure                   \
    --prefix=/usr             \
    --without-bash-malloc     \
    --with-installed-readline \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# тесты будем запускать от пользователя tester
# chown -Rv tester .
# su tester << EOF
# PATH=$PATH make tests < $(tty)
# EOF
# chown -Rv root:root .

# уставливаем сразу в систему и временную директорию, т.к. скопировать
# "${TMP_DIR}/bin/bash" в /bin/bash будет невозможно:
#    cannot create regular file '/bin/bash': Text file busy
make install
make install DESTDIR="${TMP_DIR}"

# переместим 'bash' из /usr/bin в /bin
mv -fv /usr/bin/bash /bin
mv -fv "${TMP_DIR}/usr/bin/bash" "${TMP_DIR}/bin"

# создадим ссылку sh -> bash в /bin/
ln -svf bash /bin/sh
ln -svf bash "${TMP_DIR}/bin/sh"

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
