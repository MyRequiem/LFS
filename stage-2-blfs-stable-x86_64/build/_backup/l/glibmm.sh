#! /bin/bash

PRGNAME="glibmm"

### GLibmm (C++ bindings for glib)
# Набор привязок C++ для glib, включая кроссплатформенные API, такие как как
# строковый класс UTF8 в стиле std::string, методы для обработки строк,
# например преобразование кодировки текста, доступ к файлам и потоки.

# http://www.linuxfromscratch.org/blfs/view/stable/general/glibmm.html

# Home page: http://www.gtkmm.org/
# Download:  http://ftp.gnome.org/pub/gnome/sources/glibmm/2.62/glibmm-2.62.0.tar.xz

# Required: glib
#           libsigc++2
# Optional: doxygen         (для создания документации)
#           glib-networking (для тестов)
#           gnutls          (для тестов)
#           libxslt

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим имя каталога с документацией
sed -e "/^libdocdir =/ s/\$(book_name)/${PRGNAME}-${VERSION}/" \
    -i docs/Makefile.in || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ bindings for glib)
#
# glibmm is a set of C++ bindings for glib, including cross-platform APIs such
# as a std::string-like UTF8 string class, string utility methods, such as a
# text encoding converter API, file access, and threads.
#
# Home page: http://www.gtkmm.org/
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
