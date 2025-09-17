#! /bin/bash

PRGNAME="alsa-tools"

### alsa-tools (advanced tools for various soundcards)
# Специальные инструменты для различных звуковых карт

# Required:    alsa-lib
# Recommended: no
# Optional:    gtk+3    (для сборки hdajackretask)
#              fltk     (для сборки hdspconf и hdspmixer)
#              gtk+2    (https://download.gnome.org/sources/gtk+/2.24/) для сборки echomixer, envy24control и rmedigicontrol

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим некоторые инструменты, которым нужен Qt2 или Qt3 или GTK+2, а также
# два ненужных файла
rm -rf qlo10k1 echomixer envy24control rmedigicontrol Makefile gitcompile

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

    # сразу уставливаем в систему
    make install || {
        echo "Error install tool ${TOOL} !!!"
        exit 1
    }

    make install DESTDIR="${TMP_DIR}" || {
        echo "Error install tool ${TOOL} !!!"
        exit 1
    }

    /sbin/ldconfig

    popd || exit 1
done
unset TOOL TOOL_DIR

chmod 644 "${TMP_DIR}/etc/hotplug/usb/tascam_fw.usermap"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
