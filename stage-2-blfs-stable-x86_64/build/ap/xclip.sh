#! /bin/bash

PRGNAME="xclip"

### xclip (command-line interface to the X clipboard)
# Утилита командной строки, предоставляющая интерфейс для работы с X clipboard

# Required:    Graphical Environments
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -vif || exit 1

./configure       \
    --prefix=/usr \
    --with-x || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command-line interface to the X clipboard)
#
# xclip is a command line utility that is designed to run on any system with an
# X11 implementation. It provides an interface to X selections ("the
# clipboard") from the command line. It can read data from standard input or a
# file, and place it in an X selection for pasting into other X applications.
# xclip can also print an X selection to standard out, which can then be
# redirected to a file or another program.
#
# Home page: https://github.com/astrand/${PRGNAME}
# Download:  https://github.com/astrand/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
