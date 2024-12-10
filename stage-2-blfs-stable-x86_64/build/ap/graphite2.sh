#! /bin/bash

PRGNAME="graphite2"

### Graphite2 (rendering engine for graphite fonts)
# Технология создания Юникод-совместимого смарт-шрифта и система рендеринга.
# Graphite основана на формате TrueType, и создаёт дополнительно три
# собственные таблицы данных, описывающие особенности системы письменности, а
# также создаёт правила изменения символов в зависимости от контекста,
# например, лигатур, замены или вставки глифов, диакритики, кернинга и
# выключки.

# Required:    cmake
# Recommended: no
# Optional:    freetype
#              silgraphite                  (для сборки утилиты comparerender - test and benchmarking tool) https://sourceforge.net/projects/silgraphite/files/silgraphite
#              harfbuzz                     (для более полного функционала)
#              graphite-font                (https://graphite.sil.org/)
#              --- для документации ---
#              python3-asciidoc
#              doxygen
#              texlive или install-tl-unx
#              dblatex                      (http://dblatex.sourceforge.net/)
#              --- для тестов ---
#              python3-fonttools            (https://pypi.org/project/fonttools/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# если не установлен пакет python3-fonttools, то некоторые тесты не проходят.
# Исправим:
sed -i '/cmptest/d' tests/CMakeLists.txt || exit 1

mkdir build &&
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Home page: https://graphite.sil.org/
# Download:  https://github.com/silnrsi/graphite/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
