#! /bin/bash

source "${ROOT}check_environment.sh" || exit 1

# временные инструменты нам больше не понадобятся. Можно удалить каталог /tools
# или просто переместить
mv /tools  /root/
