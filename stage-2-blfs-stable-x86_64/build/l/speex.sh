#! /bin/bash

PRGNAME="speex"

### Speex (an audio compression format designed for speech)
# Кодек для сжатия речевого сигнала, который может использоваться в приложениях
# «голос-через-интернет» (VoIP). Speex хорошо адаптирован для работы в
# Интернете и предоставляет полезные функции, которых нет в большинстве других
# кодеков.

# Required:    libogg
# Recommended: no
# Optional:    valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

# собираем утилиты 'speexenc' и 'speexdec'
#    --enable-binaries
./configure           \
    --prefix=/usr     \
    --disable-static  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

SPEEXDSP="speexdsp"
SPEEXDSP_ARCH="$(find "${SOURCES}" -type f -name "${SPEEXDSP}-*")"
SPEEXDSP_VERSION="$(echo "${SPEEXDSP_ARCH}" | rev | cut -d . -f 3- | \
    cut -d - -f 1 | rev)"

tar -xf "${SPEEXDSP_ARCH}"           || exit 1
cd "${SPEEXDSP}-${SPEEXDSP_VERSION}" || exit 1

./configure \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}/speexdsp" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

[[ "x${DOCS}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an audio compression format designed for speech)
#
# Speex is an Open Source/Free Software patent-free audio compression format
# designed especially for speech. The Speex Project aims to lower the barrier
# of entry for voice applications by providing a free alternative to expensive
# proprietary speech codecs. Moreover, Speex is well-adapted to Internet
# applications and provides useful features that are not present in most other
# codecs. Finally, Speex is part of the GNU Project and is available under the
# revised BSD license.
#
# Home page: https://${PRGNAME}.org
# Download:  https://downloads.xiph.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
