#! /bin/bash

PRGNAME="doxygen"

### Doxygen (documentation generator)
# Кроссплатформенная система документирования исходного кода, которая
# поддерживает C++, Си, Objective-C, Python, Java, IDL, PHP, C#, Фортран, VHDL
# и, частично, D. Doxygen генерирует документацию на основе набора исходных
# текстов и также может быть настроен для извлечения структуры программы из
# недокументированных исходных кодов. Возможно составление графов зависимостей
# программных объектов, диаграмм классов и исходных кодов с гиперссылками.

# http://www.linuxfromscratch.org/blfs/view/stable/general/doxygen.html

# Home page: http://www.doxygen.nl/
# Download:  http://doxygen.nl/files/doxygen-1.8.17.src.tar.gz

# Required: cmake
#           git
# Optional: graphviz
#           ghostscript
#           libxml2 (для тестов)
#           llvm
#           python2
#           qt5 (для сборки doxywizard)
#           texlive или install-tl-unx
#           xapian (для сборки doxyindexer и doxysearch.cgi)

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="/root/src"
VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}-*.tar.?z*" \
    2>/dev/null | head -n 1 | rev | cut -d . -f 4- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}${MAN}"

mkdir -v build
cd build || exit 1

QT5GUI="OFF"
XAPIAN="OFF"
LLVM="OFF"

command -v assistant    &>/dev/null && QT5GUI="ON"
command -v xapian-check &>/dev/null && XAPIAN="ON"
command -v clang        &>/dev/null && LLVM="ON"

cmake                           \
    -G "Unix Makefiles"         \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Dbuild_wizard="${QT5GUI}"  \
    -Dbuild_search="${XAPIAN}"  \
    -Duse_libclang="${LLVM}"    \
    -Wno-dev \
    .. || exit 1

make || exit 1

# тест 012_cite.dox не проходит
# make tests

PYTHON2=""
TEXLIVE=""
GHOSTSCRIPT=""

command -v python2 &>/dev/null && PYTHON2="true"
command -v texdoc  &>/dev/null && TEXLIVE="true"
command -v gs      &>/dev/null && GHOSTSCRIPT="true"

# собираем документацию
if [[ -n "${PYTHON2}" && -n "${TEXLIVE}" && -n ${GHOSTSCRIPT} ]]; then
    cmake                                                   \
        -DDOC_INSTALL_DIR="share/doc/${PRGNAME}-${VERSION}" \
        -Dbuild_doc=ON                                      \
        .. || exit 1

    make docs || exit 1
fi

make install
make install DESTDIR="${TMP_DIR}"

# если мы собирали документацию, то man-страницы уже будут установлены
if ! [[ -n "${PYTHON2}" && -n "${TEXLIVE}" && -n ${GHOSTSCRIPT} ]]; then
    install -vm644 ../doc/*.1 "${MAN}"
    install -vm644 ../doc/*.1 "${TMP_DIR}${MAN}"
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (documentation generator)
#
# The Doxygen package contains a documentation system for C++, C, Java,
# Objective-C, Corba IDL and to some extent PHP, C# and D. It is useful for
# generating HTML documentation and/or an off-line reference manual from a set
# of documented source files. There is also support for generating output in
# RTF, PostScript, hyperlinked PDF, compressed HTML, and Unix man pages. The
# documentation is extracted directly from the sources, which makes it much
# easier to keep the documentation consistent with the source code. You can
# also configure Doxygen to extract the code structure from undocumented source
# files. This is very useful to quickly find your way in large source
# distributions. Used along with Graphviz, you can also visualize the relations
# between the various elements by means of include dependency graphs,
# inheritance diagrams, and collaboration diagrams, which are all generated
# automatically.
#
# Home page: http://www.doxygen.nl/
# Download:  http://doxygen.nl/files/${PRGNAME}-${VERSION}.src.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
