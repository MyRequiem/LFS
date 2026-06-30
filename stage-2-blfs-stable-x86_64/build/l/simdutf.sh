#! /bin/bash

PRGNAME="simdutf"

### simdutf (Unicode validation and transcoding library)
# Сверхбыстрая библиотека для проверки, конвертации и обработки различных
# кодировок текста (UTF-8, UTF-16, UTF-32) и формата Base64. Она использует
# специальные векторные инструкции процессора (SIMD), что позволяет
# обрабатывать миллиарды символов в секунду и кратно ускорять работу с текстом
# в таких проектах, как Node.js, Chromium и Bun.

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                             \
    -D CMAKE_INSTALL_PREFIX=/usr  \
    -D CMAKE_BUILD_TYPE=Release   \
    -D BUILD_SHARED_LIBS=ON       \
    -G Ninja .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Unicode validation and transcoding library)
#
# simdutf is a very fast library for Unicode validation, transcoding (UTF-8,
# UTF-16, UTF-32), and base64 processing. It uses SIMD instructions (AVX2,
# AVX-512, NEON) to achieve speeds of billions of characters per second.
#
# This library powers core tools like Node.js, Bun, and Chromium.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
