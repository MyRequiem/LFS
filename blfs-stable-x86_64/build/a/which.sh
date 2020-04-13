#! /bin/bash

PRGNAME="which"

### Which
# Команда 'which' принимает один или несколько аргументов и для каждого выводит
# полный путь к исполняемым файлам

# http://www.linuxfromscratch.org/blfs/view/stable/general/which.html

# Home page: https://carlowood.github.io/which/
# Download:  https://ftp.gnu.org/gnu/which/which-2.21.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (shows the full path to shell commands)
#
# GNU 'which' takes one or more arguments. For each of its arguments it prints
# to stdout the full path of the executables that would have been executed when
# this argument had been entered at the shell prompt. It does this by
# searching for an executable or script in the directories listed in the
# environment variable PATH using the same algorithm as bash(1). 'Which' is a
# built-in function in many shells.
#
# Home page: https://carlowood.github.io/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
