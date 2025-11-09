#! /bin/bash

PRGNAME="poppler"

### Poppler (a library for rendering PDF documents)
# Библиотека, основанная на программе просмотра PDF-файлов xpdf, которая не
# предоставляет общую библиотеку. Осуществляет рендеринг PDF и предоставляет
# инструменты командной строки для работы с PDF файлами

# Required:    cmake
#              fontconfig
#              glib
# Recommended: boost
#              cairo
#              gpgmepp
#              lcms2
#              libjpeg-turbo
#              libpng
#              libtiff
#              nss
#              openjpeg
#              qt6              (для поддержки PDF в KDE'шной утилите Okular)
# Optional:    curl
#              gdk-pixbuf
#              git              (для загрузки тестовых файлов)
#              gtk-doc
#              gtk+3

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# сообщаем тестовым программам, где находятся вспомогательные файлы
#    -DTESTDATADIR="${PWD}/testfiles"
# устанавливаем старые заголовки Xpdf, необходимые для некоторых программ
#    -DENABLE_UNSTABLE_API_ABI_HEADERS=ON
cmake                                     \
    -D CMAKE_BUILD_TYPE=Release           \
    -D CMAKE_INSTALL_PREFIX=/usr          \
    -D TESTDATADIR="${PWD}/testfiles"     \
    -D ENABLE_QT5=OFF                     \
    -D ENABLE_UNSTABLE_API_ABI_HEADERS=ON \
    -G Ninja .. || exit 1

ninja || exit 1

### тесты
# Для тестов необходимы некоторые тестовые наборы, которые можно получить
# только из git-репозитория:
# git clone --depth 1 https://gitlab.freedesktop.org/poppler/test.git testfiles
#
# LC_ALL=en_US.UTF-8 ninja test

DESTDIR="${TMP_DIR}" ninja install

###
# Poppler Data
###
# файлы кодировок для правильного отображения кириллицы и CJK (китайский,
# японский и корейския языки)

POPPLER_DATA_ARCH="$(find "${SOURCES}" -type f -name "${PRGNAME}-data-*")"
POPPLER_DATA_VERSION="$(echo "${POPPLER_DATA_ARCH}" | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

cd .. || exit 1
tar -xvf "${POPPLER_DATA_ARCH}"              || exit 1
cd "${PRGNAME}-data-${POPPLER_DATA_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

make \
    prefix=/usr install DESTDIR="${TMP_DIR}" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a library for rendering PDF documents)
#
# Poppler is a library based on the xpdf PDF viewer developed by Derek Noonburg
# of Glyph and Cog, LLC. Since xpdf does not provide a shared library, whenever
# a flaw was found potentially dozens of applications incorporating code from
# xpdf would have to be patched. By providing a centralized PDF library this
# duplicated effort will be eliminated.
#
# Home page: https://${PRGNAME}.freedesktop.org
# Download:  https://${PRGNAME}.freedesktop.org/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
