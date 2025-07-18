#! /bin/bash

PRGNAME="bash"

### Bash (Bourne-Again SHell - sh-compatible shell)
# Командная оболочка UNIX
ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# использовать библиотеку readline, которая уже устанавлена в системе вместо
# использования собственной внутренней версии
#    --with-installed-readline
./configure                   \
    --prefix=/usr             \
    --without-bash-malloc     \
    --with-installed-readline \
    bash_cv_strtold_broken=no \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# набор тестов этого пакета предназначен для запуска пользователем без
# полномочий root, который владеет терминалом, подключенным к стандартному
# вводу. Чтобы удовлетворить требование, создадим новый псевдо-терминал,
# используя Expect, и запустим тесты от имени пользователя tester
#
# chown -Rv tester .
# su -s /usr/bin/expect tester << EOF
# set timeout -1
# spawn make tests
# expect eof
# lassign [wait] _ _ _ value
# exit $value
# EOF
# chown -Rv root:root .

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1

# /usr/bin/bash сразу уставливаем в систему, т.к. скопировать
# ${TMP_DIR}/usr/bin/bash в /usr/bin/ будет невозможно:
#    cannot create regular file '/usr/bin/bash': Text file busy
install -vm755 "${TMP_DIR}/usr/bin/bash" /usr/bin || exit 1

# создадим ссылку sh -> bash в /usr/bin/
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -svf bash sh
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Bourne-Again SHell - sh-compatible shell)
#
# The GNU Bourne-Again SHell. Bash is a sh-compatible command interpreter that
# executes commands read from the standard input or from a file. Bash also
# incorporates useful features from the Korn and C shells (ksh and csh). Bash
# must be present for the system to boot properly.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

rm -vf "${TMP_DIR}/usr/bin/bash"
/bin/cp -vR "${TMP_DIR}"/* /
