#! /bin/bash

PRGNAME="python3-dbus"
ARCH_NAME="dbus-python"

### D-Bus Python (Python bindings for dbus)
# Обеспечивает привязку Python к API D-Bus интерфейса

# Required:    dbus
#              glib
#              python3-meson
#              patchelf
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links=dist   \
    --no-cache-dir      \
    --no-user           \
    "${ARCH_NAME}" || exit 1

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

INCLUDE="${TMP_DIR}/usr/include"
mv "${INCLUDE}/python${PYTHON_MAJ_VER}/dbus-python/dbus-1.0" \
    "${INCLUDE}"
rm -rf "${INCLUDE}/python${PYTHON_MAJ_VER}"

DBUS_PYTHON_MESONPY_LIBS=".dbus_python.mesonpy.libs"
mv "${TMP_SITE_PACKAGES}/${DBUS_PYTHON_MESONPY_LIBS}/pkgconfig" \
    "${TMP_DIR}/usr/lib/"

cd "${TMP_SITE_PACKAGES}" || exit 1
rm -rf "${DBUS_PYTHON_MESONPY_LIBS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python bindings for dbus)
#
# D-Bus Python provides Python bindings to the D-Bus API interface
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://dbus.freedesktop.org/releases/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
