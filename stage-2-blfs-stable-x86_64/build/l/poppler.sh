#! /bin/bash

PRGNAME="poppler"

### Poppler (a library for rendering PDF documents)
# Библиотека, основанная на программе просмотра PDF-файлов xpdf, которая не
# предоставляет общую библиотеку. Осуществляет рендеринг PDF и предоставляет
# инструменты командной строки для работы с PDF файлами:
#    pdfattach   - добавляет новый встроенный файл к существующему файлу PDF
#    pdfdetach   - отображает наличие и извлекает встроенные файлы
#    pdffonts    - анализатор шрифтов
#    pdfimages   - извлекает изображения
#    pdfinfo     - отображает свойства документа
#    pdfseparate - извлечение отдельных страниц
#    pdfsig      - проверка цифровых подписей в PDF-документе
#    pdftocairo  - конвертер в форматы PNG, JPEG, PDF, PS (PostScript), EPS,
#                   SVG с использованием Cairo
#    pdftohtml   - конвертер в HTML
#    pdftoppm    - конвертер в изображения PPM, PNG, JPEG
#    pdftops     - конвертер в PS
#    pdftotext   - конвертер в текстовый файл
#    pdfunite    - объединение документов

# Required:    cmake
#              fontconfig
# Recommended: cairo
#              lcms2
#              libjpeg-turbo
#              libpng
#              nss
#              openjpeg
# Optional:    boost
#              curl
#              gdk-pixbuf
#              git          (для загрузки тестовых файлов)
#              gobject-introspection
#              gtk-doc
#              python3-pygments
#              gtk+3
#              libtiff
#              qt5          (для поддержки PDF в программе okular)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

TESTS="OFF"
INSTALL_DOCS="false"
GTK_DOC="OFF"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="ON"

mkdir build
cd build || exit 1

# используем для применения более высокого уровня оптимизации компилятора
#    -DCMAKE_BUILD_TYPE=Release
# сообщаем тестовым программам, где находятся вспомогательные файлы
#    -DTESTDATADIR="${PWD}/testfiles"
# устанавливаем старые заголовки Xpdf, необходимые для некоторых программ
#    -DENABLE_UNSTABLE_API_ABI_HEADERS=ON
cmake                                    \
    -DCMAKE_BUILD_TYPE=Release           \
    -DCMAKE_INSTALL_PREFIX=/usr          \
    -DTESTDATADIR="${PWD}/testfiles"     \
    -DBUILD_GTK_TESTS="${TESTS}"         \
    -DENABLE_GTK_DOC="${GTK_DOC}"        \
    -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
    .. || exit 1

make || exit 1

### тесты
# для запуска тестов нужно изменить переменную TESTS выше на 'ON'. Так же для
# тестов необходимы некоторые тестовые наборы, которые можно получить только из
# git-репозитория:
#
# git clone git://git.freedesktop.org/git/poppler/test testfiles
# LC_ALL=en_US.UTF-8
# make test

make install DESTDIR="${TMP_DIR}"

# документация
if [[ "x${INSTALL_DOCS}" == "xtrue" ]]; then
    DOCS_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d           "${TMP_DIR}${DOCS_PATH}"
    cp -vr ../glib/reference/html "${TMP_DIR}${DOCS_PATH}"
fi

###
# Poppler Data
###
# файлы кодировок для правильного отображения кириллицы и CJK (китайский,
# японский и корейския языки)

POPPLER_DATA_ARCH="$(find "${SOURCES}" -type f -name "${PRGNAME}-data-*")"
POPPLER_DATA_VERSION="$(echo "${POPPLER_DATA_ARCH}" | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

tar -xvf "${POPPLER_DATA_ARCH}"              || exit 1
cd "${PRGNAME}-data-${POPPLER_DATA_VERSION}" || exit 1

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
