#! /bin/bash

PRGNAME="fftw"

### fftw (Fastest Fourier Transform in the West)
# Набор C подпрограмм для вычисления дискретных преобразований Фурье. Включает
# в себя сложные, реальные, симметричные и параллельные преобразования, а так
# же подпрограммы для эффективной обработки массивов произвольных размеров.
# FFTW обычно быстрее, чем другие общедоступные FFT.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# пакет будем собирать три раза для разных библиотек с разными значениями
# точности для чисел:
#    - float       (32 битные числа одинарной точности)
#    - double      (64 битные числа двойной точности)
#    - long double (80 битные числа двойной расширенной точности)

# собирать libfftw3_threads.so (используется, например, плагином GIMP от GMIC)
#    --enable-threads
# для double (по умолчанию)
./configure          \
    --prefix=/usr    \
    --enable-shared  \
    --disable-static \
    --enable-threads \
    --enable-sse2    \
    --enable-avx     \
    --enable-avx2 || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# для float
make clean &&        \
./configure          \
    --prefix=/usr    \
    --enable-shared  \
    --disable-static \
    --enable-threads \
    --enable-sse2    \
    --enable-avx     \
    --enable-avx2    \
    --enable-float || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# для long double
make clean &&        \
./configure          \
    --prefix=/usr    \
    --enable-shared  \
    --disable-static \
    --enable-threads \
    --enable-long-double || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Fastest Fourier Transform in the West)
#
# FFTW is a free collection of fast C routines for computing the Discrete
# Fourier Transform (DFT) in one or more dimensions. It includes complex, real,
# symmetric, and parallel transforms, and can handle arbitrary array sizes
# efficiently. FFTW is typically faster than other publicly-available FFT
# implementations, and is even competitive with vendor-tuned libraries.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://www.${PRGNAME}.org/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
