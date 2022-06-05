#! /bin/bash

PRGNAME="gsimplecal"

### Gsimplecal (Simple and lightweight GTK calendar)
# Простой апплет-календарь, написанный на C++ с использованием GTK

# Required:    gtk+2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./autogen.sh || exit 1
./configure       \
    --prefix=/usr \
    --enable-gtk2 \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple and lightweight GTK calendar)
#
# Gsimplecal is a lightweight calendar applet written in C++ using GTK
#
# Home page: https://github.com/dmedvinsky/${PRGNAME}
# Download:  https://github.com/dmedvinsky/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
