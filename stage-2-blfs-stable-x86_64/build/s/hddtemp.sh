#! /bin/bash

PRGNAME="hddtemp"

### hddtemp (reads hard disk S.M.A.R.T. info and reports temperature)
# Утилита, предназначенная для чтения S.M.A.R.T. параметров жесткого диска и
# отчета о его температуре.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1,2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}".tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/"{"${PRGNAME}",rc.d/init.d}

patch --verbose -p1 -i "${SOURCES}/${PRGNAME}-${VERSION}.patch" || exit 1

./configure                 \
    --prefix=/usr           \
    --libdir=/usr/lib       \
    --sysconfdir=/etc       \
    --localstatedir=/var    \
    --mandir=/usr/share/man \
    --with-db-path="/etc/${PRGNAME}/${PRGNAME}.db" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

install -D -m 644 "${SOURCES}/${PRGNAME}.db" "${TMP_DIR}/etc/${PRGNAME}/"
install -D -m 754 "${SOURCES}/${PRGNAME}"    "${TMP_DIR}/etc/rc.d/init.d/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (reads hard disk S.M.A.R.T. info and reports temperature)
#
# hddtemp is a small and daemonizable utility designed to read the S.M.A.R.T.
# information from the given hard disk and report the temperature of the disk.
#
# Home page: https://savannah.nongnu.org/projects/${PRGNAME}/
# Download:  https://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
