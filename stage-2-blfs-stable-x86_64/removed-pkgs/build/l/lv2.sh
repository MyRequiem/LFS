#! /bin/bash

PRGNAME="lv2"

### lv2 (LADSPA Version 2)
# Стандарт для обработки и генерации аудио. Является преемником Ladspa

# Required:    sord
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/profile.d"

mkdir build
cd build || exit 1

meson ..                          \
    --prefix=/usr                 \
    --buildtype=release           \
    --localstatedir=/var          \
    --sysconfdir=/etc             \
    -D lv2dir=/usr/lib/${PRGNAME} \
    -D docs=disabled              \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

PROFILE_LV2="/etc/profile.d/${PRGNAME}.sh"
cat << EOF > "${TMP_DIR}${PROFILE_LV2}"
#!/bin/sh

export LV2_PATH=/usr/lib/${PRGNAME}
EOF

chmod 0755 "${TMP_DIR}${PROFILE_LV2}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (LADSPA Version 2)
#
# LV2 is a standard for plugins and matching host applications, primarily
# targeted at audio processing and generation. LV2 is a successor to LADSPA,
# created to address the limitations of LADSPA which many applications have
# outgrown.
#
# Home page: https://lv2plug.in/
# Download:  https://lv2plug.in/spec/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
