#! /bin/bash

PRGNAME="fftw"

### fftw (Fastest Fourier Transform in the West)
# Набор C подпрограмм для вычисления дискретных преобразований Фурье. Включает
# в себя сложные, реальные, симметричные и параллельные преобразования, а так
# же подпрограммы для эффективной обработки массивов произвольных размеров.
# FFTW обычно быстрее, чем другие общедоступные FFT.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/fftw.html

# Home page: http://www.fftw.org/
# Download:  http://www.fftw.org/fftw-3.3.8.tar.gz

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
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
    --enable-threads \
    --enable-sse2    \
    --enable-avx || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

# для float
make clean &&        \
./configure          \
    --prefix=/usr    \
    --enable-shared  \
    --enable-threads \
    --enable-sse2    \
    --enable-avx     \
    --enable-float || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

# для long double
make clean &&        \
./configure          \
    --prefix=/usr    \
    --enable-shared  \
    --enable-threads \
    --enable-long-double || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Fastest Fourier Transform in the West)
#
# FFTW is a free collection of fast C routines for computing the Discrete
# Fourier Transform (DFT) in one or more dimensions. It includes complex, real,
# symmetric, and parallel transforms, and can handle arbitrary array sizes
# efficiently. FFTW is typically faster than other publicly-available FFT
# implementations, and is even competitive with vendor-tuned libraries.
#
# Home page: http://www.fftw.org/
# Download:  http://www.fftw.org/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
