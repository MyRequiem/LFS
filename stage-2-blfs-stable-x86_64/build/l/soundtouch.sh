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
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

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
