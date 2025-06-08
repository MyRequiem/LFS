#! /bin/bash

PRGNAME="fluidsynth"

### fluidsynth (real-time software synthesizer)


# FluidSynth is a real-time software synthesizer based on the Soundfont 2
# specifications. FluidSynth reads and handles MIDI events from the MIDI input
# device. It is the software analogue of a MIDI synthesizer. FluidSynth can
# also play midifiles using a Soundfont.

# Required:    cmake
# Recommended: glib
#              libsndfile
#              pulseaudio
#              dbus
#              readline
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

SLKCFLAGS="-O2 -fPIC" \
cmake                              \
    -DCMAKE_C_FLAGS="$SLKCFLAGS"   \
    -DCMAKE_CXX_FLAGS="$SLKCFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr    \
    -Denable-ladspa=ON             \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

mkdir -p "${TMP_DIR}/usr/share/soundfonts"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (real-time software synthesizer)
#
# FluidSynth is a real-time software synthesizer based on the Soundfont 2
# specifications. FluidSynth reads and handles MIDI events from the MIDI input
# device. It is the software analogue of a MIDI synthesizer. FluidSynth can
# also play midifiles using a Soundfont.
#
# Home page: https://www.fluidsynth.org/
# Download:  https://github.com/FluidSynth/fluidsynth/archive/refs/tags/v2.4.6.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
