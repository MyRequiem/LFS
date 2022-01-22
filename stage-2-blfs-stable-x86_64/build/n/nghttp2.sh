#! /bin/bash

PRGNAME="nghttp2"

### nghttp2 (HTTP/2 implementation)
# Реализация HTTP/2 и его алгоритма сжатия заголовков

# Required:    no
# Recommended: libxml2
# Optional:    boost
#              c-ares
#              jansson
#              libevent
#              cunit     (требуется для тестов) http://cunit.sourceforge.net/
#              cython    (https://cython.org/)
#              jemalloc  (http://jemalloc.net/)
#              libev     (http://software.schmorp.de/pkg/libev.html)
#              mruby     (https://mruby.org/)
#              spdylay   (https://tatsuhiro-t.github.io/spdylay/)
#              sphinx    (https://www.sphinx-doc.org/en/master/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

# собираем только libnghttp2 (без этого параметра создаются примеры приложений,
# привязки Python и библиотека C++ asio)
#    --enable-lib-only
./configure           \
    --prefix=/usr     \
    --disable-static  \
    --enable-lib-only \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

[[ "x${DOCS}" == "xfalse" ]] &&
    rm -rf "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (HTTP/2 implementation)
#
# nghttp2 is an implementation of HTTP/2 and its header compression algorithm
# HPACK in C. The framing layer of HTTP/2 is implemented as a form of reusable
# C library
#
# Home page: https://${PRGNAME}.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
