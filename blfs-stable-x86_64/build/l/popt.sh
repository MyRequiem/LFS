#! /bin/bash

PRGNAME="popt"

### Popt (command line parsing library)
# C-библиотека для анализа параметров командной строки, используемая некоторыми
# программами для их разбора.

# http://www.linuxfromscratch.org/blfs/view/stable/general/popt.html

# Home page: http://freshmeat.sourceforge.net/projects/popt
# Download:  https://fossies.org/linux/misc/popt-1.16.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1

# для создания API документации требуется пакет doxygen
DOXYGEN=""
command -v doxygen &>/dev/null && DOXYGEN="true"
[ -n "${DOXYGEN}" ] && doxygen

# make check
make install
make install DESTDIR="${TMP_DIR}"

### установка документации, если она была собрана командой 'doxygen'
if [ -n "${DOXYGEN}" ]; then
    DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d "${DOCS}"
    install -v -m755 -d "${TMP_DIR}${DOCS}"
    install -v -m644 doxygen/html/* "${DOCS}"
    install -v -m644 doxygen/html/* "${TMP_DIR}${DOCS}"
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command line parsing library)
#
# Popt is a C library for parsing command line parameters and used by some
# programs to parse command-line options. Popt was popt: heavily influenced by
# the getopt() and getopt_long() functions, but it popt: improves on them by
# allowing more powerful argument expansion. Popt popt: can parse arbitrary
# argv[] style arrays and automatically set popt: variables based on command
# line arguments. Popt allows command line popt: arguments to be aliased via
# configuration files and includes utility popt: functions for parsing
# arbitrary strings into argv[] arrays using popt: shell-like rules.
#
# Home page: http://freshmeat.sourceforge.net/projects/${PRGNAME}
# Download:  https://fossies.org/linux/misc/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
