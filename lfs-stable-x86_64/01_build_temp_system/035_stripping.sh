#! /bin/bash

source "$(pwd)/check_environment.sh" || exit 1

# исполняемые файлы и библиотеки, созданные до сих пор, содержат не нужную нам
# отладочную информацию, поэтому можно ее удалить. В выводе следующих команд
# будут присутствовать сообщения о том, что не распознается формат файлов. В
# основном это оносится к скриптам, а не бинарным файлам. Так же используем
# команду strip хоста (/usr/bin/strip), чтобы удалить отладочную информацию с
# бинарника /tools/bin/strip
echo "strip --strip-debug /tools/lib/* ..."
sleep 1
strip --strip-debug /tools/lib/*

echo -e "\n/usr/bin/strip --strip-unneeded /tools/{,s}bin/* ..."
sleep 1
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*

# Note:
# Нельзя использовать --strip-unneeded для библиотек. Статические данные будут
# уничтожены, и пакеты придется пересобирать заново.

# удалим документацию
echo -e "\nrm -rf /tools/{,share}/{info,man,doc} ..."
sleep 1
rm -rf /tools/{,share}/{info,man,doc}

# удалим не нужные *.la файлы (libtool-архивы), устанавливаемые с библиотеками
echo -e "\find /tools/{lib,libexec} -name "*.la" -delete ..."
sleep 1
find /tools/{lib,libexec} -name "*.la" -delete
