#! /bin/bash

PRGNAME="sed"

### Sed (stream editor)
# Потоковый редактор

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr || exit 1

make || make -j1 || exit 1

# тесты проводим от пользователя tester
# chown -Rv tester .
# su tester -c "PATH=${PATH} make check"
# chown -Rv root:root .

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (stream editor)
#
# This is the GNU version of sed, a stream editor. A stream editor is used to
# perform basic text transformations on an input stream (a file or input from a
# pipeline). It is sed's ability to filter text in a pipeline which
# distinguishes it from other types of editors.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
