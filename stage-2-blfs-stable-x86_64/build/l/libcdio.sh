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
# make check -k
make install DESTDIR="${TMP_DIR}"

# libcdio-paranoia зависит от libcdio, поэтому сразу устанавливаем в систему
# (пока не удаляем отладочную информацию из бинарников, т.к. поcле сборки и
# установки libcdio-paranoia во временную директорию мы все это перезапишем)
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# собираем  и устанавливаем libcdio-paranoia
LIB_PARANOIA="$(find "${SOURCES}" -type f -name "${PRGNAME}-paranoia-*")"
PARANOIA_VERSION="$(echo "${LIB_PARANOIA}" | rev | cut -d . -f 3- | \
    cut -d - -f 1 | rev)"

tar -xvf "${LIB_PARANOIA}"
cd "${PRGNAME}-paranoia-${PARANOIA_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
