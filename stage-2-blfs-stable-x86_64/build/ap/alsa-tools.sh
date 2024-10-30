#! /bin/bash

PRGNAME="alsa-tools"

### alsa-tools (advanced tools for various soundcards)
# Специальные инструменты для различных звуковых карт

# Required:    alsa-lib
# Recommended: no
# Optional:    gtk+2 (для сборки echomixer, envy24control и rmedigicontrol)
#              gtk+3 (для сборки hdajackretask)
#              fltk  (для сборки hdspconf и hdspmixer)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим инструмент qlo10k1 (ему нужен Qt2 или Qt3) и два ненужных файла
rm -rf qlo10k1 Makefile gitcompile

for TOOL in * ; do
    TOOL_DIR="${TOOL}"
    [[ "x${TOOL}" == "xseq" ]] && TOOL_DIR="${TOOL}/sbiload"

    pushd "${TOOL_DIR}" || exit 1

    ./configure \
        --prefix=/usr || {
            echo "Error configure ${TOOL} !!!"
            exit 1
        }

    make || {
        echo "Error make ${TOOL} !!!"
        exit 1
    }

    make install DESTDIR="${TMP_DIR}" || {
        echo "Error install tool ${TOOL} !!!"
        exit 1
    }

    popd || exit 1
done
unset TOOL TOOL_DIR

chmod 644 "${TMP_DIR}/etc/hotplug/usb/tascam_fw.usermap"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

/sbin/ldconfig

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (advanced tools for various soundcards)
#
# alsa-tools includes card-specific tools for various soundcards
#
# Home page: https://www.alsa-project.org/
# Download:  https://www.alsa-project.org/files/pub/tools/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
