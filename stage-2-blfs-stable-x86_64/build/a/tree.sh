#! /bin/bash

PRGNAME="tree"

### tree (a program to display a directory tree)
# Рекурсивная программа для отображения дерева каталогов и файлов. Вывод
# производится в терминал с отступами и раскраской "аля" dircolors, если
# установлена переменная окружения LS_COLORS (устанавливается в
# /etc/profile.d/dircolors.sh командой dircolors)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make || exit 1
# пакет не содержит набора тестов
make PREFIX="${TMP_DIR}/usr" MANDIR="${TMP_DIR}/usr/share/man" install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a program to display a directory tree)
#
# Tree is a recursive directory listing program that produces a depth indented
# listing of files, which is colorized ala dircolors if the LS_COLORS
# environment variable is set and output is to tty. With no arguments, tree
# lists the files in the current directory.
#
# Home page: https://mama.indstate.edu/users/ice/${PRGNAME}/
# Download:  https://mama.indstate.edu/users/ice/${PRGNAME}/src/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
