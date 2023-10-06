#! /bin/bash

PRGNAME="xcb-proto"

### xcb-proto (X protocol C-language Binding protocol descriptions)
# Пакет предоставляет описания протокола XML-XCB, которые libxcb использует для
# генерирования большей части своего кода и API

# Required:    no
# Recommended: no
# Optional:    libxml2 (для запуска тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
PYTHON=python3 \
./configure    \
    ${XORG_CONFIG} || exit 1

# make check
make install DESTDIR="${TMP_DIR}"

# при обновлении пакета до версии >1.15.1 нужно удалить
# /usr/lib/pkgconfig/xcb-proto.pc, т.к. он будет установлен в
# /usr/share/pkgconfig
rm -f "${XORG_PREFIX}/lib/pkgconfig/${PRGNAME}.pc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X protocol C-language Binding protocol descriptions)
#
# xcb-proto provides the XML-XCB protocol descriptions that libxcb uses to
# generate the majority of its code and API. We provide them separately from
# libxcb to allow reuse by other projects, such as additional language
# bindings, protocol dissectors, or documentation generators.
#
# Home page: https://xcb.freedesktop.org/
# Download:  https://xorg.freedesktop.org/archive/individual/proto/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
