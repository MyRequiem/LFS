#! /bin/bash

PRGNAME="startup-notification"

### startup-notification ("busy" cursors support)
# Библиотеки для уведомлений о запуске приложений с помощью курсора

# Required:    xorg-libraries
#              xcb-util
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

install -v -m644 -D "doc/${PRGNAME}.txt" \
    "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/${PRGNAME}.txt"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} ("busy" cursors support)
#
# The startup-notification package contains startup-notification libraries.
# These are useful for building a consistent manner to notify the user through
# the cursor that the application is loading.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
