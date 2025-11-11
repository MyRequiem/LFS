#! /bin/bash

PRGNAME="libevdev"

### libevdev (wrapper library for evdev devices)
# Пакет содержит общие функции для Xorg input drivers

# Required:    no
# Recommended: no
# Optional:    doxygen
#              valgrind
#              check        (https://libcheck.github.io/check/)

### Конфигурация ядра
#    CONFIG_INPUT=y
#    CONFIG_INPUT_EVDEV=y
#    --- для тестов ---
#    CONFIG_INPUT_MISC=y
#    CONFIG_INPUT_UINPUT=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    -D documentation=disabled \
    -D tests=disabled || exit 1

ninja || exit 1

# Тесты должны запускаться при запущенном X-сервере. В некоторых системах тесты
# могут вызвать жесткую блокировку, что потребует перезагрузки машины. На
# ноутбуках система перейдет в спящий режим, и ее необходимо разбудить, чтобы
# завершить тестовые наборы. Должен быть установлен пакет 'check'
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (wrapper library for evdev devices)
#
# libevdev is a wrapper library for evdev devices. It moves the common tasks
# when dealing with evdev devices into a library and provides a library
# interface to the callers, thus avoiding erroneous ioctls, etc.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
