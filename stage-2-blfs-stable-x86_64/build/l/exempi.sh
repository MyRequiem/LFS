#! /bin/bash

PRGNAME="exempi"

### Exempi (an implementation of Adobe's XMP)
# Реализация XMP (расширяемая платформа метаданных Adobe)

# Required:    ^boost
# Recommended: no
# Optional:    ^valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим тест, который зависит от проприетарного Adobe SDK
sed -i -r '/^\s?testadobesdk/d' exempi/Makefile.am || exit 1

autoreconf -fiv || exit 1
./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an implementation of Adobe's XMP)
#
# Exempi is an implementation of XMP (Adobe's Extensible Metadata Platform)
#
# Home page: https://wiki.freedesktop.org/libopenraw/Exempi/
# Download:  https://libopenraw.freedesktop.org/download/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
