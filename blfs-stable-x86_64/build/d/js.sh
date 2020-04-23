#! /bin/bash

PRGNAME="js"
ARCH_NAME="mozjs"

### JS (Mozillas JavaScript engine)
# Движок Mozilla JavaScript, написанный на C. Включает в себя интерпретатор
# JavaScript и библиотеки.

# http://www.linuxfromscratch.org/blfs/view/stable/general/js60.html

# Home page: http://ftp.gnome.org/pub/gnome/teams/releng/tarballs-needing-help/mozjs/
# Download:  http://ftp.gnome.org/pub/gnome/teams/releng/tarballs-needing-help/mozjs/mozjs-60.8.0.tar.bz2

# Required: autoconf213
#           icu
#           python2
#           which
#           zip
# Optional: doxygen

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir mozjs-build
cd mozjs-build || exit 1

# jemalloc который содержит js конфликтует с malloc из glibc, поэтому отключаем
# его
#    --disable-jemalloc
# обязательно передаем в окружение переменную SHELL, иначе конфигурация
# завершится ошибкой
SHELL=/bin/bash &&     \
export SHELL    &&     \
../js/src/configure    \
    --prefix=/usr      \
    --with-intl-api    \
    --with-system-zlib \
    --with-system-icu  \
    --disable-jemalloc \
    --enable-readline || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
chmod 644 "/usr/lib/pkgconfig/mozjs-${MAJ_VERSION}.pc"
chmod 644 "${TMP_DIR}/usr/lib/pkgconfig/mozjs-${MAJ_VERSION}.pc"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Mozillas JavaScript engine)
#
# Mozillas JavaScript engine written in C. It include JavaScript interpreter
# and libraries.
#
# Home page: http://ftp.gnome.org/pub/gnome/teams/releng/tarballs-needing-help/${ARCH_NAME}/
# Download:  http://ftp.gnome.org/pub/gnome/teams/releng/tarballs-needing-help/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
