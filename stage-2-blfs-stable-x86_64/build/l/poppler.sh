#! /bin/bash

PRGNAME="poppler"

### Poppler (a library for rendering PDF documents)
# Библиотека, основанная на программе просмотра PDF-файлов xpdf, которая не
# предоставляет общую библиотеку. Осуществляет рендеринг PDF и предоставляет
# инструменты командной строки для работы с PDF файлами

# Required:    cmake
#              fontconfig
#              gobject-introspection
# Recommended: boost
#              cairo
#              lcms2
#              libjpeg-turbo
#              libpng
#              nss
#              openjpeg
# Optional:    curl
#              gdk-pixbuf
#              git          (для загрузки тестовых файлов)
#              gtk-doc
#              gtk+3
#              libtiff
#              qt5          (для поддержки PDF в KDE'шной утилите Okular)
#              >= qt6.1     (https://download.qt.io/archive/qt/)

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
cmake                                    \
    -DCMAKE_BUILD_TYPE=Release           \
    -DCMAKE_INSTALL_PREFIX=/usr          \
    -DTESTDATADIR="${PWD}/testfiles"     \
    -DENABLE_GTK_DOC=OFF                 \
    -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
    .. || exit 1

make || exit 1

### тесты
# Для тестов необходимы некоторые тестовые наборы, которые можно получить
# только из git-репозитория:
# git clone --depth 1 https://gitlab.freedesktop.org/poppler/test.git testfiles
#
# LC_ALL=en_US.UTF-8 make test

make install DESTDIR="${TMP_DIR}"

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
# Home page: http://${PRGNAME}.freedesktop.org
# Download:  https://${PRGNAME}.freedesktop.org/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
