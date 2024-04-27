#! /bin/bash

PRGNAME="soundtouch"

### SoundTouch (Sound processing library)
# Библиотека обработки звука, которая позволяет изменять темп, высоту звука и
# скорость воспроизведения не зависимо друг от друга (например, можно изменить
# темп песни без изменения тональности)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# добавляем поддержку для запуска алгоритмов параллельно на нескольких ядрах
# процессора с использованием реализации OpenMP, который предоставляется GCC
#    --enable-openmp
./bootstrap &&
./configure         \
    --prefix=/usr   \
    --enable-openmp \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Sound processing library)
#
# soundtouch is an open-source audio processing library that allows changing
# the sound tempo, pitch and playback rate parameters independently from each
# other. Using it it's possible to for example change the tempo of a song,
# while the pitch stays the same.
#
# Home page: http://www.surina.net/${PRGNAME}
# Download:  https://gitlab.com/${PRGNAME}/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
