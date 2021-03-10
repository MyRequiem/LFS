#! /bin/bash

PRGNAME="sed"

### Sed (stream editor)
# Потоковый редактор

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

./configure       \
    --prefix=/usr \
    --bindir=/bin || exit 1

make || make -j1 || exit 1
make html || exit 1

# тесты проводим от пользователя tester
# chown -Rv tester .
# su tester -c "PATH=${PATH} make check"
# chown -Rv root:root .

make install DESTDIR="${TMP_DIR}"

# устанавливаем документацию
install -m644 doc/sed.html "${TMP_DIR}${DOCS}"

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
