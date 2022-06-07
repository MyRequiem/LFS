#! /bin/bash

PRGNAME="ag"
ARCH_NAME="the_silver_searcher"

### The Silver Searcher (grep-like text search, but faster)
# Инструмент поиска в файлах, похожий на 'grep' и 'ack', но с акцентом на
# скорость. Ag ищет примерно в 3-5 раз быстрее, чем ack. Игнорирует шаблоны
# файлов из .gitignore и .hgignore в git-репозиториях.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -ivf || exit 1

CFLAGS="-O2 -fPIC -fcommon" \
./configure                 \
    --prefix=/usr           \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (grep-like text search, but faster)
#
# Ag is a code searching tool similar to grep and ack, but with a focus on
# speed. Ag searches code about 3-5x faster than ack. It ignores file patterns
# from your .gitignore and .hgignore. If there are files in your source repo
# you don't want to search, just add their patterns to a .agignore file. The
# command name is 33% shorter than ack!
#
# Home page: https://github.com/ggreer/${ARCH_NAME}
# Download:  https://github.com/ggreer/${ARCH_NAME}/archive/${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
