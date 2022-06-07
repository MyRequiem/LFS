#! /bin/bash

PRGNAME="uget"

### uGet (download manager with GTK GUI)
# Менеджер загрузок основанный на GTK+

# Required:    gtk+2
#              curl
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION_ORIG="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | rev | cut -d - -f 2-)"

VERSION="$(echo "${VERSION_ORIG}" | tr "-" "_")"
VERSION_MIN="$(echo "${VERSION}" | cut -d _ -f 1)"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION_ORIG}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION_MIN}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключаем раздражающие уведомления и звук по окончании загрузки
#    --disable-notify
#    --disable-gstreamer
CFLAGS="-O2 -fPIC -fcommon"   \
CXXFLAGS="-O2 -fPIC -fcommon" \
./configure                   \
    --prefix=/usr             \
    --sysconfdir=/etc         \
    --localstatedir=/var      \
    --disable-notify          \
    --disable-gstreamer       \
    --disable-rss-notify      \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (download manager with GTK GUI)
#
# uGet is a Free and Open Source download manager. It allows for queuing
# downloads, file type-based classification of downloads, and is lightweight.
#
# Home page: https://${PRGNAME}dm.com
# Download:  https://downloads.sourceforge.net/project/urlget/${PRGNAME}%20%28stable%29/${VERSION_MIN}/${PRGNAME}-${VERSION_ORIG}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
