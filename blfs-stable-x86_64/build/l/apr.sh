#! /bin/bash

PRGNAME="apr"

### Apr
# Apache Portable Runtime (APR) - библиотека, разрабатываемая Apache Software
# Foundation и изначально входящая в состав веб-сервера Apache, но затем
# выделенная в независимый проект. APR является кросс-платформенной оберткой
# над рядом API, в той или иной степени представленных в ОС. В случае, если
# операционная система не поддерживает нужной функциональности, APR
# обеспечивает её эмуляцию для поддержки кросс-платформенности.

# Предоставляет следующий функционал:
#     - Менеджер памяти
#     - Атомарные операции
#     - Файловый ввод-вывод
#     - Парсинг аргументов командой строки
#     - Блокировки
#     - Хеш-таблицы
#     - Массивы
#     - Mmap
#     - Сетевые сокеты
#     - Потоки, процессы и мьютексы
#     - Разделяемая память

# http://www.linuxfromscratch.org/blfs/view/stable/general/apr.html

# Home page: https://apr.apache.org/
# Download:  https://archive.apache.org/dist/apr/apr-1.7.0.tar.bz2

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
    --with-installbuilddir=/usr/share/apr-1/build || exit 1

make || exit 1
# make test
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Apache Portable Runtime)
#
# The mission of the Apache Portable Runtime (APR) project is to create and
# maintain software libraries that provide a predictable and consistent
# interface to underlying platform-specific implementations. The primary goal
# is to provide an API to which software developers may code and be assured of
# predictable if not identical behaviour regardless of the platform on which
# their software is built, relieving them of the need to code special-case
# conditions to work around or take advantage of platform-specific deficiencies
# or features.
#
# Home page: https://apr.apache.org/
# Download:  https://archive.apache.org/dist/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
