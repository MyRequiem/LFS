#! /bin/bash

PRGNAME="nodejs"
ARCH_NAME="node"

### Node.js (JavaScript runtime)
# Среда выполнения кода JavaScript, построенная на движке Chrome V8 JavaScript.
# Node.js использует управляемую событиями неблокирующую модель ввода/вывода,
# которая делает его легким и эффективным. Пакетная система npm (Node Package
# Manager), является крупнейшей системой библиотек с открытым исходным кодом.

# Required:    which
# Recommended: c-ares
#              icu
#              libuv
#              nghttp2
# Optional:    http-parser (https://github.com/nodejs/http-parser)
#              npm         (если не установлен, будет собрана внутренняя копия npm) https://www.npmjs.com/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d v -f 2)"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

C_ARES=""
LIBUV=""
NGHTTP2=""
ICU="small-icu"
NPM=""
NPM_PKG="$(find /var/log/packages/ -type f -name "npm-[0-9]*")"

[ -x /usr/lib/libcares.so ]    && C_ARES="--shared-cares"
[ -x /usr/lib/libuv.so ]       && LIBUV="--shared-libuv"
[ -x /usr/lib/libnghttp2.so ]  && NGHTTP2="--shared-nghttp2"
[ -n "${NPM_PKG}" ]            && NPM="--without-npm"
command -v icuinfo &>/dev/null && ICU="system-icu"

./configure          \
    --prefix=/usr    \
    --shared-openssl \
    --shared-zlib    \
    ${C_ARES}        \
    ${LIBUV}         \
    ${NGHTTP2}       \
    ${NPM}           \
    --ninja          \
    --with-intl="${ICU}"|| exit 1

make || exit 1
# make test-only
make install DESTDIR="${TMP_DIR}"

# по умолчанию документация устанавливается в /usr/share/doc/node/
# создадим ссылку в /usr/share/doc/
#    ${PRGNAME}-${VERSION} -> node
(
    cd "${TMP_DIR}/usr/share/doc/" || exit 1
    ln -sfv node "${PRGNAME}-${VERSION}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (JavaScript runtime)
#
# Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine.
# Node.js uses an event-driven, non-blocking I/O model that makes it
# lightweight and efficient. Node.js' package ecosystem, npm, is the largest
# ecosystem of open source libraries in the world.
#
# Home page: https://nodejs.org/
# Download:  https://nodejs.org/dist/v${VERSION}/${ARCH_NAME}-v${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
