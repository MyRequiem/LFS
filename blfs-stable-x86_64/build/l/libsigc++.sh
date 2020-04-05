#! /bin/bash

PRGNAME="libsigc++"

### libsigc++
# Библиотека реализует систему безопасных обратных вызовов (callbacks) для
# стандарта C++

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libsigc.html

# Home page: https://libsigcplusplus.github.io/libsigcplusplus/
# Download:  http://ftp.gnome.org/pub/gnome/sources/libsigc++/2.10/libsigc++-2.10.2.tar.xz

# Required: no
# Optional: doxygen-1.8.16
#           libxslt-1.1.33 (for documentation)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим имя директории с документацией
sed -e "/^libdocdir =/ s/\$(book_name)/${PRGNAME}-${VERSION}/" -i \
    docs/Makefile.in

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

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
