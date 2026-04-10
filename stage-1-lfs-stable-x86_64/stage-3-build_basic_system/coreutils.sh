#! /bin/bash

PRGNAME="coreutils"

### Coreutils (core GNU utilities)
# GNU Coreutils - это набор самых востребованных инструментов, которые
# составляют основу повседневной работы в Linux. В него входят такие базовые
# утилиты, как ls, cp, rm, cat, cut, date, chmod, chown, chroot и еще много
# других, без которых управление файлами и системой было бы невозможным. По
# сути, это «швейцарский нож» системы, обеспечивающий выполнение всех
# элементарных операций.

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
    "${SOURCES}/${PRGNAME}-${VERSION}-i18n-1.patch" || exit 1

# применение патчей модифицировало систему сборки, поэтому файлы конфигурации
# необходимо сгенерировать заново
autoreconf -fv

# без опции -i autoreconf не обновляет вспомогательные файлы automake, поэтому
# обновим их для предотващения сбоя сборки
automake -af

# позволяет собирать пакет от имени пользователя root
#    FORCE_UNSAFE_CONFIGURE=1
FORCE_UNSAFE_CONFIGURE=1 \
./configure              \
    --prefix=/usr || exit 1

make || make -j1 || exit 1

### тесты
# некоторые тесты должны запускаться от пользователя root
# make NON_ROOT_USERNAME=tester check-root

# остальные тесты должны быть запущены от пользователя tester, который
# принадлежит только одной группе tester, однако определенные тесты требуют,
# чтобы пользователь tester был членом более чем одной группы. Чтобы эти тесты
# не были пропущены мы добавим временную группу dummy и сделаем пользователя
# tester членом этой группы
# groupadd -g 102 dummy -U tester

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# утилита chroot в /usr/sbin
mv -v "${TMP_DIR}/usr/bin/chroot" "${TMP_DIR}/usr/sbin"

# переместим man-страницу для chroot из man1 в man8
mv -v "${TMP_DIR}/usr/share/man/man1/chroot.1" "${TMP_DIR}${MAN8}/chroot.8"
sed -i 's/"1"/"8"/' "${TMP_DIR}${MAN8}/chroot.8"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1

# утилиту 'cp' устанавливаем командой install, т.к. скопировать ее из DESTDIR
# будет не возможно по понятным причинам
install -vm755 "${TMP_DIR}/usr/bin/cp" /usr/bin
rm -f "${TMP_DIR}/usr/bin/cp"
cp -vR "${TMP_DIR}"/* /
cp /usr/bin/cp "${TMP_DIR}/usr/bin/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (core GNU utilities)
#
# These are the GNU core utilities, the basic command line programs such as
# 'mkdir', 'ls', and 'rm' that are needed for the system to run. This package
# is the union of the GNU fileutils, sh-utils, and textutils packages. Most of
# these programs have significant advantages over their Unix counterparts, such
# as greater speed, additional options, and fewer arbitrary limits.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
