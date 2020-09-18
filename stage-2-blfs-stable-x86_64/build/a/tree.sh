#! /bin/bash

PRGNAME="tree"

### tree (a program to display a directory tree)
# Рекурсивная программа для отображения дерева каталогов и файлов. Вывод
# производится в терминал с отступами и раскраской аля dircolors, если
# установлена переменная окружения LS_COLORS (устанавливается в
# /etc/profile.d/dircolors.sh командой dircolors)

# http://www.linuxfromscratch.org/blfs/view/stable/general/tree.html

# Home page: http://mama.indstate.edu/users/ice/tree/
# Download:  ftp://mama.indstate.edu/linux/tree/tree-1.8.0.tgz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/"{bin,share/man/man1}

make || exit 1
# пакет не содержит набора тестов

cp -v tree "/usr/bin"
cp -v tree "${TMP_DIR}/usr/bin"

chmod -v 644 doc/tree.1
cp -v doc/tree.1 /usr/share/man/man1/
cp -v doc/tree.1 "${TMP_DIR}/usr/share/man/man1/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a program to display a directory tree)
#
# Tree is a recursive directory listing program that produces a depth indented
# listing of files, which is colorized ala dircolors if the LS_COLORS
# environment variable is set and output is to tty. With no arguments, tree
# lists the files in the current directory.
#
# Home page: http://mama.indstate.edu/users/ice/${PRGNAME}/
# Download:  ftp://mama.indstate.edu/linux/${PRGNAME}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
