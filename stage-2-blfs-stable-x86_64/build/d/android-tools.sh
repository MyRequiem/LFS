#! /bin/bash

PRGNAME="android-tools"

### android-tools (adb and fastboot tools)
# Официальный комплект консольных утилит для взаимодействия с мобильными
# устройствами на базе Android прямо из Linux. Сюда входят инструменты от
# Android SDK - adb и fastboot для отладки, прошивки и передачи файлов.

# Required:    cmake
#              protobuf
#              fmt
# Recommended: no
# Optional:    gtest        (https://github.com/google/googletest)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим ошибку сборки с protobuf-3x.x
patch --verbose -Np1 -d "vendor/extras" -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fix-protobuf-3x.x-build.patch" || exit 1

# отучим android-tools от зависимости gtest: подменим заголовок gtest_prod.h
# заглушкой (пакет gtest сделал в Optional, но на самом деле без следующих 3
# строк он Required)
mkdir -p vendor/libbase/include/gtest &&
    echo "#define FRIEND_TEST(test_case_name, test_name)" > \
    vendor/libbase/include/gtest/gtest_prod.h

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
