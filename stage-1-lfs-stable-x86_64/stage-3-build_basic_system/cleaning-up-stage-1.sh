#! /bin/bash

source "${ROOT}check_environment.sh" || exit 1

# временные инструменты /tools нам больше не понадобятся и можно их удалить
rm -rf /tools
