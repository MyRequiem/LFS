#! /bin/bash

PRGNAME="intltool"

### Intltool (Utilities for translation support)
# Инструменты интернационализации, используемый для извлечения из исходного
# кода файлов перевода программ на другие языки

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим предупреждение, вызванное perl-5.22 и более поздними версиями
# '\${' --> '\$\{'
sed -i 's:\\\${:\\\$\\{:' intltool-update.in || exit 1

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# установим документацию
install -v -Dm644 doc/I18N-HOWTO \
    "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/I18N-HOWTO"

/bin/cp -vR "${TMP_DIR}"/* /

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
