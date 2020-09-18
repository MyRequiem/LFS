#! /bin/bash

PRGNAME="coreutils"

### Coreutils (core GNU utilities)
# Утилиты для отображения и настройки основных характеристик системы: basename,
# cat, chmod, chown, chroot, cp, cut, date и т.д.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/coreutils.html

# Home page: http://www.gnu.org/software/coreutils/
# Download:  http://ftp.gnu.org/gnu/coreutils/coreutils-8.31.tar.xz
#            http://www.linuxfromscratch.org/patches/lfs/9.1/coreutils-8.31-i18n-1.patch

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{bin,usr/sbin}

# стандарт POSIX требует, чтобы программы из Coreutils распознавали границы
# символов правильно даже в многобайтовых локалях. Применим патч исправляющий
# это несоответствия и другие ошибки, связанные с интернационализацией
patch -Np1 -i "/sources/${PRGNAME}-${VERSION}-i18n-1.patch" || exit 1

# отключим тест gnulib.mk, который на некоторых машинах может бесконечно
# зацикливаться
sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk

# обновим созданные файлы конфигурации в соответствии с последней версией
# automake
autoreconf -fiv

# позволяет собирать пакет от имени пользователя root
#    FORCE_UNSAFE_CONFIGURE=1
# запретим установку утилит kill и uptime, которые будут установлены с другими
# пакетами позже
#    --enable-no-install-program=kill,uptime
FORCE_UNSAFE_CONFIGURE=1 \
./configure              \
    --prefix=/usr        \
    --enable-no-install-program=kill,uptime || exit 1

make || exit 1
# некоторые тесты предназначены для запуска от пользователя root
make NON_ROOT_USERNAME=nobody check-root
# остальные тесты должны быть запущены от пользователя nobody, который
# принадлежит только одной группе nogroup, однако определенные тесты требуют,
# чтобы пользователь nobody был членом более чем одной группы. Чтобы эти тесты
# не были пропущены мы добавим временную группу dummy и сделаем пользователя
# nobody членом этой группы
echo "dummy:x:1000:nobody" >> /etc/group
chown -Rv nobody .
# известно, что тест test-getlogin не проходит в не полностью построенной
# системе. Тест tty.sh также не проходит. Параметр RUN_EXPENSIVE_TESTS=yes
# указывает тестовому набору выполнить некоторые дополнительные тесты
su nobody -s /bin/bash -c "PATH=${PATH} make RUN_EXPENSIVE_TESTS=yes check"
# удалим созданную нами временную группу dummy
sed -i '/dummy/d' /etc/group
# восстановим владельца и группу дерева исходников
chown -Rv root:root .
# устанавливаем пакет
make install
make install DESTDIR="${TMP_DIR}"

# переместим некоторые программы в места, требуемые стандартом FHS
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo}   /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,pwd,rm}             /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname}                 /bin
mv -v /usr/bin/chroot                                       /usr/sbin

mv -v "${TMP_DIR}/usr/bin"/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} \
    "${TMP_DIR}/bin"
mv -v "${TMP_DIR}/usr/bin"/{false,ln,ls,mkdir,mknod,pwd,rm} \
    "${TMP_DIR}/bin"
mv -v "${TMP_DIR}/usr/bin"/{rmdir,stty,sync,true,uname} \
    "${TMP_DIR}/bin"
mv -v "${TMP_DIR}/usr/bin/chroot" \
    "${TMP_DIR}/usr/sbin"

# переместим и переименуем man-страницу
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

mv -v "${TMP_DIR}/usr/share/man/man1/chroot.1" \
    "${TMP_DIR}/usr/share/man/man8/chroot.8"
sed -i s/\"1\"/\"8\"/1 "${TMP_DIR}/usr/share/man/man8/chroot.8"

# некоторые из сценариев в пакете LFS-Bootscripts требуют наличия утилит head,
# nice, sleep, и touch. Поскольку /usr/bin может быть недоступен на ранних
# стадиях загрузки системы, эти утилиты должны находиться в /bin
mv -v /usr/bin/{head,nice,sleep,touch} /bin
mv -v "${TMP_DIR}/usr/bin"/{head,nice,sleep,touch} "${TMP_DIR}/bin"

# переместим саму утилиту 'mv'
mv -v /usr/bin/mv /bin
/bin/mv -v "${TMP_DIR}/usr/bin/mv" "${TMP_DIR}/bin"

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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
