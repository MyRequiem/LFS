#! /bin/bash

PRGNAME="texinfo"

### Texinfo (GNU software documentation system)
# Программы для чтения, записи и конвертации страниц info

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# скрипт 'configure' будет жаловаться, что это нераспознанный параметр, но
# сценарий настройки для сборки библиотеки XSParagraph.so распознает его и
# использует для отключения установки статического XSParagraph.a в
# /usr/lib/texinfo
#    --disable-static
./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# установим компоненты, используемые пакетом tetex (texlive), который будет
# установлен в BLFS
make TEXMF="${TMP_DIR}/usr/share/texmf" install-tex

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
# Package: ${PRGNAME} (GNU software documentation system)
#
# 'Texinfo' is a documentation system that uses a single source file to produce
# both on-line information and printed output. Using Texinfo, you can create a
# printed document with the normal features of a book, including chapters,
# sections, cross references, and indices. From the same Texinfo source file,
# you can create a menu-driven, on-line Info file with nodes, menus, cross
# references, and indices. This package is needed to read the documentation
# files in /usr/info
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
