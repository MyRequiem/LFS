#! /bin/bash

PRGNAME="lcms2"

### Little CMS2 (Little Color Management System)
# Небольшая система (движок) управления цветом с акцентом на точность и
# производительность

# http://www.linuxfromscratch.org/blfs/view/9.0/general/lcms2.html

# Home page: http://www.littlecms.com/
# Download:  https://downloads.sourceforge.net/lcms/lcms2-2.9.tar.gz

# Required: no
# Optional: libjpeg-turbo
#           libtiff (для создания утилиты tificc)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# если мы будем запускать тесты, то сборка должна быть изменена так, чтобы
# сделать некоторые внутренние ссылки на библиотеки видимыми для тестового кода
sed -i '/AX_APPEND/s/^/#/' configure.ac || exit 1
autoreconf

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (little cms engine, version 2)
#
# The Little Color Management System is a small-footprint color management
# engine, with special focus on accuracy and performance. It uses the
# International Color Consortium standard (ICC), which is the modern standard
# for color management
#
# Home page: http://www.littlecms.com/
# Download:  https://downloads.sourceforge.net/lcms/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
