#! /bin/bash

PRGNAME="libspectre"

### libspectre (ghostscript wrapper library)
# Библиотека-оболочка для ghostscript, которая используется для рендеринга
# Postscript документов. Предоставляет удобный, простой в использовании API для
# написания программ, обрабатывающих и отображающих Postscript документы.

# Required:    ghostscript
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --disable-static     \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ghostscript wrapper library)
#
# libspectre is a small wrapper library for ghostscript, which is used for
# rendering Postscript documents. The goal of libspectre is to provide a
# convenient, easy to use API for writing programs which handle and render
# Postscript documents.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://${PRGNAME}.freedesktop.org/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
