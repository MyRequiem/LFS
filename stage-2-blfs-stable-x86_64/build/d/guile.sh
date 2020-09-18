#! /bin/bash

PRGNAME="guile"

### Guile (GNU's Ubiquitous Intelligent Language for Extension)
# Реализация языка программирования Scheme, рекомендованная в качестве
# скриптового языка, встраиваемого в программные продукты проекта GNU

# http://www.linuxfromscratch.org/blfs/view/stable/general/guile.html

# Home page: http://www.gnu.org/software/guile/
# Download:  https://ftp.gnu.org/gnu/guile/guile-3.0.0.tar.xz

# Required: gc
#           libunistring
# Optional: emacs
#           gdb

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
LIBS="/usr/share/gdb/auto-load/usr/lib"
mkdir -pv "${TMP_DIR}${LIBS}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make      || exit 1
make html || exit 1

makeinfo --plaintext -o doc/r5rs/r5rs.txt doc/r5rs/r5rs.texi || exit 1
makeinfo --plaintext -o doc/ref/guile.txt doc/ref/guile.texi || exit 1

# тесты
# ./check-guile

make install
make install DESTDIR="${TMP_DIR}"
make install-html
make install-html DESTDIR="${TMP_DIR}"

mkdir -p "${LIBS}"
mv /usr/lib/libguile-*-gdb.scm             "${LIBS}/"
mv "${TMP_DIR}/usr/lib/libguile-"*-gdb.scm "${LIBS}/"

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mv "${DOCS}"/{guile.html,ref}
mv "${TMP_DIR}${DOCS}"/{guile.html,ref}

mv "${DOCS}"/r5rs{.html,}
mv "${TMP_DIR}${DOCS}"/r5rs{.html,}

find examples -name "Makefile*" -delete
cp -vR examples "${DOCS}"
cp -vR examples "${TMP_DIR}${DOCS}"

for DIRNAME in r5rs ref; do
    install -v -m644  "doc/${DIRNAME}"/*.txt "${DOCS}/${DIRNAME}"
    install -v -m644  "doc/${DIRNAME}"/*.txt "${TMP_DIR}${DOCS}/${DIRNAME}"
done
unset DIRNAME

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU's Ubiquitous Intelligent Language for Extension)
#
# This is Guile, Project GNU's extension language library. Guile is an
# interpreter for Scheme, packaged as a library that you can link into your
# applications to give them their own scripting language. Guile will eventually
# support other languages as well, giving users of Guile-based applications a
# choice of languages.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
