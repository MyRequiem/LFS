#! /bin/bash

PRGNAME="nspr"

### NSPR (Netscape Portable Runtime)
# Абстрактная платформо-независимая библиотека для не GUI объектов операционных
# систем.

# http://www.linuxfromscratch.org/blfs/view/stable/general/nspr.html

# Home page: https://developer.mozilla.org/ru/docs/NSPR
# Download:  https://archive.mozilla.org/pub/nspr/releases/v4.25/src/nspr-4.25.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd "${PRGNAME}" || exit 1

# отключаем установку двух ненужных скриптов
sed -ri 's#^(RELEASE_BINS =).*#\1#' pr/src/misc/Makefile.in || exit 1
# отключаем установку статических библиотек
sed -i  's#$(LIBRARY) ##' config/rules.mk || exit 1

# добавляем поддержку библиотек Mozilla (обязательно, если мы будем собирать
# какие-либо другие продукты Mozilla)
#    --with-mozilla
# использовать системную библиотеку pthread
#    --with-pthreads
./configure         \
    --prefix=/usr   \
    --with-mozilla  \
    --with-pthreads \
    --enable-64bit || exit 1

make || exit 1
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Netscape Portable Runtime)
#
# Netscape Portable Runtime (NSPR) provides a platform-neutral API for system
# level and libc like functions.
#
# Home page: https://developer.mozilla.org/ru/docs/NSPR
# Download:  https://archive.mozilla.org/pub/${PRGNAME}/releases/v${VERSION}/src/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
