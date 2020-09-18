#! /bin/bash

PRGNAME="time"

### Time (the GNU time command for measuring program resource use)
# Программа, которая измеряет ресурсы процессора, такие как время и память,
# которые используют другие программы. Версия GNU может форматировать вывод
# произвольно с помощью строки формата printf-style. Хотя оболочка bash имеет
# встроенную команду 'time', обеспечивающую аналогичные функции, эта утилита
# требуется LSB (Linux Standard Base)

# http://www.linuxfromscratch.org/blfs/view/stable/general/time.html

# Home page: http://www.gnu.org/software/time/
# Download:  https://ftp.gnu.org/gnu/time/time-1.9.tar.gz

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
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the GNU time command for measuring program resource use)
#
# The time utility is a program that measures many of the CPU resources, such
# as time and memory, that other programs use. The GNU version can format the
# output in arbitrary ways by using a printf-style format string to include
# various resource measurements. Although the shell has a builtin command
# providing similar functionalities, this utility is required by the LSB (Linux
# Standard Base)
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
