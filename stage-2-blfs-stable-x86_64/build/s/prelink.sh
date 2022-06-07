#! /bin/bash

PRGNAME="prelink"

### prelink (ELF prelinking utility)
# Программа, которая модифицирует shared ELF библиотеки и динамически связаны
# двоичные файлы ELF. В итоге динамическому компоновщику требуется меньше
# времени для запуска программ.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --localstatedir=/var    \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

CONFIG="/etc/${PRGNAME}.conf"
cp "${SOURCES}/${PRGNAME}.conf" "${TMP_DIR}${CONFIG}"
chown root:root "${TMP_DIR}${CONFIG}"
chmod 644       "${TMP_DIR}${CONFIG}"

if [ -f "${CONFIG}" ]; then
    mv "${CONFIG}" "${CONFIG}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${CONFIG}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ELF prelinking utility)
#
# prelink is a program which modifies shared ELF libraries and dynamically
# linked ELF binaries so that the time the dynamic linker needs for their
# relocation at startup is significantly decreased. Also, due to fewer
# relocations, the run-time memory consumption of libraries/binaries is
# decreased.
#
# Home page: https://people.redhat.com/jakub/${PRGNAME}/
# Download:  http://people.redhat.com/jakub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
