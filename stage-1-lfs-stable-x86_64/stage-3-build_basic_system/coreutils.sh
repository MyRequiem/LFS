#! /bin/bash

PRGNAME="coreutils"

### Coreutils (core GNU utilities)
# Утилиты для отображения и настройки основных характеристик системы: basename,
# cat, chmod, chown, chroot, cp, cut, date и т.д.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
MAN8="/usr/share/man/man8"
mkdir -pv "${TMP_DIR}"{/usr/sbin,"${MAN8}"}

# стандарт POSIX требует, чтобы программы из Coreutils распознавали границы
# символов правильно даже в многобайтовых локалях. Применим патч исправляющий
# это несоответствия и другие ошибки, связанные с интернационализацией
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-i18n-2.patch" || exit 1

# применение патча модифицировало систему сборки, поэтому файлы конфигурации
# необходимо сгенерировать заново
autoreconf -fiv

# позволяет собирать пакет от имени пользователя root
#    FORCE_UNSAFE_CONFIGURE=1
# запретим установку утилит kill и uptime ('kill' будет установлена с пакетом
# util-linux, 'uptime' с пакетом procps-ng)
#    --enable-no-install-program=kill,uptime
FORCE_UNSAFE_CONFIGURE=1 \
./configure              \
    --prefix=/usr        \
    --enable-no-install-program=kill,uptime || exit 1

make || make -j1 || exit 1

### тесты
# некоторые тесты должны запускаться от пользователя root
# make NON_ROOT_USERNAME=tester check-root

# остальные тесты должны быть запущены от пользователя tester, который
# принадлежит только одной группе tester, однако определенные тесты требуют,
# чтобы пользователь tester был членом более чем одной группы. Чтобы эти тесты
# не были пропущены мы добавим временную группу dummy и сделаем пользователя
# tester членом этой группы
# echo "dummy:x:102:tester" >> /etc/group

# сделаем владельцем дерева исходников пользователя tester
# chown -Rv tester .

# указывает тестовому набору выполнить некоторые дополнительные тесты
#    RUN_EXPENSIVE_TESTS=yes
# su tester -c "PATH=${PATH} make -k RUN_EXPENSIVE_TESTS=yes check" < /dev/null
# известно, что тест 'test-getlogin' не проходит в среде chroot LFS

# удалим созданную нами временную группу dummy
# groupdel dummy

# восстановим владельца и группу дерева исходников
# chown -Rv root:root .
#
### конец тестирования

# устанавливаем пакет
make install DESTDIR="${TMP_DIR}"

# утилита chroot в /usr/sbin
mv -v "${TMP_DIR}/usr/bin/chroot" "${TMP_DIR}/usr/sbin"

# переместим man-страницу для chroot из man1 в man8
mv -v "${TMP_DIR}/usr/share/man/man1/chroot.1" "${TMP_DIR}${MAN8}/chroot.8"
sed -i 's/"1"/"8"/' "${TMP_DIR}${MAN8}/chroot.8"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1

# утилиту 'cp' переместим в /tmp, т.к. ее нужно будет скопировать в /usr/bin из
# только что собранного пакета
mv /usr/bin/cp /tmp
/tmp/cp -vR "${TMP_DIR}"/* /
rm -f /tmp/cp

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (core GNU utilities)
#
# These are the GNU core utilities, the basic command line programs such as
# 'mkdir', 'ls', and 'rm' that are needed for the system to run. This package
# is the union of the GNU fileutils, sh-utils, and textutils packages. Most of
# these programs have significant advantages over their Unix counterparts, such
# as greater speed, additional options, and fewer arbitrary limits.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
