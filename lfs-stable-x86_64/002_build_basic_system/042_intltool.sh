#! /bin/bash

PRGNAME="intltool"

### Intltool
# Инструменты интернационализации, используемый для извлечения из исходного
# кода файлов перевода программ на другие языки

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/intltool.html

# Home page: https://freedesktop.org/wiki/Software/intltool
# Download:  https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# исправим предупреждение, вызванное perl-5.22 и более поздними версиями
sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
make install DESTDIR="${TMP_DIR}"

# установим документацию
install -v -Dm644 doc/I18N-HOWTO \
    "/usr/share/doc/${PRGNAME}-${VERSION}/"
install -v -Dm644 doc/I18N-HOWTO \
    "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/"

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
