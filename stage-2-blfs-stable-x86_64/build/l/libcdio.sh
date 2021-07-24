#! /bin/bash

PRGNAME="libcdio"

### libcdio (GNU Compact Disc Input and Control Library)
# Библиотеки для доступа к CD-ROM и образам компакт-дисков. Связанная
# библиотека libcdio-cdparanoia считывает звук с CD-ROM напрямую как данные,
# без аналогового шага между ними и записывает данные в файл или канал как
# .wav, .aifc или как необработанный 16-битный линейный PCM

# Required:    no
# Recommended: no
# Optional:    libcddb

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# libcdio-paranoia зависит от libcdio, поэтому сразу устанавливаем в систему
source "${ROOT}/stripping.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# собираем  и устанавливаем libcdio-paranoia
LIB_PARANOIA="$(find "${SOURCES}" -type f -name "${PRGNAME}-paranoia-*")"
PARANOIA_VERSION="$(echo "${LIB_PARANOIA}" | rev | cut -d . -f 3- | \
    cut -d - -f 1 | rev)"

TMP_DIR_PARANOIA="${BUILD_DIR}/package-${PRGNAME}-paranoia-${PARANOIA_VERSION}"
mkdir -pv "${TMP_DIR_PARANOIA}"

cd "${BUILD_DIR}" || exit 1
tar -xvf "${LIB_PARANOIA}"
cd "${PRGNAME}-paranoia-${PARANOIA_VERSION}" || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR_PARANOIA}"

# stripping
BINARY="$(find "${TMP_DIR_PARANOIA}" -type f -print0 | \
    xargs -0 file 2>/dev/null | /bin/grep -e "executable" -e "shared object" | \
    /bin/grep ELF | /bin/grep -v "32-bit" | cut -f 1 -d :)"

for BIN in ${BINARY}; do
    strip --strip-unneeded "${BIN}"
done

/bin/cp -vpR "${TMP_DIR_PARANOIA}"/* /

/bin/cp -vpR "${TMP_DIR_PARANOIA}"/* "${TMP_DIR}"/

source "${ROOT}/update-info-db.sh" || exit 1

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Compact Disc Input and Control Library)
#
# The libcdio is a library for CD-ROM and CD image access. The associated
# libcdio-cdparanoia library reads audio from the CD-ROM directly as data, with
# no analog step between, and writes the data to a file or pipe as .wav, .aifc
# or as raw 16 bit linear PCM.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#            https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-paranoia-${PARANOIA_VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
