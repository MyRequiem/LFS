#! /bin/bash

PRGNAME="gettext"

### Gettext (internationalization framework)
# Утилиты для интернационализации и локализации, позволяющие программам
# компилироваться с NLS (Native Language Support), т.е. с поддержкой родного
# языка

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

chmod -v 0755 "${TMP_DIR}/usr/lib/preloadable_libintl.so"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (internationalization framework)
#
# The GNU gettext package contains "gettext" and "ngettext", programs that are
# used to internationalize the messages given by shell scripts. These allow
# programs to be compiled with NLS (Native Language Support), enabling them to
# output messages in the user's native language.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
