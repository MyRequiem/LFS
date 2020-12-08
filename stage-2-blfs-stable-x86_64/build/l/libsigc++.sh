#! /bin/bash

PRGNAME="libsigc++"

### libsigc++ (typesafe callback system for standard C++)
# Библиотека реализует систему безопасных обратных вызовов (callbacks) для
# стандарта C++

# Required:    no
# Recommended: no
# Optional:    doxygen (для сборки документации)
#              libxslt (для сборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим имя директории с документацией
sed -e "/^libdocdir =/ s/\$(book_name)/${PRGNAME}-${VERSION}/" -i \
    docs/Makefile.in || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (typesafe callback system for standard C++)
#
# libsigc++ implements a typesafe callback system for standard C++. It allows
# you to define signals and to connect those signals to any callback function,
# either global or a member function, regardless of whether it is static or
# virtual. It also contains adaptor classes for connection of dissimilar
# callbacks and has an ease of use unmatched by other C++ callback libraries.
#
# Home page: https://libsigcplusplus.github.io/libsigcplusplus/
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
