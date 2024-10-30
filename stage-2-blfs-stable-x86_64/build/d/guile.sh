#! /bin/bash

PRGNAME="guile"

### Guile (GNU's Ubiquitous Intelligent Language for Extension)
# Реализация языка программирования Scheme, рекомендованная в качестве
# скриптового языка, встраиваемого в программные продукты проекта GNU

# Required:    gc
#              libunistring
# Recommended: no
# Optional:    emacs
#              gdb

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
LIBS="/usr/share/gdb/auto-load/usr/lib"
mkdir -pv "${TMP_DIR}${LIBS}"

DOCS="false"

DOCS_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="${DOCS_DIR}" || exit 1

make || exit 1

if [[ "x${DOCS}" == "xtrue" ]]; then
    make html || exit 1
fi

# создадим .info документацию
makeinfo --plaintext -o doc/r5rs/r5rs.txt doc/r5rs/r5rs.texi || exit 1
makeinfo --plaintext -o doc/ref/guile.txt doc/ref/guile.texi || exit 1

# тесты
# ./check-guile

make install DESTDIR="${TMP_DIR}"
[[ "x${DOCS}" == "xtrue" ]] && make install-html DESTDIR="${TMP_DIR}"

mv "${TMP_DIR}/usr/lib/libguile-"*-gdb.scm "${TMP_DIR}${LIBS}"

if [[ "x${DOCS}" == "xtrue" ]]; then
    mkdir -p "${TMP_DIR}${DOCS_DIR}"
    mv "${TMP_DIR}${DOCS_DIR}"/{guile.html,ref}
    mv "${TMP_DIR}${DOCS_DIR}"/r5rs{.html,}

    find examples -name "Makefile*" -delete
    cp -vR examples "${TMP_DIR}${DOCS_DIR}"

    for DIRNAME in ref r5rs; do
        install -v -m644 "doc/${DIRNAME}"/*.txt \
            "${TMP_DIR}${DOCS_DIR}/${DIRNAME}"
    done
    unset DIRNAME
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
