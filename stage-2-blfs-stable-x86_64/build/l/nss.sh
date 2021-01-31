#! /bin/bash

PRGNAME="nss"

### NSS (Network Security Services)
# Набор библиотек, предназначенных для поддержки кроссплатформенной разработки
# защищенных клиент-серверных приложений c поддержкой SSL v2 и v3, TLS, PKCS#5,
# PKCS#7, PKCS#11, PKCS#12, сертификатов S/MIME, X.509 v3 и других стандартов
# безопасности.

# Required:    nspr
# Recommended: sqlite
#              p11-kit
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
NSS_INCLUDE_DIR="/usr/include/${PRGNAME}"
mkdir -pv "${TMP_DIR}"{/usr/{bin,lib/pkgconfig},"${NSS_INCLUDE_DIR}"}

patch -Np1 --verbose -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-standalone-1.patch" || exit 1

cd "${PRGNAME}" || exit 1

SQLITE=0
[ -f /usr/include/sqlite3.h ] && SQLITE=1

# не включать в бинарники отладочную информацию и использовать оптимизацию
# компилятора по умолчанию
#    BUILD_OPT=1
# расположение заголовочных файлов nspr
#    NSPR_INCLUDE_DIR=/usr/include/nspr
# связывать с zlib установленной в системе, а не с той, которая присутствует в
# дереве исходников
#    USE_SYSTEM_ZLIB=1
# указываем флаги компоновщика, необходимые для связи с библиотекой zlib
#    ZLIB_LIBS=-lz
make -j1                            \
    BUILD_OPT=1                     \
    USE_SYSTEM_ZLIB=1               \
    ZLIB_LIBS=-lz                   \
    NSS_ENABLE_WERROR=0             \
    USE_64=1                        \
    NSS_USE_SYSTEM_SQLITE=${SQLITE} \
    NSPR_INCLUDE_DIR=/usr/include/nspr || exit 1

# запуск тестов
# cd tests || exit 1
# HOST=localhost DOMSUF=localdomain ./all.sh || exit 1
# cd ../ || exit 1

cd ../dist || exit 1

# /usr/bin/
install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} "${TMP_DIR}/usr/bin"

# /usr/include/nss/
cp -vRL {public,private}/"${PRGNAME}"/* "${TMP_DIR}${NSS_INCLUDE_DIR}"
chmod -v 644 "${TMP_DIR}${NSS_INCLUDE_DIR}"/*

# /usr/lib/
install -v -m755 Linux*/lib/*.so              "${TMP_DIR}/usr/lib"
install -v -m644 Linux*/lib/{*.chk,libcrmf.a} "${TMP_DIR}/usr/lib"

# /usr/lib/pkgconfig/
install -v -m644 Linux*/lib/pkgconfig/nss.pc  "${TMP_DIR}/usr/lib/pkgconfig"

# ссылка /usr/lib/libnssckbi.so -> ./pkcs11/p11-kit-trust.so устанавливается с
# пакетом p11-kit, и если она уже существует, удалим ее
[ -L /usr/lib/libnssckbi.so ] && rm -f "${TMP_DIR}/usr/lib/libnssckbi.so"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

VER="${VERSION//./_}"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Network Security Services)
#
# Network Security Services (NSS) is a set of libraries designed to support
# cross-platform development of security-enabled client and server
# applications. Applications built with NSS can support SSL v2 and v3, TLS,
# PKCS #5, PKCS #7, PKCS #11, PKCS #12, S/MIME, X.509 v3 certificates, and
# other security standards.
#
# Home page: https://developer.mozilla.org/ru/docs/NSS
# Download:  https://archive.mozilla.org/pub/security/${PRGNAME}/releases/NSS_${VER}_RTM/src/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
