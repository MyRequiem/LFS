#! /bin/bash

PRGNAME="libxcb"

### libxcb (X protocol C-language Binding)
# Библиотеки предоставляющие интерфейс для протокола XCB (X protocol C-language
# Binding), который полностью заменяет Xlib. Фактически, libX11 в наибольшей
# степени использует libxcb. В портировании на XCB есть несколько преимуществ,
# такие как использование меньшего объема памяти, скрытие задержки, прямой
# доступ по протоколу и улучшенная поддержка потоков.

# Required:    libxau
#              xcb-proto
# Recommended: libxdmcp
# Optional:    doxygen (для сборки документации)
#              libxslt

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOXYGEN="--without-doxygen"
# command -v doxygen &>/dev/null && DOXYGEN="--with-doxygen"

# shellcheck disable=SC2086
CFLAGS="${CFLAGS:--O2 -g} -Wno-error=format-extra-args" \
./configure        \
    ${XORG_CONFIG} \
    "${DOXYGEN}"   \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X protocol C-language Binding)
#
# The XCB library provides an interface to the X Window System protocol which
# is fully capable of replacing Xlib. In fact, libX11 makes use of libxcb as
# much as possible :-) Porting to XCB has several advantages such as a smaller
# memory footprint, latency hiding, direct protocol access, and improved thread
# support. Xlib can also use XCB as a transport layer, allowing software to
# make requests and receive responses with both.
#
# Home page: https://xcb.freedesktop.org/
# Download:  https://xorg.freedesktop.org/archive/individual/lib/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
