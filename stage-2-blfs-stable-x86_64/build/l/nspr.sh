#! /bin/bash

PRGNAME="nspr"

### NSPR (Netscape Portable Runtime)
# Набор базовых инструментов от Mozilla, которые обеспечивают независимость
# программ от операционной системы. Помогает софту работать с потоками,
# временем и вводом-выводом одинаково на разных платформах.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd "${PRGNAME}" || exit 1

# отключаем установку двух ненужных скриптов
sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in || exit 1
# отключаем установку статических библиотек
# shellcheck disable=SC2016
sed -i 's|$(LIBRARY) ||'  config/rules.mk         || exit 1

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
# набор тестов предназначен для тестирования изменений в nss или nspr и не
# особенно полезен для проверки выпущенной версии (например, его необходимо
# запускать на неоптимизированной сборке).
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Netscape Portable Runtime)
#
# Netscape Portable Runtime (NSPR) provides a platform-neutral API for system
# level and libc like functions.
#
# Home page: https://www-archive.mozilla.org/projects/${PRGNAME}/
# Download:  https://archive.mozilla.org/pub/${PRGNAME}/releases/v${VERSION}/src/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
