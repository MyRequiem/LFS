#! /bin/bash

PRGNAME="poppler"
PRG_DATA="${PRGNAME}-data"

### Poppler (a library for rendering PDF documents)
# Библиотека рендеринга PDF и инструменты командной строки для работы с PDF
# файлами. Пакет содержит файлы кодировок (poppler-data), которые используются
# Poppler. Эти файлы не являются обязательными, и Poppler автоматически читает
# их, если они присутствуют, что позволяем Poppler правильно отображать CJK и
# кириллицу.

# http://www.linuxfromscratch.org/blfs/view/stable/general/poppler.html

# Home page: http://poppler.freedesktop.org
# Download:  https://poppler.freedesktop.org/poppler-0.85.0.tar.xz
#            https://poppler.freedesktop.org/poppler-data-0.4.9.tar.gz

# Required:    cmake
#              fontconfig
# Recommended: cairo        (для сборки утилиты pdftocairo)
#              lcms2
#              libjpeg-turbo
#              libpng
#              nss
#              openjpeg
# Optional:    boost
#              curl
#              gdk-pixbuf
#              gobject-introspection
#              libtiff
#              git          (для загрузки тестовых файлов)
#              gtk-doc      (для сборки API-документации)
#              gtk+3        (для сборки libpoppler-glib.so)
#              qt5          (для сборки libpoppler-qt5.so и поддержки pdf в
#                            KDE'шном okular)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

mkdir build
cd build || exit 1

GTK_DOC="OFF"
CURL="OFF"

command -v gtkdoc-check &>/dev/null && GTK_DOC="ON"
command -v curl         &>/dev/null && CURL="ON"

# если в системе не установлен python2, то исправим скрипт сборки
# API-документации для python3
if [[ "${GTK_DOC}" == "ON" ]]; then
    if ! command -v python2 &>/dev/null; then
        sed -i '1s/python/&3/' make-glib-api-docs
    fi
fi

# используем более высокий уровень оптимизация компилятора
#    -DCMAKE_BUILD_TYPE=Release
# место будующего расположения вспомогательных файлы для тестов
#    -DTESTDATADIR="${PWD}/testfiles"
# устанавливаем старые заголовки xpdf, необходимые для некоторых программ
# (например, для Inkscape)
#    -DENABLE_UNSTABLE_API_ABI_HEADERS=ON
# устанавливаем API-документацию, если gtk-doc установлен в системе
#    -DENABLE_GTK_DOC="${GTK_DOC}"
cmake                                    \
    -DCMAKE_BUILD_TYPE=Release           \
    -DCMAKE_INSTALL_PREFIX=/usr          \
    -DTESTDATADIR="${PWD}/testfiles"     \
    -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
    -DENABLE_GTK_DOC="${GTK_DOC}"        \
    -DENABLE_LIBCURL="${CURL}"           \
    .. || exit 1

make || exit 1

# для запуска набора тестов необходимы некоторые тестовые наборы, которые можно
# получить только из git репозитория. Тестируются только Qt5 библиотеки.
# if command -v git &>/dev/null; then
#     export LC_ALL=en_US.UTF-8
#     make test
# fi

make install
make install DESTDIR="${TMP_DIR}"

# документация
install -v -m755 -d "${DOCS}"
cp -vr ../glib/reference/html "${DOCS}"
cp -vr ../glib/reference/html "${TMP_DIR}${DOCS}"

# Poppler Data
# ------------
PRG_VERSION="${VERSION}"
source "${ROOT}/unpack_source_archive.sh" "${PRG_DATA}" || exit 1
PRG_DATA_VERSION="${VERSION}"
VERSION="${PRG_VERSION}"

make prefix=/usr install                      || exit 1
make prefix=/usr install DESTDIR="${TMP_DIR}" || exit 1

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a library for rendering PDF documents)
#
# The Poppler package contains a PDF rendering library and command line tools
# used to manipulate PDF files. This is useful for providing PDF rendering
# functionality as a shared library.
#
# ${PRG_DATA} (data files used by poppler)
# Consists of encoding files for use with Poppler. The encoding files are
# optional and Poppler will automatically read them if they are present. When
# installed, they enable Poppler to render CJK and Cyrillic properly.
#
# Home page: http://${PRGNAME}.freedesktop.org
# Download:  https://${PRGNAME}.freedesktop.org/${PRGNAME}-${VERSION}.tar.xz
#            https://${PRGNAME}.freedesktop.org/${PRG_DATA}-${PRG_DATA_VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
