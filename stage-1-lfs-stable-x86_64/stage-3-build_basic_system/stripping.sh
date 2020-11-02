#! /bin/bash

# Исполняемые файлы и библиотеки, созданные до сих пор, содержат не нужную нам
# отладочную информацию, которую можно удалить.

source "${ROOT}check_environment.sh" || exit 1

# В выводе следующих команд будут  присутствовать сообщения о том, что не
# распознается формат файлов. В основном это оносится к скриптам, а не бинарным
# файлам.
find /usr/lib -type f -name "*.a" -exec strip --strip-debug {} \;
find /lib /usr/lib -type f -name "*.so*" -exec strip --strip-unneeded {} \;
find /{bin,sbin} /usr/{bin,sbin,libexec} -type f -exec strip --strip-all {} \;
