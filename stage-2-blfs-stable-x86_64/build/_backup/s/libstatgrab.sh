#! /bin/bash

PRGNAME="libstatgrab"

### libstatgrab (library for cross platform access to system statistics)
# Кроссплатформенная библиотека, написанная на C и предоставляющая полезные
# интерфейсы, которые можно использовать для доступа к ключевой системной
# статистике: использование процессора, памяти, количество процессов, сетевой
# трафик, дисковый ввод-вывод и многое другое.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libstatgrab.html

# Home page: https://libstatgrab.org/
# Download:  http://www.mirrorservice.org/sites/ftp.i-scream.org/pub/i-scream/libstatgrab/libstatgrab-0.92.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for cross platform access to system statistics)
#
# This is a library that provides cross platform access to statistics about the
# system on which it's run. It's written in C and presents a selection of
# useful interfaces which can be used to access key system statistics. The
# current list of statistics includes CPU usage, memory utilisation, disk
# usage, process counts, network traffic, disk I/O, and more.
#
# Home page: https://libstatgrab.org/
# Download:  http://www.mirrorservice.org/sites/ftp.i-scream.org/pub/i-scream/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
