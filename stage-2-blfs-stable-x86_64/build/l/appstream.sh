#! /bin/bash

PRGNAME="appstream"
ARCH_NAME="AppStream"

### AppStream (library for retrieving software metadata)
# Библиотека и утилита для получения метаданных о программном обеспечении в
# Linux. Позволяет центрам приложений (таким как GNOME Software или Discover)
# красиво отображать иконки, читать переведенные описания, искать и удобно
# устанавливать программы из разных источников.

# Required:    curl
#              elogind
#              itstool
#              libfyaml
#              libxml2
#              libxmlb
#              libxslt
# Recommended: docbook-xsl
# Optional:    python3-gi-docgen
#              qt6
#              daps                 (https://github.com/openSUSE/daps)
#              libstemmer           (https://github.com/zvelo/libstemmer)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
METAINFO="/usr/share/metainfo"
mkdir -pv "${TMP_DIR}${METAINFO}"

mkdir build
cd build || exit 1

meson setup ..               \
    --prefix=/usr            \
    --buildtype=release      \
    -D apidocs=false         \
    -D bash-completion=false \
    -D stemming=false        \
    -D systemd=false         \
    -D compose=false         \
    -D svg-support=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Пакет AppStream ожидает наличие файла метаинформации операционной системы,
# описывающий дистрибутив GNU/Linux, как описано в официальной сборке BLFS, но
# нам это нахрен не нужно в i3 или LXQt и никаких центров приложений мы не
# используем.

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for retrieving software metadata)
#
# The AppStream package contains a library and tool that is useful for
# retrieving software metadata and making it easily accessible to programs
# which need it
#
# Home page: https://www.freedesktop.org/wiki/Distributions/${ARCH_NAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
