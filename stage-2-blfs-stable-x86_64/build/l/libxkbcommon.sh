#! /bin/bash

PRGNAME="libxkbcommon"

### libxkbcommon (library to handle keyboard descriptions)
# Компилятор раскладки клавиатуры и вспомогательная библиотека, которая
# обрабатывает сокращенное подмножество раскладок клавиш, в соответствии со
# спецификацией XKB. В основном предназначен для клиентских инструментов,
# оконных менеджеров и других системных приложений.

# Required:    xkeyboard-config
# Recommended: libxcb
#              wayland
#              wayland-protocols
# Optional:    doxygen              (для сборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

ENABLE_DOCS="false"
ENABLE_WAYLAND="false"

# command -v doxygen &>/dev/null && ENABLE_DOCS="true"
[ -d /usr/share/wayland-protocols ] && ENABLE_WAYLAND="true"

mkdir build
cd build || exit 1

meson                                    \
    --prefix=/usr                        \
    --buildtype=release                  \
    -Denable-docs="${ENABLE_DOCS}"       \
    -Denable-wayland="${ENABLE_WAYLAND}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# по умолчанию документация устанавливается в /usr/share/doc/libxkbcommon,
# исправим
if [[ "x${ENABLE_DOCS}" == "xtrue" ]]; then
    mv "${TMP_DIR}/usr/share/doc/${PRGNAME}"{,"-${VERSION}"}
else
    rm -rf "${TMP_DIR}/usr/share/doc"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library to handle keyboard descriptions)
#
# libxkbcommon is a keymap compiler and support library which processes a
# reduced subset of keymaps as defined by the XKB specification. Primarily, a
# keymap is created from a set of Rules/Model/Layout/Variant/Options names,
# processed through an XKB ruleset, and compiled into a struct xkb_keymap,
# which is the base type for all xkbcommon operations. It's mainly meant for
# client toolkits, window systems, and other system applications.
#
# Home page: https://xkbcommon.org/
# Download:  https://xkbcommon.org/download/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
