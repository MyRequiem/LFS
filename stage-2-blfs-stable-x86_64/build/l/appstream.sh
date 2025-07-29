#! /bin/bash

PRGNAME="appstream"
ARCH_NAME="AppStream"

### AppStream (library for retrieving software metadata)
# библиотека и утилита, полезные для получение метаданных программного
# обеспечения и легкого доступа к ним для программ, которым это необходимо

# Required:    curl
#              elogind
#              itstool
#              libxml2
#              libxmlb
#              libyaml
# Recommended: no
# Optional:    python3-gi-docgen
#              qt6
#              daps          (https://github.com/openSUSE/daps)
#              libstemmer    (https://github.com/zvelo/libstemmer)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
METAINFO="/usr/share/metainfo"
mkdir -pv "${TMP_DIR}${METAINFO}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D apidocs=false    \
    -D stemming=false   \
    -D qt=true          \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
find   "${TMP_DIR}/usr/share/man/" -type f -exec chmod 644 {} \;

###
# Конфигурация
###

# конфиг
#    /usr/share/metainfo/org.linuxfromscratch.lfs.xml

# Пакет AppStream ожидает наличие файла метаинформации операционной системы,
# описывающий дистрибутив GNU/Linux:

cat > "${TMP_DIR}${METAINFO}/org.linuxfromscratch.lfs.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="operating-system">
  <id>org.linuxfromscratch.lfs</id>
  <name>Linux From Scratch</name>
  <summary>A customized Linux system built entirely from source</summary>
  <description>
    <p>
      Linux From Scratch (LFS) is a project that provides you with
      step-by-step instructions for building your own customized Linux
      system entirely from source.
    </p>
  </description>
  <url type="homepage">https://www.linuxfromscratch.org/lfs/</url>
  <metadata_license>MIT</metadata_license>
  <developer id='linuxfromscratch.org'>
    <name>The Linux From Scratch Editors</name>
  </developer>

  <releases>
    <release version="12.3" type="release" date="2025-03-05">
      <description>
        <p>Now contains Binutils 2.44, GCC-14.2.0, Glibc-2.41,
        and Linux kernel 6.13.12</p>
      </description>
    </release>

    <release version="12.1" type="stable" date="2024-03-01">
      <description>
        <p>Now contains Binutils 2.42, GCC-13.2.0, Glibc-2.39,
        and Linux kernel 6.7.</p>
      </description>
    </release>
  </releases>
</component>
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
