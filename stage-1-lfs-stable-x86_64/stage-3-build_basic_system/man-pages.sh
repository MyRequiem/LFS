#! /bin/bash

PRGNAME="man-pages"

### Man-pages (system documentation)
# Содержит более 2300 man-страниц, описывающие функции языка C, основные файлы
# устройств, важные файлы конфигурации и т.д. Страницы устанавливаются в
# /usr/share/man/man{1,2,3,4,5,6,7,8}/*

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# удалим две man-страницы для функций хеширования паролей, libxcrypt
# предоставит лучшую версию этих страниц руководства
rm -vf man3/crypt*

# предотвратим создание любых встроенных переменных
#    -R
make          \
    -R        \
    GIT=false \
    prefix=/usr install DESTDIR="${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (system documentation)
#
# Man pages are online documentation for Linux (contains over 2300 man pages).
# This package includes many section 1, 2, 3, 4, 5, 7, and 8 man pages for
# Linux.
#
# Home page: https://www.kernel.org/doc/${PRGNAME}/
# Download:  https://www.kernel.org/pub/linux/docs/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
