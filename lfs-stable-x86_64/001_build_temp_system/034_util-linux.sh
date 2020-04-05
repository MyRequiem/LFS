#! /bin/bash

PRGNAME="util-linux"

### Util-linux
# Содержит различные утилиты для обработки файловых систем, консолей, разделов,
# сообщений и т.д.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/util-linux.html

# Home page: http://freecode.com/projects/util-linux
# Download:  https://www.kernel.org/pub/linux/utils/util-linux/v2.34/util-linux-2.34.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

# в данный момент нужна только утилита rev
make rev
cp rev /tools/bin
