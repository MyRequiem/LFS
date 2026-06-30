#! /bin/bash

PRGNAME="time"

### Time (the GNU time command for measuring program resource use)
# Классическая консольная утилита, которая измеряет точное время выполнения
# любой запущенной команды или программы. Она также показывает количество
# затраченных системных ресурсов и оперативной памяти. Данная GNU версия может
# форматировать вывод произвольно с помощью параметра --format. Хотя оболочка
# bash имеет встроенную команду 'time', обеспечивающую аналогичные функции, эта
# утилита требуется LSB (Linux Standard Base).

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
