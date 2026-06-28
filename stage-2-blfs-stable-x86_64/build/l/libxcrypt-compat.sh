#! /bin/bash

PRGNAME="libxcrypt-compat"
ARCH_NAME="libxcrypt"

### libxcrypt-compat (Compatibility libxcrypt library for legacy binaries)
# Системная библиотека для безопасного шифрования и проверки паролей
# пользователей при входе в систему. Предоставляет функции хэширования (такие
# как SHA-512, bcrypt или Argon2) для защиты учетных записей от
# несанкционированного доступа.

# Required:    no
# Recommended: no
# Optional:    no

# ==============================================================================
# Пакет libxcrypt устанавливается в LFS (stage-3-build_basic_system). Данный
# пакет (libxcrypt-compat) предоставляет старую версию библиотеки шифрования
# паролей libcrypt.so.1, которая необходима для запуска бинарных и
# проприетарных программ (например, Apache OpenOffice), слинкованных со старыми
# версиями Glibc.
#
# Архитектурное решение и безопасность:
#    В базовой системе LFS пакет libxcrypt собирается с флагом:
#       --enable-obsolete-api=no
#    Это полностью отключает устаревший API, меняет SONAME на libcrypt.so.2
#    и гарантирует, что новые программы в системе не будут линковаться с
#    небезопасными и устаревшими функциями (fcrypt, encrypt, bigcrypt и др.).
#
#    Данный скрипт (libxcrypt-compat) собирает libxcrypt БЕЗ этого флага (по
#    умолчанию используется --enable-obsolete-api=yes/glibc). В результате
#    компилятор генерирует слой совместимости libcrypt.so.1.1.0.
#
# Хирургический split-пакет:
#    Чтобы не засорять систему и избежать конфликтов заголовков (*.h), манов,
#    файлов pkgconfig и основной системной библиотеки libcrypt.so.2, данный
#    скрипт НЕ использует стандартный 'make install' в DESTDIR. Вместо этого мы
#    вручную забираем из директории .libs исключительно два файла:
#       - реальную библиотеку libcrypt.so.1.1.0
#       - её soname-ссылку libcrypt.so.1
#
# Преимущества:
#    - Легаси-библиотека честно компилируется родным системным тулчейном.
#    - Идеальная чистота и изоляция: пакет ставится как жесткая runtime
#      зависимость только для тех программ, которые без него не запускаются,
#      например openoffice.
# ==============================================================================

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/lib"

# исправим сборку с glibc >=2.43
sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c || exit 1

./configure                      \
    --prefix=/usr                \
    --enable-hashes=strong,glibc \
    --disable-static             \
    --disable-failure-tokens || exit 1

make || exit 1

install -v -m755 .libs/libcrypt.so.1.1.0 "${TMP_DIR}/usr/lib/"
ln -s libcrypt.so.1.1.0 "${TMP_DIR}/usr/lib/libcrypt.so.1"

source "${ROOT}/stripping.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Compatibility libxcrypt library for legacy binaries)
#
# The Libxcrypt package contains a library for one-way hashing of passwords.
#
# Home page: https://github.com/besser82/${PRGNAME}/
# Download:  https://github.com/besser82/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
