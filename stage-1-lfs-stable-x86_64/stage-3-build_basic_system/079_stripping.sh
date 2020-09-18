#! /bin/bash

source "${ROOT}check_environment.sh" || exit 1

# Исполняемые файлы и библиотеки, созданные до сих пор, содержат не нужную нам
# отладочную информацию, которую можно удалить. Сначала поместим отладочную
# информацию для выбранных библиотек в отдельные файлы (lib_name.dbg). Эта
# отладочная информация необходима, если выполняются регрессионные тесты,
# использующие Valgrind или GDB позже в BLFS
SAVE_LIB="              \
    ld-2.31.so          \
    libc-2.31.so        \
    libpthread-2.31.so  \
    libthread_db-1.0.so \
"

cd /lib || exit 1
for LIB in ${SAVE_LIB}; do
    objcopy --only-keep-debug "${LIB}" "${LIB}.dbg"
    strip --strip-unneeded "${LIB}"
    objcopy --add-gnu-debuglink="${LIB}.dbg" "${LIB}"
done

SAVE_USRLIB="            \
    libatomic.so.1.2.0   \
    libitm.so.1.0.0      \
    libquadmath.so.0.0.0 \
    libstdc++.so.6.0.27  \
"

cd /usr/lib || exit 1
for LIB in ${SAVE_USRLIB}; do
    objcopy --only-keep-debug "${LIB}" "${LIB}.dbg"
    strip --strip-unneeded "${LIB}"
    objcopy --add-gnu-debuglink="${LIB}.dbg" "${LIB}"
done

unset LIB SAVE_LIB SAVE_USRLIB

# теперь отладочную информацию из двоичных файлов и библиотек можно безопасно
# удалить. В выводе этих команд будут  присутствовать сообщения о том, что не
# распознается формат файлов. В основном это оносится к скриптам, а не бинарным
# файлам.
/tools/bin/find /usr/lib -type f -name "*.a" \
   -exec /tools/bin/strip --strip-debug {} \;

/tools/bin/find /lib /usr/lib -type f \( -name "*.so*" -a ! -name "*dbg" \) \
   -exec /tools/bin/strip --strip-unneeded {} \;

/tools/bin/find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
    -exec /tools/bin/strip --strip-all {} \;
