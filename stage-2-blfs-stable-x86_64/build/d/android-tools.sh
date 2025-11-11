#! /bin/bash

PRGNAME="android-tools"

### android-tools (adb and fastboot tools)
# Инструменты ADB и Fastboot от Android SDK

# Required:    cmake
#              protobuf
#              fmt
#              gtest
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -d "vendor/extras" -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fix-protobuf-3x.x-build.patch" || exit 1

mkdir -p build
cd build || exit 1

cmake                                      \
    -D CMAKE_INSTALL_PREFIX=/usr           \
    -D CMAKE_BUILD_TYPE=Release            \
    -D CMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
    -D protobuf_MODULE_COMPATIBLE=ON       \
    -D ANDROID_TOOLS_LIBUSB_ENABLE_UDEV=ON \
    -D ANDROID_TOOLS_USE_BUNDLED_LIBUSB=ON \
    -G Ninja -Wno-dev                      \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (adb and fastboot tools)
#
# These are the adb and fastboot tools from the android sdk
#
# Home page: https://developer.android.com/sdk/
# Download:  https://github.com/nmeum/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
