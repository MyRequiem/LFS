#! /bin/bash

PRGNAME="dtc"

### dtc (Device Tree Compiler for Flat Device Trees)
# Device Tree Compiler, dtc, takes as input a device-tree in a given format and
# outputs a device-tree in another format for booting kernels on embedded
# systems, transforms a textual description of a device tree (DTS) into a
# binary object (DTB).

# Required:    no
# Recommended: no
# Optional:    libyaml
#              swig         (для сборки Python3 модуля)
#              texlive

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# предотвращаем создание Python3 модуля с помощью устаревшего метода setup.py
# Далее мы создадим модуль с помощью pip3 wheel
#    -D python=disabled
meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D python=disabled  \
    .. || exit 1

ninja || exit 1

# тесты
# CC='gcc -Wl,-z,noexecstack' meson test -v

# сразу устанавливаем в систему для дальнейшей сборки Python3 модуля
ninja install
DESTDIR="${TMP_DIR}" ninja install

rm /usr/lib/libfdt.a

# соберем Python3 модуль
if command -v swig &>/dev/null; then
    pip3 wheel               \
        -w dist              \
        --no-build-isolation \
        --no-deps            \
        --no-cache-dir       \
        ..

    pip3 install            \
        --root="${TMP_DIR}" \
        --no-index          \
        --find-links dist   \
        --no-user           \
        libfdt
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Device Tree Compiler for Flat Device Trees)
#
# Device Tree Compiler, dtc, takes as input a device-tree in a given format and
# outputs a device-tree in another format for booting kernels on embedded
# systems, transforms a textual description of a device tree (DTS) into a
# binary object (DTB).
#
# Home page: https://git.kernel.org/cgit/utils/${PRGNAME}/${PRGNAME}.git
# Download:  https://kernel.org/pub/software/utils/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
