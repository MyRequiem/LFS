#! /bin/bash

PRGNAME="timidity"
ARCH_NAME="TiMidity++"

### timidity (a software midi synthesizer)

# TiMidity++ is a software synthesizer.  It can play MIDI files by
# converting them into PCM waveform data or other various audio
# file formats.

# Required:    no
# Recommended: no
# Optional:    fluid-soundfont

### NOTE:
# перед запуском '/etc/rc.d/rc.timidity start' нужно загрузить модуль ядра:
#    # modprobe snd-seq
# либо добавить модуль для его автозагрузки в /etc/sysconfig/modules

nd-seq="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
RC_D="/etc/rc.d"
mkdir -pv "${TMP_DIR}${RC_D}"

patch -Np1 --verbose -i ${SOURCES}/${PRGNAME}-${VERSION}-autoconf.diff || exit 1

autoreconf -vif || exit 1

EXTRACFLAGS="-O2 -fPIC"                   \
./configure                               \
    --prefix=/usr                         \
    --sysconfdir=/etc                     \
    --localstatedir=/var                  \
    --disable-dependency-tracking         \
    --enable-alsaseq \
    --enable-audio=alsa \
    --with-default-output=alsa \
    --with-default-path="/etc/${PRGNAME}" \
    --with-xaw-resource-prefix=/etc/X11 || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

cp "${SOURCES}/rc.${PRGNAME}" "${TMP_DIR}${RC_D}"
chmod 755 "${TMP_DIR}${RC_D}/rc.${PRGNAME}"
chown root:root "${TMP_DIR}${RC_D}/rc.${PRGNAME}"

mkdir -p "${TMP_DIR}/etc/timidity/"
cat << EOF > "${TMP_DIR}/etc/timidity/timidity.cfg"
# This is the default configuration file for TiMidity.
# See timidity.cfg(5) for details.
trysource /etc/timidity/crude.cfg
trysource /etc/timidity/freepats.cfg
trysource /etc/timidity/eawpats.cfg
trysource /etc/timidity/fluid.cfg
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a software midi synthesizer)
#
# TiMidity++ is a software synthesizer.  It can play MIDI files by converting
# them into PCM waveform data or other various audio file formats.
#
# Home page: https://sourceforge.net/projects/timidity/
# Download:  https://sourceforge.net/projects/timidity/files/TiMidity++/TiMidity++-2.15.0/TiMidity++-2.15.0.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
