#! /bin/bash

PRGNAME="brotli"

### brotli (general-purpose lossless compression algorithm)
# Современный алгоритм сжатия данных, который делает файлы намного меньше без
# потери качества, чтобы они быстрее передавались по сети. Он эффективнее
# старого формата GZIP, поэтому веб-страницы с ним загружаются быстрее, а
# мобильный трафик расходуется экономнее.

# Required:    cmake
# Recommended: no
# Optional:    python3-pytest (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -G Ninja .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# сразу устанавливаем пакет в систему для сборки Python3 bindings
source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cd .. || exit 1

# Python3 bindings
# разрешить создание привязки Python3 с USE_SYSTEM_BROTLI=1, но без
# установленного модуля pkgconfig Python 3
sed -e '/libraries +=/s/=.*/= [required_system_library[3:]]/' \
    -e '/package_configuration/d'                             \
    -e '/pkgconfig/d'                                         \
    -i setup.py || exit 1

# удалим Python3 модули, если уже установлены
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
rm -rf "/usr/lib/python${PYTHON_MAJ_VER}/site-packages/__pycache__/brotli"*
rm -rf "/usr/lib/python${PYTHON_MAJ_VER}/site-packages/"/{,_}brotli*

USE_SYSTEM_BROTLI=1      \
pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
    --no-user           \
    Brotli || exit 1

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (general-purpose lossless compression algorithm)
#
# Brotli is a generic-purpose lossless compression algorithm that compresses
# data using a combination of a modern variant of the LZ77 algorithm, Huffman
# coding and 2nd order context modeling, with a compression ratio comparable to
# the best currently available general-purpose compression methods. It is
# similar in speed with deflate but offers more dense compression.
#
# Home page: https://github.com/google/${PRGNAME}
# Download:  https://github.com/google/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
