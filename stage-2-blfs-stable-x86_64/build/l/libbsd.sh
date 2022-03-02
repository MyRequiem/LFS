#! /bin/bash

PRGNAME="libbsd"

### libbsd (library of BSD functions)
# Библиотека предоставляющая полезные функции, часто встречающиеся в системах
# BSD, и отсутствующие в других. Упрощает портирование BSD проектов без
# необходимости встраивать один и тот же код снова и снова в каждом проекте.

# Required:    libmd
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --enable-static=no || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf libbsd.so.0 libbsd.so
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library of BSD functions)
#
# This library provides useful functions commonly found on BSD systems, and
# lacking on others like GNU systems, thus making it easier to port projects
# with strong BSD origins, without needing to embed the same code over and over
# again on each project.
#
# Home page: https://${PRGNAME}.freedesktop.org/wiki/
# Download:  https://${PRGNAME}.freedesktop.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
