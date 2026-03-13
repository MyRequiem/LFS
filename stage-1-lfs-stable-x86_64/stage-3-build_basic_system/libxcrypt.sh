#! /bin/bash

PRGNAME="libxcrypt"

### libxcrypt (library for one-way hashing of passwords)
# Современная библиотека для шифрования и проверки паролей пользователей при
# входе в систему.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим сборку с glibc >=2.43
sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c || exit 1

# создаем надежные алгоритмы хеширования, рекомендуемые для случаев
# использования в целях безопасности, а также алгоритмы хеширования,
# предоставляемые традиционной Glibc libcrypt для обеспечения совместимости
#    --enable-hashes=strong,glibc
# отключим устаревшие функции API, которые не нужны для современной системы
# Linux, собранной из исходного кода
#    --enable-obsolete-api=no
# заставляет libxcrypt возвращать ошибку вместо «токена неудачи» - специальной
# зашифрованной строки, если при хешировании пароля произошел сбой или
# использован неизвестный алгоритм (в системе Linux на базе Glibc этот токен не
# требуется)
#    --disable-failure-tokens
./configure                      \
    --prefix=/usr                \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=no     \
    --disable-static             \
    --disable-failure-tokens || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for one-way hashing of passwords)
#
# The Libxcrypt package contains a modern library for one-way hashing of
# passwords
#
# Home page: https://github.com/besser82/${PRGNAME}/
# Download:  https://github.com/besser82/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
