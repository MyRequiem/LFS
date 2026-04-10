#! /bin/bash

PRGNAME="bash"

### Bash (Bourne-Again SHell - sh-compatible shell)
# Bourne Again SHell - это основная программа для взаимодействия пользователя с
# системой через командную строку в Linux. Она служит командным
# интерпретатором, который понимает ваши текстовые команды, запускает нужные
# программы и позволяет автоматизировать задачи с помощью скриптов. По сути,
# это стандартный «пульт управления» и фундамент для работы большинства
# инструментов в операционной системе.

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
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# набор тестов этого пакета предназначен для запуска пользователем без
# полномочий root, который владеет терминалом, подключенным к стандартному
# вводу. Чтобы удовлетворить требование, создадим новый псевдо-терминал,
# используя Expect, и запустим тесты от имени пользователя tester
#
# chown -Rv tester .
# LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"
# set timeout -1
# spawn make tests
# expect eof
# lassign [wait] _ _ _ value
# exit $value
# EOF
# chown -Rv root:root .

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# создадим ссылку в /usr/bin/
#    sh -> bash
ln -svf bash "${TMP_DIR}/usr/bin/sh"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1

###
# ${TMP_DIR}/usr/bin/bash сразу уставливаем в систему командой install, т.к.
# скопировать его будет невозможно:
#    cannot create regular file '/usr/bin/bash': Text file busy
###
# «Text file busy» возникает потому, что мы пытаемся перезаписать файл
# /usr/bin/bash в тот момент, когда он запущен и используется системой (как
# минимум данным скриптом). Linux запрещает прямую модификацию исполняемого
# файла, если он находится в памяти
install -vm755 "${TMP_DIR}/usr/bin/bash" /usr/bin || exit 1

# копируем все остальное в корень системы (без /usr/bin/bash)
mv "${TMP_DIR}/usr/bin/bash" /tmp/
/bin/cp -vR "${TMP_DIR}"/* /
mv /tmp/bash "${TMP_DIR}/usr/bin/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Bourne-Again SHell - sh-compatible shell)
#
# The GNU Bourne-Again SHell. Bash is a sh-compatible command interpreter that
# executes commands read from the standard input or from a file. Bash also
# incorporates useful features from the Korn and C shells (ksh and csh). Bash
# must be present for the system to boot properly.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
