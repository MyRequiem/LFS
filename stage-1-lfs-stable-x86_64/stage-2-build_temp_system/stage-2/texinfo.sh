#! /bin/bash

PRGNAME="texinfo"

### Texinfo
# Программы для чтения, записи и конвертации страниц info

# http://www.linuxfromscratch.org/lfs/view/stable/chapter07/texinfo.html

# Home page: http://www.gnu.org/software/texinfo/

ROOT="/"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# в процессе конфигурации выполняется тест, который выдает ошибку для
# TestXS_la-TestXS.lo. Эта ошибка на данном этапе должна игнорироваться
./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
make install
