#! /bin/bash

PRGNAME="intltool"

### Intltool
# Инструменты интернационализации, используемый для извлечения из исходного
# кода файлов перевода программ на другие языки

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/intltool.html

# Home page: https://freedesktop.org/wiki/Software/intltool
# Download:  https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

# исправим предупреждение, вызванное perl-5.22 и более поздними версиями
sed -i 's:\\\${:\\\$\\{:' intltool-update.in || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install
make install DESTDIR="${TMP_DIR}"

# установим документацию
install -d -m755                 "${DOCS}"
install -v -Dm644 doc/I18N-HOWTO "${DOCS}"
install -v -Dm644 doc/I18N-HOWTO "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Utilities for translation support)
#
# The Intltool is an internationalization tool (scripts and autoconf files)
# used for extracting translatable strings from source files.
#
# Home page: https://freedesktop.org/wiki/Software/${PRGNAME}
# Download:  https://launchpad.net/${PRGNAME}/trunk/${VERSION}/+download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
