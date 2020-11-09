#! /bin/bash

PRGNAME="graphite2"

### Graphite2 (rendering engine for graphite fonts)
# Технология создания Юникод-совместимого смарт-шрифта и система рендеринга.
# Graphite основана на формате TrueType, и создаёт дополнительно три
# собственные таблицы данных, описывающие особенности системы письменности, а
# также создаёт правила изменения символов в зависимости от контекста,
# например, лигатур, замены или вставки глифов, диакритики, кернинга и
# выключки.

# http://www.linuxfromscratch.org/blfs/view/stable/general/graphite2.html

# Home page: http://graphite.sil.org/
# Download:  https://github.com/silnrsi/graphite/releases/download/1.3.13/graphite2-1.3.13.tgz

# Required: cmake
# Optional: freetype
#           python2
#           harfbuzz (циклическая зависимость: сначала нужно собрать graphite2 без harfbuzz, потом собрать harfbuzz и пересобрать graphite2)
#           asciidoc
#           doxygen
#           texlive или install-tl-unx
#           silgraphite (https://sourceforge.net/projects/silgraphite/files/silgraphite)
#           dblatex (для создания pdf документации) http://dblatex.sourceforge.net/
#           fonttools (python2 и python3 модули для тестов) https://pypi.org/project/fonttools/
#           graphite-font (https://scripts.sil.org/cms/scripts/page.php?site_id=projects&item_id=graphite_fonts)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/txt"

# если не установлен python3 модуль для fonttools, то некоторые тесты не
# проходят. Исправим:
sed -i '/cmptest/d' tests/CMakeLists.txt || exit 1

mkdir build &&
cd build || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    .. || exit 1

make || exit 1

ASCIIDOC=""
DOXYGEN=""
TEXLIVE=""
DBLATEX=""
BUILD_DOCS=""

command -v asciidoc &>/dev/null && ASCIIDOC="true"
command -v doxygen  &>/dev/null && DOXYGEN="true"
command -v texdoc   &>/dev/null && TEXLIVE="true"
command -v dblatex  &>/dev/null && DBLATEX="true"

# собираем документацию
if [[ -n "${ASCIIDOC}" || -n "${DOXYGEN}" || \
        -n "${TEXLIVE}" || -n "${DBLATEX}" ]]; then
    BUILD_DOCS="true"
    make docs || exit 1
fi

# make test

make install
make install DESTDIR="${TMP_DIR}"

# txt документация
install -vd -m755 "${DOCS}/txt"
cp -vf ../doc/{GTF,manual}.txt  "${DOCS}/txt"
cp -vf ../doc/{intro,building,calling,features,font,hacking,testing}.txt \
    "${DOCS}/txt"
cp -vf ../doc/{GTF,manual}.txt  "${TMP_DIR}${DOCS}/txt"
cp -vf ../doc/{intro,building,calling,features,font,hacking,testing}.txt \
    "${TMP_DIR}${DOCS}/txt"

# если собирали pdf и/или html документацию
if [ -n "${BUILD_DOCS}" ]; then
    cp -vf doc/{GTF,manual}.html "${DOCS}"
    cp -vf doc/{GTF,manual}.pdf  "${DOCS}"

    cp -vf doc/{GTF,manual}.html "${TMP_DIR}${DOCS}"
    cp -vf doc/{GTF,manual}.pdf  "${TMP_DIR}${DOCS}"
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (rendering engine for graphite fonts)
#
# Graphite is a system that can be used to create "smart fonts" capable of
# displaying writing systems with various complex behaviors. A smart font
# contains not only letter shapes but also additional instructions indicating
# how to combine and position the letters in complex ways. Graphite was
# primarily developed to provide the flexibility needed for minority languages
# which often need to be written according to slightly different rules than
# well-known languages that use the same script.
#
# Home page: http://graphite.sil.org/
# Download:  https://github.com/silnrsi/graphite/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
