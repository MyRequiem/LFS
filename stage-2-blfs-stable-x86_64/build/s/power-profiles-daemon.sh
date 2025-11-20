#! /bin/bash

PRGNAME="power-profiles-daemon"

### Power-profiles-daemon (modification of the system power/behavior state)
# Утилита, позволяющая изменять состояния питания/поведения системы.
# Используется на многих ноутбуках для активации энергосбережения или повышения
# производительности ЦП

# Required:    polkit
#              python3-pygobject3
#              upower
# Recommended: no
# Optional:    gtk-doc
#              python3-dbusmock
#              umockdev
#              isort                    (https://github.com/PyCQA/isort)
#              mccabe                   (https://github.com/PyCQA/mccabe)

### Конфигурация ядра
#    CPU_FREQ=y
#    CPU_FREQ_GOV_PERFORMANCE=y
#    CPU_FREQ_GOV_POWERSAVE=y|m
#    X86_INTEL_PSTATE=y
#    X86_AMD_PSTATE=y
#    X86_PLATFORM_DEVICES=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                      \
    --prefix=/usr                \
    --buildtype=release          \
    -D gtk_doc=false             \
    -D tests=false               \
    -D systemdsystemunitdir=/tmp \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# каталог, необходимый для хранения состояния питания
install -vdm755 "${TMP_DIR}/var/lib/${PRGNAME}"

rm -rf "${TMP_DIR}/tmp"

# установим загрузочный скрипт
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-power-profiles-daemon DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (modification of the system power/behavior state)
#
# The Power-profiles-daemon package provides a program that allows modification
# of the system power/behavior state. This is used on many laptops and can be
# used by a Desktop Environment to activate power saving or performance CPU
# governors through dbus. On other systems, Power-profiles-daemon can be used
# as a streamlined way to set the CPU governor in order to increase system
# performance at the cost of energy usage
#
# Home page: https://gitlab.freedesktop.org/upower/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/upower/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
