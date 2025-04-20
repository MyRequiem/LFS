#! /bin/bash

PRGNAME="colm"

### colm (Programming language)
# Язык программирования, разработанный для анализа и преобразование других
# языков

# Required:    no
# Recommended: no
# Optional:    no

###
# WARNING !!!
#    после установки пакета НЕ удаляем .la файлы из /usr/lib/ т.к. они
#    требуются для сборки пакета ragel
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure     \
  --prefix=/usr \
  --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# пакет при установке пытается генерировать html документацию из .adoc файлов
# средствами пакета python3-asciidoc. Если asciidoc не установлен происходит
# ошибка 'make install', поэтому отменим создание html
sed '312,322 d;329,339 d;'          -i doc/${PRGNAME}/Makefile || exit 1
sed 's/IN_FILES = \\/IN_FILES =/'   -i doc/${PRGNAME}/Makefile || exit 1
sed 's/OUT_FILES = \\/OUT_FILES =/' -i doc/${PRGNAME}/Makefile || exit 1

make install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}" || exit 1
    # удалим статические библиотеки
    rm -f usr/lib/{libfsm,libcolm}.a
    # удалим документацию
    rm -rf usr/share/doc
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Programming language)
#
# Colm is a programming language designed for the analysis and and
# transformation of computer languages. Colm is influenced primarily by TXL. It
# is in the family of program transformation languages.
#
# Home page: https://www.${PRGNAME}.net/open-source/${PRGNAME}/
# Download:  https://www.${PRGNAME}.net/files/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
