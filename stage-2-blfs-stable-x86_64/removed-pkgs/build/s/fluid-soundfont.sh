#! /bin/bash

PRGNAME="fluid-soundfont"

### fluid-soundfont (Fluid General MIDI SoundFont)

# This is a GM SoundFont, for use with any modern MIDI synthesiser: hardware
# (like the emu10k1 sound card), or software (like FluidSynth).

# Required:    fluidsynth    (runtime)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

zcat ${SOURCES}/${PRGNAME}-${VERSION}.diff.gz | patch -p1 --verbose || exit 1

mkdir -p "${TMP_DIR}/etc/timidity" \
         "${TMP_DIR}/usr/bin"      \
         "${TMP_DIR}/usr/share/sounds/sf2"

cat << EOF > "${TMP_DIR}/usr/bin/fluidplay"
#!/bin/sh

SOUNDFONTS="/usr/share/sounds/sf2/FluidR3_GM.sf2 /usr/share/sounds/sf2/FluidR3_GS.sf2"

exec fluidsynth \$SOUNDFONTS "\$@"
EOF

chmod 0755 "${TMP_DIR}/usr/bin/fluidplay"

cp *.sf2 "${TMP_DIR}/usr/share/sounds/sf2/"

sed -e 's/\r//' debian/fluidr3_gm.cfg debian/fluidr3_gs.cfg \
    > "${TMP_DIR}/etc/timidity/fluid.cfg" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Fluid General MIDI SoundFont)
#
# This is a GM SoundFont, for use with any modern MIDI synthesiser: hardware
# (like the emu10k1 sound card), or software (like FluidSynth).
#
# Home page: https://packages.debian.org/sid/fluid-soundfont-gm
# Download:  https://ftp.debian.org/debian/pool/main/f/fluid-soundfont/fluid-soundfont_3.1.orig.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
