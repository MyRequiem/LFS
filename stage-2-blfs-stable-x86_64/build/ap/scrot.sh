#! /bin/bash

PRGNAME="scrot"

### scrot (commandline screen capture program)
# scrot (SCReenshOT) - утилита захвата экрана из командной строки, использующая
# библиотеку imlib2

# Required:    imlib2
#              giblib
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson \
    --prefix=/usr || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# удалим ненужные директории
#    /usr/share/doc
#    /usr/share/licenses
(
    cd "${TMP_DIR}/usr/share/" || exit 1
    rm -rf doc licenses
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (commandline screen capture program)
#
# scrot (SCReenshOT) is a commandline screen capture util like "import", but
# using the imlib2 library. It has lots of options for autogenerating
# filenames, and can do fun stuff like taking screenshots of multiple displays
# and glueing them together
#
# Home page: https://github.com/dreamer/${PRGNAME}
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
