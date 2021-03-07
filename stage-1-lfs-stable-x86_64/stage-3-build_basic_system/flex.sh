#! /bin/bash

PRGNAME="flex"

### Flex (fast lexical analyzer generator)
# Пакет содержит утилиту для генерации программ, которые распознают шаблоны в
# тексте

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# некоторые программы еще не знают о flex и пытаются запустить его
# предшественника lex. Для поддержки таких программ создадим ссылку в /usr/bin
# lex -> flex
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sv flex lex
)

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (fast lexical analyzer generator)
#
# flex is a tool for generating programs that perform pattern matching on text.
# Flex is a rewrite of the AT&T Unix lex tool (the two implementations do not
# share any code, though), with some extensions (and incompatibilities).
#
# Home page: https://github.com/westes/${PRGNAME}
# Download:  https://github.com/westes/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
