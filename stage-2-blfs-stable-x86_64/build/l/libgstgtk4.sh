#! /bin/bash

PRGNAME="libgstgtk4"
ARCH_NAME="gst-plugins-rs-gstreamer"

### libgstgtk4 (GTK-4 Gstreamer Multimedia Framework)
# Библиотека для связывания Gstreamer Multimedia Framework с GTK-4

# Required:    git
#              gst-plugins-base
#              gtk4
#              rustc
# Recommended: no
# Optional:    no

###
# NOTE
###
#    Для сборки требуется сеть Internet, поэтому СОБИРАЕМ ТОЛЬКО В ЧИСТОЙ LFS
#    системе (не в chroot хоста)
###
#
# После установки пакета можно проверить его основную функциональность в
# графическом терминале:
#    $ gst-launch-1.0 videotestsrc num-buffers=60 ! gtk4paintablesink
# Должно воспроизводиться тестовое видео в окне GTK-4 в течение 2 секунд

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/lib/gstreamer-1.0"

cd video/gtk4         || exit 1
cargo build --release || exit 1
# пакет не имеет набора тестов
install -vm755 ../../target/release/libgstgtk4.so \
    "${TMP_DIR}/usr/lib/gstreamer-1.0/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK-4 Gstreamer Multimedia Framework)
#
# The libgstgtk4 package contains a library that binds the gstreamer multimedia
# framework to GTK-4
#
# Home page: https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/
# Download:  https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/-/archive/gstreamer-${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
