#! /bin/bash

PRGNAME="python3-pygobject3"
ARCH_NAME="pygobject"

### PyGObject3 (GObject bindings for Python3)
# Python3 bindings для GObject

# Required:    glib
# Recommended: python3-pycairo
# Optional:    --- для тестов ---
#              gtk4
#              python3-pytest
#              python3-pep8     (https://pypi.org/project/pep8/)
#              python3-pyflakes (https://pypi.org/project/pyflakes/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# уберем два ошибочных теста
mv -v tests/test_gdbus.py{,.nouse}
mv -v tests/test_overrides_gtk.py{,.nouse}

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
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
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
