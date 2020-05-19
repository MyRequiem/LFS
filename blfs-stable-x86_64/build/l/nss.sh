#! /bin/bash

PRGNAME="nss"

### NSS (Network Security Services)
# Набор библиотек, предназначенных для поддержки кроссплатформенной разработки
# защищенных клиент-серверных приложений c поддержкой SSL v2 и v3, TLS, PKCS#5,
# PKCS#7, PKCS#11, PKCS#12, сертификатов S/MIME, X.509 v3 и других стандартов
# безопасности.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/nss.html

# Home page: https://developer.mozilla.org/ru/docs/NSS
# Download:  https://archive.mozilla.org/pub/security/nss/releases/NSS_3_50_RTM/src/nss-3.50.tar.gz
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.1/nss-3.50-standalone-1.patch

# Required:    nspr
# Recommended: sqlite
#              p11-kit
# Optional:    no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr"/{bin,"include/${PRGNAME}",lib/pkgconfig}

patch -Np1 --verbose -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-standalone-1.patch" || exit 1

cd "${PRGNAME}" || exit 1

# пакет не поддерживает компиляцию в несколько потоков, поэтому явно указываем
# -j1
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
make -j1                    \
    BUILD_OPT=1             \
    USE_SYSTEM_ZLIB=1       \
    ZLIB_LIBS=-lz           \
    NSS_ENABLE_WERROR=0     \
    USE_64=1                \
    NSS_USE_SYSTEM_SQLITE=1 \
    NSPR_INCLUDE_DIR=/usr/include/nspr || exit 1

# тесты уже были запущены во время сборки

cd ../dist || exit 1

install -v -m755 Linux*/lib/*.so              /usr/lib
install -v -m755 Linux*/lib/*.so              "${TMP_DIR}/usr/lib"
install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib
install -v -m644 Linux*/lib/{*.chk,libcrmf.a} "${TMP_DIR}/usr/lib"

NSS_INCLUDE_DIR="/usr/include/${PRGNAME}"
install -v -m755 -d "${NSS_INCLUDE_DIR}"

cp -vRL {public,private}/"${PRGNAME}"/* "${NSS_INCLUDE_DIR}"
cp -vRL {public,private}/"${PRGNAME}"/* "${TMP_DIR}${NSS_INCLUDE_DIR}"
chmod -v 644 "${NSS_INCLUDE_DIR}"/*
chmod -v 644 "${TMP_DIR}${NSS_INCLUDE_DIR}"/*

install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin
install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} "${TMP_DIR}/usr/bin"

install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig
install -v -m644 Linux*/lib/pkgconfig/nss.pc  "${TMP_DIR}/usr/lib/pkgconfig"

VER=$(echo "${VERSION/./_}")
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
