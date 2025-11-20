#! /bin/bash

PRGNAME="wireplumber"

### Wireplumber (session/policy manager for Pipewire)
# менеджер сессий для Pipewire

# Required:    elogind
#              glib
#              pipewire
# Recommended: lua
# Optional:    doxygen
#              python3-lxml
#              python3-sphinx
#              python3-sphinx-rtd-theme
#              breathe              (https://pypi.org/project/breathe/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D system-lua=true  \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

mv -v "${TMP_DIR}/usr/share/doc"/wireplumber{,-"${VERSION}"}

PIPEWIRE_LAUNCHER="/usr/bin/pipewire-launcher.sh"
cat << EOF > "${TMP_DIR}${PIPEWIRE_LAUNCHER}"
#!/bin/sh
# Begin ${PIPEWIRE_LAUNCHER}

# First, kill any previous instances of pipewire, wireplumber, or pipewire-pulse
# that are running. Multiple instances of the daemon can not be run at the same
# time, and this helps prevent possible errors if a user logs out or logs in
# too fast, and restores audio if Pipewire hangs and needs to be reset.

pkill -u \${USER} -fx /usr/bin/pipewire-pulse
pkill -u \${USER} -fx /usr/bin/wireplumber
pkill -u \${USER} -fx /usr/bin/pipewire

# Start Pipewire first.
exec /usr/bin/pipewire &

# Next, we need to wait until pipewire is up before starting wireplumber.
# This prevents a possible race condition where pipewire takes too long
# to start, as some users have run into.
while [ \$(pgrep -f /usr/bin/pipewire) = "" ]; do
   sleep 1
done

# Start Wireplumber now that Pipewire has been started.
exec /usr/bin/wireplumber &

# Start the Pulseaudio server included with Pipewire.
exec /usr/bin/pipewire-pulse &

# End ${PIPEWIRE_LAUNCHER}
EOF
chmod +x "${TMP_DIR}${PIPEWIRE_LAUNCHER}"

AUTOSTART="/etc/xdg/autostart"
mkdir -p "${TMP_DIR}${AUTOSTART}"
cat << EOF > "${TMP_DIR}${AUTOSTART}/pipewire.desktop"
[Desktop Entry]
Version=1.0
Name=Pipewire
Comment=Starts the Pipewire and Wireplumber daemons
# Exec=${PIPEWIRE_LAUNCHER}
Terminal=false
Type=Application
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (session/policy manager for Pipewire)
#
# The Wireplumber package contains a session and policy manager for Pipewire
#
# Home page: https://pipewire.pages.freedesktop.org/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/pipewire/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
