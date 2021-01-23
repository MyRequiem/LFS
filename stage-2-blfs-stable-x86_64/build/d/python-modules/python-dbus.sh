#! /bin/bash

PRGNAME="python-dbus"
ARCH_NAME="dbus-python"

### D-Bus Python (Python bindings for dbus)
# Обеспечивает привязку Python к API D-Bus интерфейса

# Required:    python2
#              python3
#              dbus
#              glib
# Recommended: no
# Optional:    python-pygobject3
#              python-docutils
#              tap-py           (https://pypi.org/project/tap.py/)
#              sphinx           (https://www.sphinx-doc.org/en/master/)
#              sphinx-rtd-theme (https://github.com/readthedocs/sphinx_rtd_theme)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

### сборка Python2 модуля
mkdir python2
pushd python2 || exit 1

PYTHON=/usr/bin/python2 \
../configure            \
    --prefix=/usr       \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
popd || exit 1

# make -C python2 check

### сборка Python3 модуля
mkdir python3
pushd python3 || exit 1

PYTHON=/usr/bin/python3 \
../configure            \
    --prefix=/usr       \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
popd || exit 1

# make -C python3 check

make -C python2 install DESTDIR="${TMP_DIR}"
make -C python3 install DESTDIR="${TMP_DIR}"

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

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
