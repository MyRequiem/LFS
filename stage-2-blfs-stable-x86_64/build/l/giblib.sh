#! /bin/bash

PRGNAME="giblib"

### giblib (giblib utility library)
# Библиотека-обертка для imlib2. Предоставляет собой контекстную API оболочку.

# Required:    imlib2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                   \
    --prefix=/usr             \
    --disable-static          \
    --sysconfdir=/etc         \
    --with-imlib2-prefix=/usr \
    --localstatedir=/var || exit 1

make || exit 1
make docsdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (giblib utility library)
#
# giblib is a simple library which wraps imlib2. It provides a wrapper to
# imlib2's context API, avoiding all the context_get/set calls, adds fontstyles
# to the truetype renderer and supplies a generic doubly-linked list and some
# string functions.
#
# Home page: https://sourceforge.net/projects/slackbuildsdirectlinks/files/${PRGNAME}/
# Download:  https://sourceforge.net/projects/slackbuildsdirectlinks/files/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
