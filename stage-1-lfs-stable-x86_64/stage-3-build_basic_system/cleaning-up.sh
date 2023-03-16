#! /bin/bash

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

# удалим # временного пользователя tester
userdel -r tester
