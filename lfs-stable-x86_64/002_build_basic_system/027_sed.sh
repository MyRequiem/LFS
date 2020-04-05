#! /bin/bash

PRGNAME="sed"

### Sed
# потоковый редактор

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/sed.html

# Home page: http://www.gnu.org/software/sed/
# Download:  http://ftp.gnu.org/gnu/sed/sed-4.7.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# исправим проблему окружения для среды LFS, а так же удалим один из тестов
# (testsuite.panic-tests.sh), который терпит неудачу
sed -i 's/usr/tools/'                 build-aux/help2man
sed -i 's/testsuite.panic-tests.sh//' Makefile.in

./configure       \
    --prefix=/usr \
    --bindir=/bin || exit 1

# собираем пакет и документацию
make || exit 1
make html || exit 1
# запускаем наборы тестов
make check
# устанавливаем пакет
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

# устанавливаем документацию
install -d -m755           "/usr/share/doc/${PRGNAME}-${VERSION}"
install -m644 doc/sed.html "/usr/share/doc/${PRGNAME}-${VERSION}"
install -d -m755           "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
install -m644 doc/sed.html "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (stream editor)
#
# This is the GNU version of sed, a stream editor. A stream editor is used to
# perform basic text transformations on an input stream (a file or input from a
# pipeline). It is sed's ability to filter text in a pipeline which
# distinguishes it from other types of editors.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
