#! /bin/bash

PRGNAME="slop"

### slop (selection query)
# Утилита, запрашивающая выбор прямоугольной области экрана мышью

# Required:    glm
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# ошибка сборки с новыми версиями icu, поэтому отключим поддержку ICU, удалив
# диапозон строк 102-112 в CMakeLists.txt
sed '102,112 d;' -i CMakeLists.txt

cmake \
    -D CMAKE_INSTALL_PREFIX=/usr || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (selection query)
#
# slop (Select Operation) is an application that queries for a selection from
# the user and prints the region to stdout. It grabs the mouse and turns it
# into a crosshair, lets the user click and drag to make a selection (or click
# on a window) while drawing a pretty box around it, then finally prints the
# selection's dimensions to stdout.
#
# Home page: https://github.com/naelstrof/${PRGNAME}
# Download:  https://github.com/naelstrof/${PRGNAME}/archive/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
