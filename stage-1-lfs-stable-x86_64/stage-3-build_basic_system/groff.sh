#! /bin/bash

PRGNAME="groff"

### Groff (document formatting system)
# Программы для обработки и форматирования текста

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# Groff ожидает, что переменная окружения PAGE будет содержать размер страницы
# по умолчанию. Для пользователей в Соединенных Штатах подходит PAGE=letter. В
# других странах более подходящим значением может быть PAGE=A4. Так же размер
# страницы может быть переопределен позже в файле /etc/papersize
PAGE=A4 ./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (document formatting system)
#
# The GNU groff package provides versions of troff, nroff, eqn, tbl, and other
# Unix text-formatting utilities. Groff is used to 'compile' man pages stored
# in groff/nroff format into a form which can be printed or displayed on the
# screen. These man pages are stored in compressed form in the /usr/man/man?
# directories.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
