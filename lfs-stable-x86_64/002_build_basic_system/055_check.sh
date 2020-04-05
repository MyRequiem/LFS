#! /bin/bash

PRGNAME="check"

### Check
# Фреймворк для тестов на C

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/check.html

# Home page: https://libcheck.github.io/check
# Download:  https://github.com/libcheck/check/releases/download/0.12.0/check-0.12.0.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
# устанавливаем пакет
DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
make docdir="${DOC_DIR}" install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make docdir="${DOC_DIR}" install DESTDIR="${TMP_DIR}"

# правим shebang скрипта checkmk
# '#! /tools/bin/gawk -f' --> '#! /usr/bin/gawk -f'
sed -i '1 s/tools/usr/' /usr/bin/checkmk
sed -i '1 s/tools/usr/' "${TMP_DIR}/usr/bin/checkmk"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (unit testing framework for C)
#
# Check is a unit testing framework for C.
#
# Home page: https://libcheck.github.io/${PRGNAME}
# Download:  https://github.com/libcheck/${PRGNAME}/releases/download/0.12.0/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
