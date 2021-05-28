#! /bin/bash

PRGNAME="libevdev"

### libevdev (wrapper library for evdev devices)
# Пакет содержит общие функции для Xorg input drivers

# Required:    no
# Recommended: no
# Optional:    doxygen
#              valgrind

### Конфигурация ядра
#    CONFIG_INPUT=y
#    CONFIG_INPUT_EVDEV=y
#    CONFIG_INPUT_MISC=y
#    CONFIG_INPUT_UINPUT=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure \
    ${XORG_CONFIG} || exit 1

make || exit 1

# Тесты должны запускаться при запущенном X-сервере. В некоторых системах тесты
# могут вызвать жесткую блокировку, что потребует перезагрузки машины. На
# ноутбуках система перейдет в спящий режим, и ее необходимо разбудить, чтобы
# завершить тестовые наборы.
# make check

make install DESTDIR="${TMP_DIR}"

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

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
