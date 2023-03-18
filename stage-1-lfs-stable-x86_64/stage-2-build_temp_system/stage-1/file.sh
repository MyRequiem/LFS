#! /bin/bash

PRGNAME="file"

### File
# Утилита для определения типа файла

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# утилита 'file' на хосте должна быть той же версии, что и та, которую мы
# создаем для LFS (для создания файла подписи). Создадим утилиту на хосте:
mkdir -p build
pushd build || exit 1

../configure             \
    --disable-bzlib      \
    --disable-libseccomp \
    --disable-xzlib      \
    --disable-zlib || exit 1

make || make -j1 || exit 1
popd || exit 1

# конфигурируем и собираем пакет для LFS
./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(./config.guess)" || exit 1

# путь к утилите 'file', которую мы только что скомпилировали
FILE_COMPILE_PATH="$(pwd)/build/src/file"
make FILE_COMPILE="${FILE_COMPILE_PATH}" || \
    make -j1 FILE_COMPILE="${FILE_COMPILE_PATH}" || exit 1

make install DESTDIR="${LFS}"

# удалим libtool архив (.la), поскольку он вреден для кросс-компиляции
rm -fv "${LFS}/usr/lib/libmagic.la"
