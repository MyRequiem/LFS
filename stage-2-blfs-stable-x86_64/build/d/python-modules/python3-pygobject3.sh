#! /bin/bash

PRGNAME="python3-pygobject3"
ARCH_NAME="pygobject"

### PyGObject3 (GObject bindings for Python3)
# Python3 bindings для GObject

# Required:    gobject-introspection
#              python3-pycairo
#              python3
# Recommended: no
# Optional:    pep8             (https://pypi.org/project/pep8/)
#              pyflakes         (https://pypi.org/project/pyflakes/)
#              python3-pytest   (https://pypi.org/project/pytest/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-3*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

mkdir build
cd build || exit 1

meson             \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1

# тесты необходимо проводить в графической среде
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GObject bindings for Python3)
#
# This archive contains bindings for the GObject, to be used in Python. It is a
# fairly complete set of bindings, it's already rather useful, and is usable to
# write moderately complex programs.
#
# Home page: https://live.gnome.org/PyGObject
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
