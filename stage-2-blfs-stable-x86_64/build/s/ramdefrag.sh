#! /bin/bash

PRGNAME="ramdefrag"

### RAMDefrag (so-called Memory Defragmenter)
# Мультиплатформенный дефрагментатор/оптимизатор ОЗУ

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --localstatedir=/var    \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (so-called Memory Defragmenter)
#
# 'Multi Platform RAM Defragmentation' is a so-called Memory Defragmenter, also
# called RAM defragmenter, RAM/memory booster, RAM/memory optimizer, etc. By
# its visionary design, 'Multi Platform RAM Defragmentation' makes your
# computing platform run faster while simultaneously increasing system
# stability, and testers all over the world report that it also does a great
# job in delivering world peace and harmony.
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/project/${PRGNAME}/${PRGNAME}/${VERSION}/${PRGNAME}_${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
