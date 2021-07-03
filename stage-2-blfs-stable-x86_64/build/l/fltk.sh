#! /bin/bash

PRGNAME="fltk"

### FLTK (The Fast Light Tool Kit)
# Кросс-платформенная библиотека (Unix/Linux/Windows/MacOS) инструментов для
# построения графического интерфейса пользователя (GUI). Изначально создавалась
# для поддержки 3D графики и поэтому имеет встроенный интерфейс для OpenGL, но
# хорошо подходит и для программирования обычных интерфейсов пользователя.
# Библиотека использует свои собственные независимые системы виджетов, графики
# и событий, что позволяет писать программы одинаково выглядящие и работающие
# на разных операционных системах. В отличие от других подобных библиотек (Qt,
# GTK+, wxWidgets) FLTK ограничивается только графической функциональностью,
# поэтому она имеет малый размер, обычно компонуется статически, не использует
# сложных макросов, препроцессоров и продвинутых возможностей языка C++
# (шаблоны, исключения, пространства имен). Вкупе с малым размером кода, это
# облегчает использование библиотеки не очень искушенными пользователями.

# Required:    xorg-libraries
# Recommended: hicolor-icon-theme
#              libjpeg-turbo
#              libpng
# Optional:    alsa-lib
#              desktop-file-utils
#              doxygen
#              glu
#              mesa
#              texlive или install-tl-unx

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}-source"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

API_DOCS="false"

# man-страницы устанавливаем в /usr/share/man/ а не в /usr/share/man/cat*
sed -i -e '/cat./d' documentation/Makefile || exit 1

./configure       \
    --prefix=/usr \
    --enable-shared || exit 1

make || exit 1

[[ "x${API_DOCS}" == "xtrue" ]] && make -C documentation html

# NOTE: тесты для пакета интерактивны
# ./test/unittests
#
# кроме того, в каталоге ./test есть еще 70 исполняемых тестовых программ,
# которые можно запускать индивидуально

make docdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"
[[ "x${API_DOCS}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Fast Light Tool Kit)
#
# The Fast Light Tool Kit ("FLTK", pronounced "fulltick") is a a cross-
# platform C++ GUI toolkit for UNIX/Linux (X11), Windows, and MacOS X. FLTK
# provides modern GUI functionality without the bloat and supports 3D graphics
# via OpenGL and its built-in GLUT emulation. It was originally developed by
# Mr. Bill Spitzak and is currently maintained by a small group of developers
# across the world with a central repository in the US.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  http://${PRGNAME}.org/pub/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}-source.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
